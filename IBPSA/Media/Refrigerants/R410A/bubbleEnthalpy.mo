within IBPSA.Media.Refrigerants.R410A;
function bubbleEnthalpy
  "Return bubble point specific enthalpy"
  extends Modelica.Icons.Function;
  input SaturationProperties sat "Saturation property record";
  output Modelica.Units.SI.SpecificEnthalpy hl "Boiling curve specific enthalpy";

algorithm
  hl := enthalpySatLiq_T(sat.Tsat);

  annotation (smoothOrder=1, Documentation(info="<html>
<p>It calls <a href=\"Modelica://IBPSA.Media.Refrigerants.R410A.enthalpySatLiq_T\">enthalpySatLiq_T</a>   . 
</p>
</html>"));
end bubbleEnthalpy;
