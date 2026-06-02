# -*- coding: utf-8 -*-
"""
Created on Wed May  6 12:37:03 2026

@author: Sim1
"""

from dymola.dymola_interface import DymolaInterface
import numpy as np
import time as tm

class ModelicaPropRefrigerantMap(object):
    """ Class for the generation of maps of properties of refrigerant from a Modelica library.
    
    """

    def __init__(self, ref_name, ModelicaModelPath, map_libraries):
        from scipy.interpolate import interp1d
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
        get_SaturatedVaporPressure_map = get_SaturatedLiquidPressure_map
        self._pVapsat_interp = interp1d(
            get_SaturatedVaporPressure_map["T"],
            get_SaturatedVaporPressure_map["y"],
            kind='linear',
            bounds_error=True
        )
    
        tic = tm.time()
        deltaT_reduced = 0.1
        T_min_used = 273.15 - 1
        T_max_used = 318.15 + 1  #self.TCri
        T_range_2D = np.round(np.arange(T_min_used, T_max_used, deltaT_reduced),4)
        v_range = np.arange(0.001, 0.5, 0.002)
        d_range = np.sort(1/v_range)
        d_slice_str = "{" + ",".join(f"{x:.8g}" for x in d_range) + "}"
        nT = len(T_range_2D)
        nv = len(v_range)
        
        get_SpecificIsobaricHeatCapacity_vT_2Dmap = np.zeros((nT, nv))
        get_SpecificIsochoricHeatCapacity_vT_2Dmap = np.zeros((nT, nv))
        get_IsentropicExponent_vT_2Dmap = np.zeros((nT, nv))
        get_VaporPressure_2Dmap = np.zeros((nT, nv))
        
        print("Start for loop to generate 2D ref data, length... ", len(T_range_2D))
        for j, T_ in enumerate(T_range_2D):
            state_expr = f"{self.Medium}.setState_dTX({d_slice_str},{T_})"
            cp_slice = np.array(self.dymola.ExecuteCommand(f'{self.Medium}.specificHeatCapacityCp({state_expr})'))
            get_SpecificIsobaricHeatCapacity_vT_2Dmap[j,:] = cp_slice 
            cv_slice = np.array(self.dymola.ExecuteCommand(f'{self.Medium}.specificHeatCapacityCv({state_expr})'))
            get_SpecificIsochoricHeatCapacity_vT_2Dmap[j,:] = cv_slice
            get_IsentropicExponent_vT_2Dmap[j,:] = cp_slice / cv_slice
            get_VaporPressure_2Dmap[j,:] = np.array(self.dymola.ExecuteCommand(f'{self.Medium}.pressure({state_expr})'))
        
        print("Loop to generate 2D ref data has finished")
        np.savez_compressed("refmaps/"+
        ModelicaModelPath+"_maps.npz",
        cp=get_SpecificIsobaricHeatCapacity_vT_2Dmap,
        cv=get_SpecificIsochoricHeatCapacity_vT_2Dmap,
        kappa=get_IsentropicExponent_vT_2Dmap,
        pVap=get_VaporPressure_2Dmap,
        T_range_2D=T_range_2D,
        d_range=d_range)

        intermediate_toc = tm.time()  - tic      
        print("2D maps ready: ", intermediate_toc)
        
        tic = tm.time()
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
                    v_val = 1/self.dymola.ExecuteCommand(f'{self.Medium}.density({self.Medium}.setState_pTX({p_},{T_}))')
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
                
        np.savez_compressed("refmaps/"+
        ModelicaModelPath+"_v_map.npz",
        T = np.array(T_all),
        p = np.array(p_all),
        v = np.array(v_all)
        )  
        toc = tm.time() - tic
        print("Specific volume data ready, time =  ", toc, " s")
        