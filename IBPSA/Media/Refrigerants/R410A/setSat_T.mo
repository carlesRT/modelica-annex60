within IBPSA.Media.Refrigerants.R410A;
function setSat_T
  "Return saturation property record from temperature"
  extends Modelica.Icons.Function;
  input Modelica.Units.SI.Temperature T "Temperature";
  output SaturationProperties sat "Saturation property record";
algorithm
  sat.Tsat := T;
  sat.psat := saturationPressure(T);
end setSat_T;
