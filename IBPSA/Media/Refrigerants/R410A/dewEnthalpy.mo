within IBPSA.Media.Refrigerants.R410A;
function dewEnthalpy
  "Return dew point specific enthalpy"
  extends Modelica.Icons.Function;
  input SaturationProperties sat "Saturation property record";
  output Modelica.Units.SI.SpecificEnthalpy hv "Dew curve specific enthalpy";

algorithm
  hv := enthalpySatVap_T(sat.Tsat);

annotation (smoothOrder=1, Documentation(info="<html>
<p>It calls <a href=\"Modelica://IBPSA.Media.Refrigerants.R410A.enthalpySatVap_T\">enthalpySatVap_T</a>   . 
</p>
</html>"));
end dewEnthalpy;
