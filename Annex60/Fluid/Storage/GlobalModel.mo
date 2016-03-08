within Annex60.Fluid.Storage;
model GlobalModel
//
  replaceable package Medium = Modelica.Media.Interfaces.PartialMedium
    "Medium of the storage model"                                                                     annotation (choicesAllMatching = true);
//
  parameter Modelica.SIunits.Length   height = 1.0
    "Height of the tank (= reference lenght)";
  parameter Modelica.SIunits.Diameter d = 1.0 "Internal diameter of the tank";
  parameter Real Ratio_HD = height/d;
  parameter Modelica.SIunits.Length   th_ins = 1.0 "Thickness insulation";
  parameter Modelica.SIunits.ThermalConductivity lam_ins
    "Thermal conductivity insulation";
  Modelica.SIunits.CoefficientOfHeatTransfer h_ext
    "External heat transfer coefficient";

//
  parameter Real U = 11.6 "Non-dimensional overall heat transfer coefficient ";
  parameter Real Ra = 5.986*10^12 "Rayleigh number";
  Modelica.SIunits.Velocity v_ref = alpha / height;
  Modelica.SIunits.ThermalDiffusivity alpha = 0.15*10^(-6)
    "Thermal diffusivity";
  Modelica.SIunits.ThermalConductivity k = 0.6 "Thermal diffusivity";
  Modelica.SIunits.CoefficientOfHeatTransfer U_overall = ((th_ins/lam_ins) + 1/(h_ext))^(-1)
    "Overall heat transfer coefficient (eq 5.8)";

//
  Modelica.SIunits.Temperature T_env = 273.15+20 "Ambient temperature";
  Modelica.SIunits.Temperature T1 = T_env + meanT_I*DeltaT
    "Fluid temperature I";
  Modelica.SIunits.Temperature T2 = T_env + meanT_II*DeltaT
    "Fluid temperature II";
  Modelica.SIunits.Temperature T3 = T_env + meanT_III*DeltaT
    "Fluid temperature III";
//
  Modelica.SIunits.Temperature T_0 = 273.15 + 60 "Initial temperature";
  Modelica.SIunits.TemperatureDifference DeltaT = T_0- T_env
    "Reference temperature difference";
//
  Real Nu_B =  4.3365*(t_dim^(-0.324))*(Ra^(-0.00549))*(U^(-0.0928))*(Ratio_HD^(-0.1412))
    "Nusselt number at the bottom wall of teh tank (eq 5.52)";
  Real Nu_T =  0.3417*(Ra^(0.2371))*(U^(0.1616))*(Ratio_HD^(0.3546))*Modelica.Math.exp((-5.9*(10^(-4)))*t_dim*(Ra^(0.2804))*(U^(0.9243))*(Ratio_HD^(0.1307)))
    "Nussel number at the top wall of the tank (eq 5.53)";
//
  Real Nu_I_z1 =  0.795493*(t_dim^(0.139))*(Ra^(0.2581))*(U^(0.149))*(Ratio_HD^(-0.011))
    "Nusselt number at temperature level I, zone I (eq 5.54)";
  Real Nu_I_z2 =  0.6756*(Ra^(0.2499))*(U^(0.051))*(Ratio_HD^(-0.0539))*Modelica.Math.exp((-7.56*(10^(-3)))*t_dim*(Ra^(0.2))*(U^(0.735))*(Ratio_HD^(0.25)))
    "Nusselt number at temperature level I, zone II (eq 5.54)";
  Real Nu_I =     min(Nu_I_z1,Nu_I_z2)
    "Nusselt number at temperature level I (eq 5.54)";
  Real Nu_II =    min(Nu_II_z1,Nu_II_z2)
    "Nusselt number at temperature level II (eq 5.55)";
  Real Nu_II_z1 = 0.466*(t_dim^(0.0567))*(Ra^(0.2384))*(U^(0.1914))*(Ratio_HD^(0.0412))
    "Nusselt number at temperature level II, zone I (eq 5.55)";
  Real Nu_II_z2 = 0.4168*(Ra^(0.2416))*(U^(0.0476))*(Ratio_HD^(0.039))*Modelica.Math.exp((-3.08*(10^(-4)))*t_dim*(Ra^(0.3017))*(U^(0.6104))*(Ratio_HD^(0.3132)))
    "Nusselt number at temperature level II, zone II (eq 5.55)";
  Real Nu_III =   0.1356*(Ra^(0.269))*(U^(0.2041))*(Ratio_HD^(-0.0127))*Modelica.Math.exp((-4.09*10^(-4))*t_dim*(Ra^(0.294))*(U^(0.906))*(Ratio_HD^(0.1827)))
    "Nusselt number at temperature level III (eq 5.56)";
  //
  Modelica.SIunits.CoefficientOfHeatTransfer h_B =   Nu_B*k/height
    "Heat transfer coefficient Bottom (eq 5.63)";
  Modelica.SIunits.CoefficientOfHeatTransfer h_T =   Nu_T*k/height
    "Heat transfer coefficient Top (eq 5.63)";
  Modelica.SIunits.CoefficientOfHeatTransfer h_I =   Nu_I*k/height
    "Heat transfer coefficient Wall I (eq 5.63)";
  Modelica.SIunits.CoefficientOfHeatTransfer h_II =  Nu_II*k/height
    "Heat transfer coefficient Wall II (eq 5.63)";
  Modelica.SIunits.CoefficientOfHeatTransfer h_III = Nu_III*k/height
    "Heat transfer coefficient Wall III (eq 5.63)";
  //
  Modelica.SIunits.Area S_T =   Modelica.Constants.pi*(d/2)^2 "Area Top";
  Modelica.SIunits.Area S_B =   S_T "Area Bottom";
  Modelica.SIunits.Area S_I =   2*Modelica.Constants.pi*(d/2)*height/4 "Area I";
  Modelica.SIunits.Area S_II =  S_I * 2 "Area II";
  Modelica.SIunits.Area S_III = S_I "Area III";
  //
  Modelica.SIunits.Heat Qloss_B "Heat losses Bottom";
  Modelica.SIunits.Heat Qloss_T "Heat losses Top";
  Modelica.SIunits.Heat Qloss_I "Heat losses I";
  Modelica.SIunits.Heat Qloss_II "Heat losses II";
  Modelica.SIunits.Heat Qloss_III "Heat losses III";
  Modelica.SIunits.Heat Qloss_wall "Heat losses Vertical Wall";
//
  Real t_dim = time * v_ref / height "Non-dimensional time";
//
  Real meanT_I =    Modelica.Math.exp(-8.008*t_dim*(Ra^(-0.00863))*(U^(0.9997))*(Ratio_HD^(0.8064)))
    "Mean fluid temperature at level I (eq 5.60)";
  Real meanT_II =   Modelica.Math.exp(-7.7299*t_dim*(Ra^(-0.01))*(U^(0.9488))*(Ratio_HD^(0.8203)))
    "Mean fluid temperature at level II (eq 5.61)";
  Real meanT_III = Modelica.Math.exp(-6.8239*t_dim*(Ra^(-0.00591))*(U^(0.9387))*(Ratio_HD^(0.8137)))
    "Mean fluid temperature at level III (eq 5.62)";
//
  Real x_fig_516_I =   t_dim*(Ra^(-0.00863))*(U^(0.9997))*(Ratio_HD^(0.8064));
  Real x_fig_516_II =  t_dim*(Ra^(-0.01))*(U^(0.9488))*(Ratio_HD^(0.8203));
  Real x_fig_516_III = t_dim*(Ra^(-0.00591))*(U^(0.9387))*(Ratio_HD^(0.8137));

equation
  der(Qloss_B)   = U_overall*h_B/(U_overall+h_B)*(T1-T_env)*S_B;
  der(Qloss_T)   = U_overall*h_T/(U_overall+h_T)*(T3-T_env)*S_T;
  der(Qloss_I)   = U_overall*h_I/(U_overall+h_I)*(T1-T_env)*S_I;
  der(Qloss_II)  = U_overall*h_II/(U_overall+h_II)*(T2-T_env)*S_II;
  der(Qloss_III) = U_overall*h_III/(U_overall+h_III)*(T3-T_env)*S_III;
  der(Qloss_wall) = der(Qloss_I) + der(Qloss_II) + der(Qloss_III);

  annotation (Documentation(info="<html>
<p>
Model that characterise the transient behaviour of the fluid inside a cylindrical storage tank during a cooling phase (nor chager neither uncharge phase).</p>
<p>A storage tank model was studied by means of detailed computational fluid dynamics simulations. The results were used to correlate a the Nusselt number and the transient mean fluid temperature.</p>

<p>Important aspects of the simulations are that all simulations considered the initial condition, of the tank being homogenously at a specific temperature and a constant ambient temperature of 20 deg. </p>
<p>Furthermore, the following hyphotesis are considered</p>
<ul>
<li>Thermophysical properties have been taken constant and have been evaluated at the mean temperature between the ambient and initial fluid temperature</li>
<li>Energy storage capacity of solid walls has been neglected</li>
</ul>

<h4>References</h4>
<p>Rodríguez Pérez, Ivette (2006) <a href=\"http://www.tdx.cat/handle/10803/6689/\">Unsteady laminar convection in cylindrical domains: numerical studies and application to solar water storage tanks</a> </p>
</html>"));
end GlobalModel;
