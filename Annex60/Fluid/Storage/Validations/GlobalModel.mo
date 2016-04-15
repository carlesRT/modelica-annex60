within Annex60.Fluid.Storage.Validations;
model GlobalModel
//
 extends Annex60.Fluid.Interfaces.LumpedVolumeDeclarations(
   final energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
   final massDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
   final mSenFac=1);

//protected
final parameter Medium.ThermodynamicState state_start = Medium.setState_pTX(
      T=T_ref,
      p=p_start,
      X=X_start[1:Medium.nXi]) "Medium state at start values";
final parameter Modelica.SIunits.ThermalConductivity k=Medium.thermalConductivity(
   state=state_start) "Fluid thermal conductivity evaluated at T_ref";
final parameter Modelica.SIunits.Density rho_start=Medium.density(
   state=state_start) "Density, used to compute start and guess values";
final parameter Modelica.SIunits.SpecificHeatCapacity cp_start=Medium.specificHeatCapacityCp(
   state=state_start) "Fluid heat capacity evaluated at T_ref";
final parameter Modelica.SIunits.LinearExpansionCoefficient Beta_start=Medium.isobaricExpansionCoefficient(
   state=state_start) "Fluid Isobaric expansion coefficient evaluated at T_ref";
final parameter Modelica.SIunits.DynamicViscosity mu_start=Medium.dynamicViscosity(
   state=state_start) "Fluid dynamic viscosity evaluated at T_ref";
final parameter Modelica.SIunits.KinematicViscosity eta_start = mu_start/rho_start;
parameter Modelica.SIunits.ThermalDiffusivity alpha = k/rho_start/cp_start
    "Fluid thermal diffusivity evaluated at T_ref";

public
    parameter Boolean use_Ra_exp = false
    "Set to true to define explicitely a value for the Rayleigh number";
    parameter Real Ra_exp = 7.132*10^11 "Explicit value of the Rayleigh number"
                                                                                annotation(Dialog(enable = use_Ra_exp));
    final parameter Real Ra = if use_Ra_exp then Ra_exp else Modelica.Constants.g_n*Beta_start/eta_start/alpha*(T_start-293.15)*height^(3)
    "Rayleigh number";

//
  parameter Modelica.SIunits.Volume V = 0.3 "Storage tank volume";
  parameter Real Ratio_HD = height/d "Ratio height diameter";
  parameter Modelica.SIunits.Length height = Ratio_HD*d
    "Height of the tank (= reference lenght)" annotation(Dialog(enable = false));
  parameter Modelica.SIunits.Diameter d = (V/Ratio_HD/Modelica.Constants.pi*4)^(1/3)
    "Internal diameter of the tank"                                                                                  annotation(Dialog(enable = false));
  parameter Modelica.SIunits.Length   th_ins = 0.01 "Thickness insulation";
  parameter Modelica.SIunits.ThermalConductivity lam_ins = 0.025
    "Thermal conductivity insulation";
  parameter Modelica.SIunits.ThermalConductivity lam_w = 16
    "Thermal conductivity wall material";
  parameter Modelica.SIunits.CoefficientOfHeatTransfer h_ext = 2
    "External heat transfer coefficient";
    //
  parameter Boolean use_U_exp = false
    "set to true to define explicitely a value for the Non-dimensional overall HTC";
  parameter Real U_exp = 11.6
    "Explicit value of the non-dimensional overall heat transfer coefficient "                           annotation(Dialog(enable = use_U_exp));
  Real U = if use_U_exp then U_exp else U_H*height/k
    "Check non-dimensional overall heat transfer coefficient ";

  parameter Modelica.SIunits.Temperature T_ref = (T_start + 273.15+20)/2
    "Reference temperature";
//
  Modelica.SIunits.Velocity v_ref = alpha / height "Reference velocity";

  parameter Modelica.SIunits.CoefficientOfHeatTransfer U_B = ((3/1000)/lam_w + (th_ins/lam_ins) + 1/(h_ext))^(-1)
    "Overall heat transfer coefficient for bottom and top of the tank (eq 5.8/5.9)";
  parameter Modelica.SIunits.CoefficientOfHeatTransfer U_H = ((0.5*d/lam_w)*log(r_t/(0.5*d)) + (0.5*d/lam_ins)*log(r_ins/(r_t)) + (0.5*d/r_ins)*1/(h_ext))^(-1)
    "Overall heat transfer coefficient fot tank wall (eq 5.7)";

protected
parameter Modelica.SIunits.Radius r_t = 0.5*d+3/1000;
parameter Modelica.SIunits.Radius r_ins = r_t+th_ins;
//
public
  Modelica.SIunits.Temperature T_env = 273.15+20 "Ambient temperature";
  Modelica.SIunits.Temperature T1 = T_env + meanT_I*DeltaT
    "Fluid temperature zone I";
  Modelica.SIunits.Temperature T2 = T_env + meanT_II*DeltaT
    "Fluid temperature zone II";
  Modelica.SIunits.Temperature T3 = T_env + meanT_III*DeltaT
    "Fluid temperature zone III";
  Modelica.SIunits.TemperatureDifference DeltaT = T_start- T_env
    "Reference temperature difference";
//
  Real Nu_B =  if t_dim <= 0 then 0 else 4.3365*(t_dim^(-0.324))*(Ra^(-0.00549))*(U^(-0.0928))*(Ratio_HD^(-0.1412))
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
  Modelica.SIunits.CoefficientOfHeatTransfer h_B =   max(Nu_B*k/height,0.000000000000001)
    "Heat transfer coefficient between Bottom and fluid (eq 5.63)";
  Modelica.SIunits.CoefficientOfHeatTransfer h_T =   max(Nu_T*k/height,0.000000000000001)
    "Heat transfer coefficient between Top wall and fluid (eq 5.63)";
  Modelica.SIunits.CoefficientOfHeatTransfer h_I =   max(Nu_I*k/height,0.000000000000001)
    "Heat transfer coefficient between Wall I and fluid (eq 5.63)";
  Modelica.SIunits.CoefficientOfHeatTransfer h_II =  max(Nu_II*k/height,0.000000000000001)
    "Heat transfer coefficient between Wall II and fluid (eq 5.63)";
  Modelica.SIunits.CoefficientOfHeatTransfer h_III = max(Nu_III*k/height,0.000000000000001)
    "Heat transfer coefficient between Wall III and fluid (eq 5.63)";
//
  Modelica.SIunits.Area S_T =     Modelica.Constants.pi*(d/2)^2 "Area top wall";
  Modelica.SIunits.Area S_B =     S_T "Area bottom wall";
  Modelica.SIunits.Area S_I =     2*Modelica.Constants.pi*(d/2)*height/4
    "Area I wall";
  Modelica.SIunits.Area S_II =    S_I * 2 "Area II wall";
  Modelica.SIunits.Area S_III =   S_I "Area III wall";
//
  Modelica.SIunits.Heat Qloss_B "Heat losses trough bottom wall";
  Modelica.SIunits.Heat Qloss_T "Heat losses trough top wall";
  Modelica.SIunits.Heat Qloss_I "Heat losses trough I wall";
  Modelica.SIunits.Heat Qloss_II "Heat losses trough II wall";
  Modelica.SIunits.Heat Qloss_III "Heat losses trough III wall";
  Modelica.SIunits.Heat Qloss_wall "Heat losses Vertical Wall";
  Modelica.SIunits.Heat Qloss "Total heat losses";
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
  // Check validity of some parameters:
  assert(V <= 0.4 and V >= 0.1, "Volume out of validated range");
  assert(Ratio_HD <= 3.45 and Ratio_HD >= 1, "Ratio height-diameter out of validated range");
  assert(T_start <= 273.15+70 and T_start >= 273.15+40, "Initial temperature out of validated range");

  //

  der(Qloss_B)   = U_H*h_B/(U_H+h_B)*(T1-T_env)*S_B;
  der(Qloss_T)   = U_H*h_T/(U_H+h_T)*(T3-T_env)*S_T;
  der(Qloss_I)   = U_H*h_I/(U_H+h_I)*(T1-T_env)*S_I;
  der(Qloss_II)  = U_H*h_II/(U_H+h_II)*(T2-T_env)*S_II;
  der(Qloss_III) = U_H*h_III/(U_H+h_III)*(T3-T_env)*S_III;
  der(Qloss_wall) = der(Qloss_I) + der(Qloss_II) + der(Qloss_III);
  der(Qloss) = der(Qloss_wall) + der(Qloss_B) + der(Qloss_T);
  annotation (Documentation(info="<html>
<p>
Model that characterise the transient behaviour of the fluid inside a cylindrical storage tank during a cooling phase (nor chage neither uncharge phase).</p>
<p>A storage tank model was studied by means of detailed computational fluid dynamics simulations. The results were used to correlate the Nusselt number and the transient mean fluid temperature.</p>

<h4>Global model</h4>
<p>
The volume of the water storage tank is divided in three zones: bottom, middle and top, thus the storage tank is described by three temperatures.</p>
<p>The global model includes Nusselt number correlations: The three temperatures are used to calculate five different Nusselt numbers (Bottom, Wall bottom volume, Wall mid volume, wall top volume and top) used to calculate the heat losses of the tank. </p>


<h4>Experiment</h4>
<p>The performed study was focus on the solar storage tanks used in domestic systems. Thus typical values for tank size, aspect ratio, insualtion, etc where used. </p>
<ul> 
<li>Volumes between 0.1 and 0.4 m3 </li>
<li>Aspect ratiod height/diameter between 1 and 3.45 </li> 
<li>Thank made of stainless stell with a wall thickness = 3 mm</li>
<li>Insulation thickness between 0 and 0.04 mm </li> 
<li>Heat transfer coefficient between external tank wall and the ambient equal to 2 and 10 W/m2K </li>
</ul>
<p>Important aspects of the simulations are that all simulations considered the initial condition, of the tank being homogenously at a specific temperature in the rage between 40 and 70 deg and a constant ambient temperature of 20 deg. </p>
<p>Furthermore, the following hyphotesis are considered</p>
<ul>
<li>Thermophysical properties have been taken constant and have been evaluated at the mean temperature between the ambient and initial fluid temperature</li>
<li>Energy storage capacity of solid walls has been neglected</li>
<li>It is assumed that the overall heat transfer coefficiet between the inner wall of the tank and ambient temperature are nearly the same, eqs 5.7, 5.8 and 5.9</li>
</ul>

<h4>Considerations</h4>
<p>Some Information, such as thermal conductivity of the insulation material and wall are missing, with the equations and other parameters information is theoretically possible to obtain this missing information. </p>
<p>
For instance, case v3 (see table 5.2 in pag. 143 of the reference) using eqs 5.8 and 5.20 yields thermal conductivity for the wall of 0.012 W/mK. This values is clearly too low for a stainless steel. (Trying to find out what is wrong...) 
</p>

<h4>References</h4>
<p>Rodríguez Pérez, Ivette (2006) <a href=\"http://www.tdx.cat/handle/10803/6689/\">Unsteady laminar convection in cylindrical domains: numerical studies and application to solar water storage tanks</a> </p>
</html>"));
end GlobalModel;
