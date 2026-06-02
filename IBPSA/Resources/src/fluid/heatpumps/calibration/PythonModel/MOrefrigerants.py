# -*- coding: utf-8 -*-
from __future__ import division, print_function, absolute_import

from dymola.dymola_interface import DymolaInterface
import numpy as np
import time as tm


class ModelicaPropRefrigerant(object):
    """ Class for the evaluation of properties of refrigerant from a Modelica library.
    
    """

    def __init__(self, ref_name, ModelicaModelPath, map_libraries):
        from scipy.interpolate import interp1d, RegularGridInterpolator, LinearNDInterpolator
        self.ref_name = ref_name
        self.Medium = ModelicaModelPath
        self.IBPSA_ref_package = "IBPSA.Media.Refrigerants"    
        self.dymola = DymolaInterface()
        self.dymola.ExecuteCommand(f'DymolaCommands.SimulatorAPI.openModel("{map_libraries["IBPSA"]}/package.mo")')
        self.dymola.ExecuteCommand(f'DymolaCommands.SimulatorAPI.openModel("{map_libraries[ModelicaModelPath.split(".")[0]]}/package.mo")')
        self.dymola.ExecuteCommand(f'translateModel("{self.IBPSA_ref_package + "." + ref_name}")')            
        # Critical temperature (K)
        self.TCri = self.dymola.ExecuteCommand("fluidConstants.criticalTemperature")[0]
        # Critical pressure (Pa)
        self.pCri = self.dymola.ExecuteCommand("fluidConstants.criticalPressure")[0]
        # Critical volume (m3/kg)
        tol_p = 1001
        self.vCri = 1/self.dymola.ExecuteCommand(f'{self.Medium}.density({self.Medium}.setState_pTX({self.pCri}+{tol_p},{self.TCri}))')
        # Minimum temperature for property evaluation (K)
        self.T_min = self.dymola.ExecuteCommand("fluidLimits.TMIN")[0]
        # dymola.ExecuteCommand("fluidLimits.TMAX")
        self.T_max = self.dymola.ExecuteCommand("fluidLimits.TMAX")[0]

        deltaT = 0.01
        T_range = np.round(np.arange(self.T_min,self.TCri + deltaT, deltaT),4)
        T_range_str = "{" + ",".join(map(str, T_range)) + "}"   
        tic = tm.time()
        get_SaturatedLiquidPressure_map = {"T":T_range, "y":self.dymola.ExecuteCommand(f'{self.Medium}.saturationPressure({T_range_str})')}    
        self._pLiqsat_interp = interp1d(
            get_SaturatedLiquidPressure_map["T"],
            get_SaturatedLiquidPressure_map["y"],
            kind='linear',
            bounds_error=True
        )
        get_SaturatedVaporPressure_map = get_SaturatedLiquidPressure_map
        self._pVapsat_interp = interp1d(
            get_SaturatedVaporPressure_map["T"],
            get_SaturatedVaporPressure_map["y"],
            kind='linear',
            bounds_error=True
        )
        
        get_SaturatedLiquidEnthalpy_map = {"T":T_range, "y":self.dymola.ExecuteCommand(f'{self.Medium}.bubbleEnthalpy({self.Medium}.setSat_T({T_range_str}))')}  
        self._hLiqsat_interp = interp1d(
            get_SaturatedLiquidEnthalpy_map["T"],
            get_SaturatedLiquidEnthalpy_map["y"],
            kind='linear',
            bounds_error=True
        )
        
        get_SaturatedVaporEnthalpy_map = {"T":T_range, "y":self.dymola.ExecuteCommand(f'{self.Medium}.dewEnthalpy({self.Medium}.setSat_T({T_range_str}))')}
        self._hVapsat_interp = interp1d(
            get_SaturatedVaporEnthalpy_map["T"],
            get_SaturatedVaporEnthalpy_map["y"],
            kind='linear',
            bounds_error=True
        )
        toc = tm.time() - tic
        print("Linear functions ready. time = ", toc, " s")
        
   
        try: 
            data_2D = np.load("refmaps/"+ModelicaModelPath+"_maps.npz")
            print("Ref 2D data is laoded.")
            get_SpecificIsobaricHeatCapacity_vT_2Dmap = data_2D["cp"]
            get_SpecificIsochoricHeatCapacity_vT_2Dmap = data_2D["cv"]
            get_IsentropicExponent_vT_2Dmap = data_2D["kappa"]
            get_VaporPressure_2Dmap = data_2D["pVap"]
            T_range_2D = data_2D["T_range_2D"]
            d_range = data_2D["d_range"]
            intermediate_toc = tm.time()  - tic
            print("Load 2D files ", intermediate_toc, " s")
        except FileNotFoundError:
            raise FileNotFoundError(
            f"Required refrigerant map files are missing for {ModelicaModelPath}.\n"
            f"Required file:\n"
            f"  refmaps/{ModelicaModelPath}_maps.npz\n"
            f"Fix: run ModelicaPropRefrigerantMap() in example_calibration.py before using ModelicaPropRefrigerant."
            ) 
  
        self.cp_interp = RegularGridInterpolator(
            (T_range_2D, d_range),
            get_SpecificIsobaricHeatCapacity_vT_2Dmap,
            bounds_error=True)        
        
        self.cv_interp = RegularGridInterpolator(
            (T_range_2D, d_range),
            get_SpecificIsochoricHeatCapacity_vT_2Dmap,
            bounds_error=True)
        
        self.kappa_interp = RegularGridInterpolator(
            (T_range_2D, d_range),
            get_IsentropicExponent_vT_2Dmap,
            bounds_error=True)

        self.pVap_interp = RegularGridInterpolator(
            (T_range_2D, d_range),
            get_VaporPressure_2Dmap,
            bounds_error=True)        
     
        print("2D functions ready.")
        try: 
            data_v = np.load("refmaps/"+ModelicaModelPath+"_v_map.npz")
            T_all = data_v["T"]
            p_all = data_v["p"]
            v_all = data_v["v"]
            toc = tm.time()-tic
            print("Load v file ", toc, " s")         
        except FileNotFoundError:
            raise FileNotFoundError(
            f"Required refrigerant map files are missing for {ModelicaModelPath}.\n"
            f"Required file:\n"
            f"  refmaps/{ModelicaModelPath}_v_map.npz\n\n"
            f"Fix: run ModelicaPropRefrigerantMap() in example_calibration.py before using ModelicaPropRefrigerant."
            ) 
            
 
        self.interp_func = LinearNDInterpolator(
            list(zip(T_all, p_all)),
            v_all
        )
        print("specificVolumeVap_pT function ready")        

    def get_IsentropicExponent_vT(self, v, T):
        """ Evaluate the isentropic exponent.

        :param v: Specific volume of the refrigerant (m3/kg).
        :param T: Temperature of the refrigerant (K).

        :return: Isentropic exponent (-).

        Usage: Type
           >>> ref = R410A()
           >>> '%.4f' % ref.get_IsentropicExponent_vT(0.025, 289.64)
           '1.3862'

        """
        k = self.kappa_interp((T,1/v))
        if np.isnan(k).any():
            k = self.dymola.ExecuteCommand(f'{self.Medium}.isentropicExponent({self.Medium}.setState_dTX(1/{v},{T}))')
        else:    
            k = float(k)
            #print("Call get_IsentropicExponent_vT ..", k)
        return k

    def get_SpecificIsobaricHeatCapacity_vT(self, v, T):
        """ Evaluate the specific isobaric heat capacity.

        :param v: Specific volume of the refrigerant (m3/kg).
        :param T: Temperature of the refrigerant (K).

        :return: Specific isobaric heat capacity (J/kg-K).

        Usage: Type
           >>> ref = R410A()
           >>> '%.2f' % ref.get_SpecificIsobaricHeatCapacity_vT(0.025, 289.64)
           '1167.01'

        """  
        cp = self.cp_interp((T,1/v))
        if np.isnan(cp).any():
            cp = self.dymola.ExecuteCommand(f'{self.Medium}.specificHeatCapacityCp({self.Medium}.setState_dTX(1/{v},{T}))')
        else:
            cp = float(cp)
        #print("Call get_SpecificIsobaricHeatCapacity_vT ..", cp)
        return cp

    def get_SpecificIsochoricHeatCapacity_vT(self, v, T):
        """ Evaluate the specific isochoric heat capacity.

        :param v: Specific volume of the refrigerant (m3/kg).
        :param T: Temperature of the refrigerant (K).

        :return: Specific isochoric heat capacity (J/kg-K).

        Usage: Type
           >>> ref = R410A()
           >>> '%.2f' % ref.get_SpecificIsochoricHeatCapacity_vT(0.025, 289.64)
           '841.85'

        """ 
        cv = self.cv_interp((T,1/v))
        if np.isnan(cv).any():
            cv = self.dymola.ExecuteCommand(f'{self.Medium}.specificHeatCapacityCv({self.Medium}.setState_dTX(1/{v},{T}))')
        else:
            cv = float(cv)
        return cv

    def get_SaturatedLiquidPressure(self, TLiq):
        """ Evaluate the pressure of saturated liquid refrigerant.

        :param TLiq: Temperature of the saturated liquid refrigerant (K).

        :return: Pressure of saturated liquid refrigerant (Pa).

        Usage: Type
           >>> ref = R410A()
           >>> '%.2f' % ref.get_SaturatedLiquidPressure(305.25)
           '1989639.98'

        """ 
        pLiq= self._pLiqsat_interp(TLiq)
        if np.isnan(pLiq).any():
            pLiq = self.dymola.ExecuteCommand(f'{self.Medium}.saturationPressure({TLiq})')
        else:
            pLiq = float(pLiq)
        return pLiq

    def get_SaturatedVaporPressure(self, TVap):
        """ Evaluate the pressure of saturated refrigerant vapor.

        :param TLiq: Temperature of the saturated liquid refrigerant (K).

        :return: Pressure of saturated refrigerant vapor (Pa).

        Usage: Type
           >>> ref = R410A()
           >>> '%.2f' % ref.get_SaturatedVaporPressure(283.15)
           '1082792.93'

        """ 
        pVap = self._pVapsat_interp(TVap)
        if np.isnan(pVap).any():
            pVap = self.dymola.ExecuteCommand(f'{self.Medium}.saturationPressure({TVap})')
        else:
            pVap = float(pVap)
        return pVap

    def get_SaturatedLiquidEnthalpy(self, TLiq):
        """ Evaluate the specific enthalpy of saturated liquid refrigerant.

        :param TLiq: Temperature of the saturated liquid refrigerant (K).

        :return: Specific enthalpy of saturated liquid refrigerant (J/kg).

        Usage: Type
           >>> ref = R410A()
           >>> '%.2f' % ref.get_SaturatedLiquidEnthalpy(305.25)
           '252787.45'

        """
        hLiq = self._hLiqsat_interp(TLiq)
        if np.isnan(hLiq).any():
            hLiq = self.dymola.ExecuteCommand(f'{self.Medium}.bubbleEnthalpy({self.Medium}.setSat_T({TLiq}))')
        else:
            hLiq = float(hLiq)
        #print("Call get_SaturatedLiquidEnthalpy ..", hLiq)
        return hLiq

    def get_SaturatedVaporEnthalpy(self, TVap):
        """ Evaluate the specific enthalpy of saturated liquid refrigerant.

        :param TLiq: Temperature of the saturated liquid refrigerant (K).

        :return: Specific enthalpy of saturated liquid refrigerant (J/kg).

        .. note:: Correlated properties from the thermodynamic properties of
                  DuPont Suva R410A. An expression similar to the saturated
                  liquid enthalpy was used.

        Usage: Type
           >>> ref = R410A()
           >>> '%.2f' % ref.get_SaturatedVaporEnthalpy(283.15)
           '425094.18'

        """

        hVap = self._hVapsat_interp(TVap)
        if np.isnan(hVap).any(): 
            hVap = self.dymola.ExecuteCommand(f'{self.Medium}.dewEnthalpy({self.Medium}.setSat_T({TVap}))')
        else:
            hVap = float(hVap)
        return hVap

    def get_VaporPressure(self, TVap, vVap):
        """ Evaluate the pressure of refrigerant vapor.

        :param TVap: Temperature of refrigerant vapor (K).
        :param vVap: Specific volume of refrigerant vapor (m3/kg).

        :return: Pressure of refrigerant vapor (Pa).

        The pressure is calculated fromthe Martin-Hou equation of state for
        refrigerant  R410A.

        Usage: Type
           >>> ref = R410A()
           >>> '%.2f' % ref.get_VaporPressure(289.64, 0.025)
           '1083546.30'

        """
        pVap = self.pVap_interp((TVap,1/vVap))
        if np.isnan(pVap).any():
            pVap = self.dymola.ExecuteCommand(f'{self.Medium}.pressure({self.Medium}.setState_dTX(1/{vVap},{TVap}))')
            #print(f"pVap outside of range, (TVap,vVap): ({TVap:.2f}, {vVap:.0f}) → fallback pVap = {pVap:.6f}")
        else:
            pVap = float(pVap)
        return pVap

    def get_VaporSpecificVolume(self, p, T, tol=1e-6):
        """ Evaluate the Specific of refrigerant vapor.

        :param p: Pressure of refrigerant vapor (Pa).
        :param T: Temperature of refrigerant vapor (K).

        :return: Specific volume of refrigerant vapor (m3/kg).

        Uses the Martin-Hou equation of state to determine specific volume.

        Usage: Type
           >>> ref = R410A()
           >>> '%.8f' % ref.get_VaporSpecificVolume(1083546.3, 289.64)
           '0.02500001'

        """

        v_interp = self.interp_func((T, p))
        if v_interp is None or np.isnan(v_interp).any():   
            v = 1/self.dymola.ExecuteCommand(f'1/{self.Medium}.density({self.Medium}.setState_pTX({p},{T}))')
            #print(f"v outside of range, (T,p): ({T:.2f}, {p:.0f}) → fallback v = {v:.6f}")
        else:
            v = float(v_interp)
        return v

