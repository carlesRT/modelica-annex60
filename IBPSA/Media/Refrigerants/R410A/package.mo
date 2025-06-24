within IBPSA.Media.Refrigerants;
package R410A "Refrigerant R410A"
  extends Modelica.Icons.VariantsPackage;

  constant Modelica.Media.Interfaces.PartialTwoPhaseMedium.FluidConstants[1]
    fluidConstants(
     each chemicalFormula = "50% CH2F2 + 50% CHF2CF3",
     each structureFormula = "50% CH2F2 + 50% CHF2CF3",
     each casRegistryNumber = "75-10-5 + 354-33-6",
     each iupacName = "Mixture of difluoromethane and pentafluoroethane",
     each molarMass = 0.07258,
     each criticalTemperature = TCri,
     each criticalPressure = pCri,
     each criticalMolarVolume = 0.07258/488.9,
     each normalBoilingPoint = 221.71,
     each triplePointTemperature = 200,
     each meltingPoint = 118.15,
     each acentricFactor = 0.296,
     each dipoleMoment = 1.99,
     each triplePointPressure = 29160) "Thermodynamic constants for R410a";

  record SaturationProperties
  "Saturation properties of two phase medium"
  extends Modelica.Icons.Record;
  Modelica.Units.SI.AbsolutePressure psat "Saturation pressure";
  Modelica.Units.SI.Temperature Tsat "Saturation temperature";
  end SaturationProperties;

function density_pT "Return density from p and T"
  extends Modelica.Icons.Function;
  input Modelica.Units.SI.AbsolutePressure p "Pressure";
  input Modelica.Units.SI.Temperature T "Temperature";
  output Modelica.Units.SI.Density d "Density";
algorithm
  d := 1/specificVolumeVap_pT(p,T);
    annotation (Documentation(info="<html>

<p>Density  <code>d</code> defined as the inverse of <code>v</code>, i.e. <code>d=1/v</code>.</p>
<p>It calls <a href=\"Modelica://IBPSA.Media.Refrigerants.R410A.specificVolumeVap_pT\">specificVolumeVap_pT</a> to obtain <code>v</code>.</p>

</html>"));
end density_pT;

function isentropicExponent
  "Return isentropic exponent"
  extends Modelica.Icons.Function;
    input ThermodynamicState state "Thermodynamic state record";
    output Modelica.Units.SI.IsentropicExponent gamma "Isentropic exponent";

algorithm
  gamma := isentropicExponentVap_Tv(state.T,1/state.d);
    annotation (Documentation(info="<html>
<p>It calls <a href=\"Modelica://IBPSA.Media.Refrigerants.R410A.isentropicExponentVap_Tv\">isentropicExponentVap_Tv</a>   . 
</p>
</html>"));
end isentropicExponent;
//setState_dT

function setState_dT "Return thermodynamic state from d and T"
  extends Modelica.Icons.Function;
  input Modelica.Units.SI.Density d "Density";
  input Modelica.Units.SI.Temperature T "Temperature";
  output ThermodynamicState state "Thermodynamic state record";
algorithm
  state := ThermodynamicState(
             T = T,
             d = d,
             p = 100000,
             h = 100000);
    annotation (Documentation(info="<html>
<p>Set Thermodynamic state. Use of dummy values for pressure and specific enthalpy.</p>
</html>"));
end setState_dT;
final constant Modelica.Units.SI.SpecificEntropy R=114.55
  "Gas constant for use in Martin-Hou equation of state";

final constant Modelica.Units.SI.Temperature TCri=345.25 "Critical temperature";

final constant Modelica.Units.SI.Temperature T_min=173.15
  "Minimum temperature for correlated properties";

final constant Modelica.Units.SI.AbsolutePressure pCri=4926.1e3
  "Critical pressure";

protected
  final constant Real A[:] = {-1.721781e2, 2.381558e-1, -4.329207e-4, -6.241072e-7}
    "Coefficients A for Martin-Hou equation of state";

  final constant Real B[:] = {1.646288e-1, -1.462803e-5, 0, 1.380469e-9}
    "Coefficients B for Martin-Hou equation of state";

  final constant Real C[:] = {-6.293665e3, 1.532461e1, 0, 1.604125e-4}
    "Coefficients C for Martin-Hou equation of state";

  final constant Real b = 4.355134e-4
    "Coefficient b for Martin-Hou equation of state";

  final constant Real k = 5.75
    "Coefficient K for Martin-Hou equation of state";

annotation (preferredView="info",Documentation(info="<HTML>
<p>
This package contains function definitions for thermodynamic properties of R410A
based on data for commercial refrigerant Dupont Suva 410A. The methodology used
to evaluate the isentropic exponent is taken from de Monte (2002).
</p>
<h4>References</h4>
<p>
F. de Monte. (2002).
Calculation of thermodynamic properties of R407C and
R410A by the Martin-Hou equation of state, part I:
theoretical development.
<i>
International Journal of Refrigeration.
</i>
25. 306-313.
</p>
<p>
Thermodynamic properties of DuPont Suva 410A:
<a href=\"https://www.chemours.com/Refrigerants/en_US/assets/downloads/h64423_Suva410A_thermo_prop_si.pdf\">
https://www.chemours.com/Refrigerants/en_US/assets/downloads/h64423_Suva410A_thermo_prop_si.pdf
</a>
</p>
</html>", revisions="<html>
<ul>
<li>
November 9, 2020, by Michael Wetter:<br/>
Moved constants that are common to functions to the scope of the package.<br/>
This is for
<a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/1414\">#1414</a>.
</li>
<li>
October 17, 2016, by Massimo Cimmino:<br/>
First implementation.
</li>
</ul>
</html>"));

end R410A;
