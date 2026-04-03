from __future__ import division, print_function, absolute_import

from CoolProp.CoolProp import PropsSI
from dymola.dymola_interface import DymolaInterface
import numpy as np
import os
import time as tm
from fmpy import *

class FMUPropRefrigerant(object):
    """ Class for the evaluation of properties of refrigerant from a Modelica library using FMU.

    
    """

    def __init__(self, ref_name, modelicaModelPath):  
        self.IBPSA_ref_package = "IBPSA.Media.Refrigerants"
        map_libraries = {"IBPSA":r"S:/Carles/Repositories/Carles-IBPSA/IBPSA",
                "ThermofluidStream":r"S:/Carles/Repositories/DLR/ThermofluidStream"}        
        self.dymola = DymolaInterface()
        package_file = map_libraries["IBPSA"]+ "/package.mo"
        command = f'DymolaCommands.SimulatorAPI.openModel("{package_file}")'
        self.dymola.ExecuteCommand(command)
        self.dymola.ExecuteCommand("DymolaCommands.System.getLastError()")
        libray_name = modelicaModelPath.split(".")[0]
        package_file = map_libraries[libray_name]+ "/package.mo"
        command = f'DymolaCommands.SimulatorAPI.openModel("{package_file}")'
        self.dymola.ExecuteCommand(command)     
        self.dymola.ExecuteCommand("DymolaCommands.System.getLastError()")
        self.name = ref_name
        self.IBPSAMedium = self.IBPSA_ref_package + "." + ref_name
        self.LibraryMedium = modelicaModelPath
        self.IBPSAMedium_cal = r'IBPSA.Media.Refrigerants.Calibration.'+ ref_name
        self.wd = r'S:/Carles/WDs/WD8'
        self.dymola.ExecuteCommand(f'cd("{self.wd}")')
        os.chdir(self.wd)
        print(os.getcwd(), " .. and translateModelFMU")
        fmu = self.dymola.ExecuteCommand(f'translateModelFMU("{self.IBPSAMedium_cal}", fmiVersion="3")')
        self.dymola.ExecuteCommand("DymolaCommands.System.getLastError()")
        self.fmu = f"{fmu}.fmu"
        print("self.fmu: ", self.fmu)
        print(os.getcwd())
        result = simulate_fmu(self.fmu,start_values={'T_in': 300, 'v_in': 1, 'p_in': 100000},
                              start_time=0,
                              stop_time=0,
                              output_interval=1)
        # Critical temperature (K)
        self.TCri = result["TCri"][-1]
        # Critical pressure (Pa)
        self.pCri = result["pCri"][-1]
        # Critical volume (m3/kg)
        self.vCri =  result["vCri"][-1]
        # Minimum temperature for property evaluation (K)
        self.T_min = result["T_min"][-1]      

        

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
        result = simulate_fmu(self.fmu,start_values={'T_in': T, 'v_in': v, 'p_in': 100000},
                              start_time=0,
                              stop_time=0,
                              output_interval=1)
        k = result["k"][-1]
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
        result = simulate_fmu(self.fmu,start_values={'T_in': T, 'v_in': v, 'p_in': 100000},
                              start_time=0,
                              stop_time=0,
                              output_interval=1)
        cp = result["cp"][-1]
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
        result = simulate_fmu(self.fmu,start_values={'T_in': T, 'v_in': v, 'p_in': 100000},
                              start_time=0,
                              stop_time=0,
                              output_interval=1)
        cv = result["cv"][-1]
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
        result = simulate_fmu(self.fmu,start_values={'T_in': Tliq, 'v_in':0.1, 'p_in': 100000},
                              start_time=0,
                              stop_time=0,
                              output_interval=1)
        pLiq = result["pLiq"][-1]
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
        result = simulate_fmu(self.fmu,start_values={'T_in': TVap, 'v_in':0.1, 'p_in': 100000},
                              start_time=0,
                              stop_time=0,
                              output_interval=1)
        pVap = result["pVap"][-1]
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
        result = simulate_fmu(self.fmu,start_values={'T_in': TLiq, 'v_in':0.1, 'p_in': 100000},
                              start_time=0,
                              stop_time=0,
                              output_interval=1)
        hLiq = result["hLiq"][-1]
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
        #print("Call get_SaturatedVaporEnthalpy .. TVap: ", TVap)
        result = simulate_fmu(self.fmu,start_values={'T_in': TVap, 'v_in':0.1, 'p_in': 100000},
                              start_time=0,
                              stop_time=0,
                              output_interval=1)
        hVap = result["hVap"][-1]
        #print("Call get_SaturatedVaporEnthalpy  .. hVap: ", hVap)
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
        #print("Call get_VaporPressure ..", TVap, " ", vVap)
        result = simulate_fmu(self.fmu,start_values={'T_in': TVap, 'v_in':vVap, 'p_in': 100000},
                              start_time=0,
                              stop_time=0,
                              output_interval=1)
        pVap = result["pVap"][-1]    
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
        result = simulate_fmu(self.fmu,start_values={'T_in': T, 'v_in':0.1, 'p_in':p},
                              start_time=0,
                              stop_time=0,
                              output_interval=1)
        v = result["v"][-1]
        print("v: ", v)
        return v

class ModelicaPropRefrigerant(object):
    """ Class for the evaluation of properties of refrigerant from a Modelica library.

    
    """

    def __init__(self, ref_name, modelicaModelPath):
        from scipy.interpolate import interp1d, RegularGridInterpolator, LinearNDInterpolator
        self.IBPSA_ref_package = "IBPSA.Media.Refrigerants"
        map_libraries = {"IBPSA":r"S:/Carles/Repositories/Carles-IBPSA/IBPSA",
                         "ThermofluidStream":r"S:/Carles/Repositories/DLR/ThermofluidStream"}        
        self.dymola = DymolaInterface()
        self.dymola.ExecuteCommand(f'DymolaCommands.SimulatorAPI.openModel("{map_libraries["IBPSA"]}/package.mo")')
        self.dymola.ExecuteCommand(f'DymolaCommands.SimulatorAPI.openModel("{map_libraries[modelicaModelPath.split(".")[0]]}/package.mo")')        
        self.ref_name = ref_name
        self.IBPSAMedium = modelicaModelPath
        self.IBPSAMedium_cal = r'IBPSA.Media.Refrigerants.Calibration.'+ ref_name
        self.dymola.ExecuteCommand(f'translateModel("{self.IBPSAMedium_cal}")')
        # Critical temperature (K)
        self.TCri = self.dymola.ExecuteCommand("TCri")
        # Critical pressure (Pa)
        self.pCri = self.dymola.ExecuteCommand("pCri")
        # Critical volume (m3/kg)
        tol = 1001
        self.vCri = self.dymola.ExecuteCommand(f'{self.IBPSAMedium}.specificVolumeVap_pT({self.pCri}+{tol},{self.TCri})')
        # Minimum temperature for property evaluation (K)
        self.T_min = self.dymola.ExecuteCommand("T_min")
        #self.T_max = self.dymola.ExecuteCommand("T_max")

        deltaT = 0.01
        T_range = np.round(np.arange(self.T_min,self.TCri + deltaT, deltaT),4)
        T_range_str = "{" + ",".join(map(str, T_range)) + "}"   
        
        tic = tm.time()
        get_SaturatedLiquidPressure_map = {"T":T_range, "y":self.dymola.ExecuteCommand(f'{self.IBPSAMedium}.saturationPressure({T_range_str})')}    
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
        
        get_SaturatedLiquidEnthalpy_map = {"T":T_range, "y":self.dymola.ExecuteCommand(f'{self.IBPSAMedium}.bubbleEnthalpy({self.IBPSAMedium}.setSat_T({T_range_str}))')}  
        self._hLiqsat_interp = interp1d(
            get_SaturatedLiquidEnthalpy_map["T"],
            get_SaturatedLiquidEnthalpy_map["y"],
            kind='linear',
            bounds_error=True
        )
        
        get_SaturatedVaporEnthalpy_map = {"T":T_range, "y":self.dymola.ExecuteCommand(f'{self.IBPSAMedium}.dewEnthalpy({self.IBPSAMedium}.setSat_T({T_range_str}))')}
        self._hVapsat_interp = interp1d(
            get_SaturatedVaporEnthalpy_map["T"],
            get_SaturatedVaporEnthalpy_map["y"],
            kind='linear',
            bounds_error=True
        )
        toc = tm.time() - tic
        print("Linear functions ", toc, " s")
        
   
        tic = tm.time()
        deltaT_reduced = 0.1
        T_min_reduced = 273.15 - 30
        T_range_2D = np.round(np.arange(T_min_reduced, self.TCri + deltaT_reduced, deltaT_reduced),4)
        try: 
            data_2D = np.load(modelicaModelPath+"_maps.npz")
            print("Ref 2D data is laoded.")
            get_SpecificIsobaricHeatCapacity_vT_2Dmap = data_2D["cp"]
            get_SpecificIsochoricHeatCapacity_vT_2Dmap = data_2D["cv"]
            get_IsentropicExponent_vT_2Dmap = data_2D["kappa"]
            get_VaporPressure_2Dmap = data_2D["pVap"]
            T_range_2D = data_2D["T_range_2D"]
            v_range = data_2D["v_range"]
            intermediate_toc = tm.time()  - tic
            print("Load 2D files ", intermediate_toc, " s")
        except FileNotFoundError:
            v_range = np.arange(0.0001, 1.5, 0.001)
            v_slice_str = "{" + ",".join(map(str, v_range)) + "}"        
            get_SpecificIsobaricHeatCapacity_vT_2Dmap = np.zeros((len(T_range_2D), len(v_range)))
            get_SpecificIsochoricHeatCapacity_vT_2Dmap = np.zeros((len(T_range_2D), len(v_range)))
            get_IsentropicExponent_vT_2Dmap = np.zeros((len(T_range_2D), len(v_range)))
            get_VaporPressure_2Dmap = np.zeros((len(T_range_2D), len(v_range)))
            
            print("Start for loop to generate 2D ref data, length... ", len(T_range_2D))
            for j, T_ in enumerate(T_range_2D):
                if j % 50 == 0:
                    print(f"Progress: {j}/{len(T_range_2D)} (T={T_})")
                cp_slice = np.array(self.dymola.ExecuteCommand(f'{self.IBPSAMedium}.specificIsobaricHeatCapacityVap_Tv({T_},{v_slice_str})'))
                get_SpecificIsobaricHeatCapacity_vT_2Dmap[j,:] = cp_slice 
                cv_slice = np.array(self.dymola.ExecuteCommand(f'{self.IBPSAMedium}.specificIsochoricHeatCapacityVap_Tv({T_},{v_slice_str})'))
                get_SpecificIsochoricHeatCapacity_vT_2Dmap[j,:] = cv_slice
                get_IsentropicExponent_vT_2Dmap[j,:] = cp_slice / cv_slice
                get_VaporPressure_2Dmap[j,:] = np.array(self.dymola.ExecuteCommand(f'{self.IBPSAMedium}.pressureVap_Tv({T_},{v_slice_str})'))
            
            print("Loop to generate 2D ref data has finished")
            np.savez_compressed(
            modelicaModelPath+"_maps.npz",
            cp=get_SpecificIsobaricHeatCapacity_vT_2Dmap,
            cv=get_SpecificIsochoricHeatCapacity_vT_2Dmap,
            kappa=get_IsentropicExponent_vT_2Dmap,
            pVap=get_VaporPressure_2Dmap,
            T_range_2D=T_range_2D,
            v_range=v_range)

            intermediate_toc = tm.time()  - tic      
            print("Maps ready: ", intermediate_toc)
      
        self.cp_interp = RegularGridInterpolator(
            (T_range_2D, v_range),
            get_SpecificIsobaricHeatCapacity_vT_2Dmap,
            bounds_error=True
        )        
        
        self.cv_interp = RegularGridInterpolator(
            (T_range_2D, v_range),
            get_SpecificIsochoricHeatCapacity_vT_2Dmap,
            bounds_error=True
        )
        
        self.kappa_interp = RegularGridInterpolator(
            (T_range_2D, v_range),
            get_IsentropicExponent_vT_2Dmap,
            bounds_error=True)

        self.pVap_interp = RegularGridInterpolator(
            (T_range_2D, v_range),
            get_VaporPressure_2Dmap,
            bounds_error=True)
        
        toc = tm.time() - tic
        print("2D map Functions ", toc, " s")
        print(".. create functions: ", toc - intermediate_toc)
        
        tic = tm.time()
        try: 
            data_v = np.load(modelicaModelPath+"_v_map.npz")
            T_all = data_v["T"]
            p_all = data_v["p"]
            v_all = data_v["v"]
            toc = tm.time()-tic
            print("Load v file ", toc, " s")         
        except FileNotFoundError:  
            v_slices = []
            p_slices = []
            for T_ in T_range_2D:
                p_sat = self._pVapsat_interp(T_)
                # Create pressure array up to p_sat
                p_range = np.append(np.arange(10000, p_sat, 10000), p_sat)
                
                valid_v = []
                valid_p = []
                
                for p_ in p_range:
                    try:
                        v_val = self.dymola.ExecuteCommand(
                            f'{self.IBPSAMedium}.specificVolumeVap_pT({p_},{T_})'
                        )
                        valid_v.append(v_val)
                        valid_p.append(p_)
                    except Exception as e:
                        # Skip this point if calculation fails
                        print(f"Skipping T={T_}, p={p_}: {e}")
                        continue
                
                v_slices.append(np.array(valid_v))
                p_slices.append(np.array(valid_p))
                
            T_all = []
            p_all = []
            v_all = []
        
            for j, T_ in enumerate(T_range_2D):
                if j % 50 == 0:
                    print(f"Progress: {j}/{len(T_range_2D)} (T={T_})")
                for k in range(len(p_slices[j])):
                    T_all.append(T_)
                    p_all.append(p_slices[j][k])
                    v_all.append(v_slices[j][k])
                    
            np.savez_compressed(
            modelicaModelPath+"_v_map.npz",
            T = np.array(T_all),
            p = np.array(p_all),
            v = np.array(v_all)
            )  
            toc = tm.time() - tic
            print("Generate data, ", toc, " s")
        
        tic = tm.time()
        self.interp_func = LinearNDInterpolator(
            list(zip(T_all, p_all)),
            v_all
        )
        toc = tm.time() - tic
        print("specificVolumeVap_pT function", toc, " s")
        

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
        k = self.kappa_interp((T,v))
        if np.isnan(k).any():
            k = self.dymola.ExecuteCommand(f'{self.IBPSAMedium}.isentropicExponentVap_Tv({T},{v})')
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
        cp = self.cp_interp((T,v))
        if np.isnan(cp).any():
            cp = self.dymola.ExecuteCommand(f'{self.IBPSAMedium}.specificIsobaricHeatCapacityVap_Tv({T},{v})')
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
        cv = self.cv_interp((T,v))
        if np.isnan(cv).any():
            cv = self.dymola.ExecuteCommand(f'{self.IBPSAMedium}.specificIsochoricHeatCapacityVap_Tv({T},{v})')
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
            pLiq = self.dymola.ExecuteCommand(f'{self.IBPSAMedium}.saturationPressure({TLiq})')
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
            pVap = self.dymola.ExecuteCommand(f'{self.IBPSAMedium}.saturationPressure({TVap})')
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
            hLiq = self.dymola.ExecuteCommand(f'{self.IBPSAMedium}.bubbleEnthalpy({self.IBPSAMedium}.setSat_T({TLiq}))')
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
            hVap = self.dymola.ExecuteCommand(f'{self.IBPSAMedium}.dewEnthalpy({self.IBPSAMedium}.setSat_T({TVap}))')
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
        pVap = self.pVap_interp((TVap,vVap))
        if np.isnan(pVap).any():
            pVap = self.dymola.ExecuteCommand(f'{self.IBPSAMedium}.pressureVap_Tv({TVap},{vVap})')
            print(f"pVap outside of range, (TVap,vVap): ({TVap:.2f}, {vVap:.0f}) → fallback pVap = {pVap:.6f}")
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
            v = self.dymola.ExecuteCommand(f'{self.IBPSAMedium}.specificVolumeVap_pT({p},{T})')
            print(f"v outside of range, (T,p): ({T:.2f}, {p:.0f}) → fallback v = {v:.6f}")
        else:
            v = float(v_interp)
        return v


class CoolPropRefrigerant(object):
    """ Class for the evaluation of properties of refrigerant from Coolprop.

    The refrigerant name must coincide with Coolprop nomenclature.
    """

    def __init__(self, ref_name, modelicaModelPath):
        self.ref_name = ref_name
        self.modelicaModelPath = modelicaModelPath
        # Critical temperature (K)
        self.TCri = PropsSI('Tcrit',self.ref_name)
        # Critical pressure (Pa)
        self.pCri = PropsSI('Pcrit',self.ref_name)
        # Critical volume (m3/kg)
        self.vCri = 1./PropsSI('rhocrit',self.ref_name)
        # Minimum temperature for property evaluation (K)
        self.T_min = PropsSI('Tmin',self.ref_name)

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
        cp = self.get_SpecificIsobaricHeatCapacity_vT(v, T)
        cv = self.get_SpecificIsochoricHeatCapacity_vT(v, T)
        k = cp / cv
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
        cp = PropsSI('Cpmass', 'D', 1./v, 'T', T, self.ref_name)
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
        cv = PropsSI('Cvmass', 'D', 1./v, 'T', T, self.ref_name)
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
        pLiq = PropsSI('P', 'Q', 0, 'T', TLiq, self.ref_name)
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
        pVap = PropsSI('P', 'Q', 1, 'T', TVap, self.ref_name)
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
        hLiq = PropsSI('H', 'Q', 0, 'T', TLiq, self.ref_name)
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
        hVap = PropsSI('H', 'Q', 1, 'T', TVap, self.ref_name)
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
        pVap = PropsSI('P', 'D', 1./vVap, 'T', TVap, self.ref_name)
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
        v = 1./PropsSI('D', 'P', p, 'T', T, self.ref_name)
        return v



class R410A(object):
    """ Class for the evaluation of properties of refrigerant R410A.

        Properties are based on commercial refrigerant Dupont Suva 410A.
    """

    def __init__(self):
        self.ref_name = 'R410A'
        self.modelicaModelPath = 'IBPSA.Media.Refrigerants.R410A'
        self.TCri = 345.25          # Critical temperature (K)
        self.pCri = 4926.1e3        # Critical pressure (Pa)
        self.vCri = 0.00205         # Critical volume (m3/kg)
        self._k = 1.273             # Isentropic exponent (-)
        # Minimum temperature for property evaluation (K)
        self.T_min = 173.15

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
        cp = self.get_SpecificIsobaricHeatCapacity_vT(v, T)
        cv = self.get_SpecificIsochoricHeatCapacity_vT(v, T)
        k = cp / cv
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
        R, A, B, C, b, k = self._martinHouCoefficients()
        cv = self.get_SpecificIsochoricHeatCapacity_vT(v, T)
        Tr = T / self.TCri

        dpdT = R / (v - b)
        dpdv = -R*T/(v - b)**2
        for i in range(len(A)):
            dpdT += (B[i] - k/self.TCri*C[i]*np.exp(-k*Tr)) / (v - b)**(i + 2)
            dpdv += -(float(i+2)*(A[i] + B[i]*T
                      + C[i]*np.exp(-k*Tr))/(v-b)**(i+3))
        cp = cv - T * dpdT**2 / dpdv
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
        R, A, B, C, b, k = self._martinHouCoefficients()
        cvo = self._get_IdealGasIsochoricHeatCapacity(T)
        Tr = T / self.TCri
        # Dimensionless value of cv
        intd2pdT2 = 0.
        for i in range(len(A)):
            intd2pdT2 += (k/self.TCri)**2 * C[i]*np.exp(-k*Tr) \
                / (float(i+1) * (v - b)**(i + 1))
        cv = cvo - T * intd2pdT2
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
        a = [-1.4376, -6.8715, -0.53623, -3.82642, -4.06875, -1.2333]
        x0 = 0.2086902
        x = (1.0 - TLiq/self.TCri) - x0
        pLiq = self.pCri \
            * np.exp(self.TCri/TLiq * np.polynomial.polynomial.polyval(x, a))
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
        a = [-1.440004, -6.865265, -0.5354309, -3.749023, -3.521484, -7.75]
        x0 = 0.2086902
        x = (1.0 - TVap/self.TCri) - x0
        pVap = self.pCri \
            * np.exp(self.TCri/TVap * np.polynomial.polynomial.polyval(x, a))
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
        a = [221.1749, -514.9668, -631.625, -262.2749, 1052.0, 1596.0]
        x0 = 0.5541498
        x = (1.0 - TLiq/self.TCri)**(1.0/3.0) - x0
        hLiq = 1e3 * np.polynomial.polynomial.polyval(x, a)
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
        a = [406.0598, -34.78156, 262.8079, 223.8549, -1162.627, 570.6635]
        x0 = 0.0
        x = (1.0 - TVap/self.TCri)**(1.0/3.0) - x0
        hVap = 1e3 * np.polynomial.polynomial.polyval(x, a)
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
        R, A, B, C, b, k = self._martinHouCoefficients()

        pVap = R*TVap/(vVap - b)
        for i in range(len(A)):
            pVap = pVap + (A[i] + B[i]*TVap
                           + C[i]*np.exp(-k*TVap/self.TCri)) \
                           / (vVap - b)**(i + 2.0)
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
        R = 114.55
        b = 4.355134e-4
        # Initial guess from the first term in the equation of state
        v = R*T/p + b
        dv = 1e99
        i = 0
        # Iterative evaluation of the specific volume
        while abs(dv)/v > tol and i < 1e3:
            i += 1
            # Error on pressure
            dp = p - self.get_VaporPressure(T, v)
            # Specific volume adjustment
            dv = dp / self._dpdv(T, v)
            v = v + dv
        return v

    def modelicaModelPath(self):
        """ Returns the full path to the refrigerant package in the Buildings
            library.

        :return: Full path to the refrigerant package in the IBPSA library.

        Usage: Type
           >>> ref = R410A()
           >>> ref.modelicaModelPath()
           'IBPSA.Media.Refrigerants.R410A'

        """
        return 'IBPSA.Media.Refrigerants.R410A'

    def _get_IdealGasIsobaricHeatCapacity(self, T):
        """ Evaluate the ideal gas specific isobaric heat capacity.

        :param T: Temperature of refrigerant vapor (K).

        :return: Ideal gas specific isobaric heat capacity (J/kg-K).

        """
        a = [2.676087e-1, 2.115353e-3, -9.848184e-7, 6.493781e-11]
        cpo = 1e3*np.polynomial.polynomial.polyval(T, a)
        return cpo

    def _get_IdealGasIsochoricHeatCapacity(self, T):
        """ Evaluate the ideal gas specific isochoric heat capacity.

        :param T: Temperature of refrigerant vapor (K).

        :return: Ideal gas specific isochoric heat capacity (J/kg-K).

        """
        R = 114.55
        cpo = self._get_IdealGasIsobaricHeatCapacity(T)
        cvo = cpo - R
        return cvo

    def _dpdv(self, TVap, vVap):
        """ Derivative for specific volume in the Martin-Hou equation of state.

        :param TVap: Temperature of refrigerant vapor (K).
        :param vVap: Specific volume of refrigerant vapor (m3/kg).

        :return: Derivative of pressure with respect to specific volume
                 (Pa-kg/m3).

        """
        R, A, B, C, b, k = self._martinHouCoefficients()

        dpdv = -R*TVap/(vVap - b)**2.0
        for i in range(len(A)):
            dpdv = dpdv - (2.0+i)*(A[i] + B[i]*TVap
                                + C[i]*np.exp(-k*TVap/self.TCri)) \
                                / (vVap - b)**(i + 3.0)
        return dpdv

    def _martinHouCoefficients(self):
        """ Return the coefficients to the Martin-Hou equation of state.

        :return: Coefficients to the Martin-Hou equation of state.

        """
        R = 114.55
        A = [-1.721781e2, 2.381558e-1, -4.329207e-4, -6.241072e-7]
        B = [1.646288e-1, -1.462803e-5, 0, 1.380469e-9]
        C = [-6.293665e3, 1.532461e1, 0, 1.604125e-4]
        b = 4.355134e-4
        k = 5.75
        return R, A, B, C, b, k
