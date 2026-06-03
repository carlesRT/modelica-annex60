within IBPSA.Media.Refrigerants;
package R410a_IIR_P1_48_T233_340_formula "Refrigerant R410a. Source: AixLib"
  extends Modelica.Icons.MaterialPropertiesPackage;
  extends AixLib.Media.Refrigerants.R410A_HEoS.R410a_IIR_P1_48_T233_340_Formula;

  final constant Modelica.Units.SI.Temperature T_min= 173.15
  "Minimum temperature for correlated properties";
  final constant Modelica.Units.SI.Temperature T_max= 273.15 + 120
    "Maximal temperature for correlated properties";
  constant Modelica.Media.Interfaces.PartialTwoPhaseMedium.FluidConstants[1] fluidConstants = refrigerantConstants;

end R410a_IIR_P1_48_T233_340_formula;
