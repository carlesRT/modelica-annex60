within IBPSA.Media.Refrigerants.R410A;
function saturationPressure
  "Return saturation pressure"
  extends Modelica.Icons.Function;
  input Modelica.Units.SI.Temperature T "Temperature";
  output Modelica.Units.SI.AbsolutePressure p "Saturation pressure";

algorithm
  p := pressureSatVap_T(T);

  annotation(smoothOrder=1, Documentation(info="<html>
<p>It calls <a href=\"Modelica://IBPSA.Media.Refrigerants.R410A.pressureSatVap_T\">pressureSatVap_T</a>   . 
</p>
</html>"));

end saturationPressure;
