within IBPSA.Media.Refrigerants;
package R1234yf_ph "Refrigerant R1234yf. Source: ThermofluidStream library"
  extends Modelica.Icons.MaterialPropertiesPackage;
  extends ThermofluidStream.Media.XRGMedia.R1234yf_ph;

  final constant Modelica.Units.SI.Temperature T_min= r1234yfLimits[1].TMIN
  "Minimum temperature for correlated properties";
  final constant Modelica.Units.SI.Temperature T_max= r1234yfLimits[1].TMAX
    "Maximal temperature for correlated properties";
  constant Modelica.Media.Interfaces.PartialTwoPhaseMedium.FluidLimits[1] fluidLimits = r1234yfLimits;
  constant Modelica.Media.Interfaces.PartialTwoPhaseMedium.FluidConstants[1] fluidConstants = r1234yfConstants;

end R1234yf_ph;
