within Annex60.Fluid.Storage.BaseClasses.StratificationEfficiency;
model MIXnumber

 extends Annex60.Fluid.Interfaces.LumpedVolumeDeclarations(final energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
   final massDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
   final mSenFac=1);

final parameter Medium.ThermodynamicState state_start = Medium.setState_pTX(T=T_start,p=p_start,X=X_start[1:Medium.nXi])
    "Medium state at start values";
final parameter Modelica.SIunits.Density rho_start=Medium.density(state=state_start)
    "Density, used to compute start and guess values";
final parameter Modelica.SIunits.SpecificHeatCapacity cp_start=Medium.specificHeatCapacityCp(state=state_start)
    "Fluid heat capacity evaluated at T_ref";

  Real Me_str "Momentum of Energy Stratified";
  Real Me_exp "Momentum of Energy experiment";
  Real Me_mix "Momentum of Energy mixed";

  Real MIX "MIX number ";

  Modelica.SIunits.Energy E_str_b "Energy stratified";
  Modelica.SIunits.Energy E_str_t "Energy stratified";
  Modelica.SIunits.Energy E_exp[n] "Energy experiment";
  Modelica.SIunits.Energy E_mix "Energy mixed";
  Modelica.SIunits.Energy E_tank "tank current Energy";

  Modelica.SIunits.Temperature T_str "Temperature stratified";
  Modelica.SIunits.Temperature T_mix "Temperature mixed";

  Modelica.SIunits.Length y[n]
    "Distance from the Bottom of teh tank to the mid point of the volume layer i";
  Modelica.SIunits.Length y_b
    "Distance from the Bottom of the tank to the mid point of bottom volume of the stratified tank";
  Modelica.SIunits.Length y_t
    "Distance from the Bottom of the tank to the mid point of the top volume of the stratified tank";
  parameter Modelica.SIunits.Length H "Height of the tank";
  parameter Modelica.SIunits.Volume V_tank "Volume of the tank";
  Modelica.SIunits.Volume   V[n] "Volume of each layer";
  parameter Integer n "number of Volumes";

//Detect Charge/uncharge period.
Boolean charge "In charge phase...";
//

Modelica.SIunits.Volume V_in "Introduced Volume";

  Modelica.Blocks.Interfaces.RealInput T_exp[n] "Temperature experiment"
    annotation (Placement(transformation(extent={{-120,50},{-80,90}})));
  Modelica.Blocks.Interfaces.RealInput m_in "Temperature experiment"
    annotation (Placement(transformation(extent={{-120,10},{-80,50}})));
equation
  for i in 1:n loop
    y[i] = (H/n)*(i-0.5);
    V[i] = V_tank/n;
    E_exp[i] = (cp_start*rho_start*V[i]*T_exp[i]);
  end for;
  der(V_in) = m_in/rho_start;
  // Energy
  E_tank  = cp_start*rho_start*V*T_exp;
  E_str_b = cp_start*rho_start*(V_tank-V_in)*T_start;
  E_str_t = E_tank - E_str_b;
  E_mix = cp_start*rho_start*V_tank*T_mix;
  // Temperature
  T_mix = sum(T_exp / n);
  T_str = if V_in <= 0 then 0 else E_str_t/(cp_start*rho_start*V_in);
  // Calculation Momentum
  y_b = (V_tank-V_in)/V_tank*H*0.5;
  y_t = H-(V_in)/V_tank*H*0.5;
  //
  Me_str = y_b*E_str_b + y_t*E_str_t;
  Me_exp = y*E_exp;
  Me_mix = 0.5*H*E_mix;
  //

  if m_in <= 0 then
    charge = false;
  else
    charge = true;
  end if;

  MIX = if Me_str > Me_exp then ((Me_str-Me_exp)/(Me_str-Me_mix)) else 0;

 annotation (Documentation(info="<html>

<p>The mixing number is defined as the ratio of two Momentum of energy diferences </p>
<p>
...
</p>

<p>
<code>MIX = (M_str - M_exp) / (M_str - M_mix)</code>
</p>

<p>The momentum of energy is defined as the sum of the product of the distance from the bottom to each layer and the energy of each layer</p>

<p>
<code>M =sum(y_i * E_i)</code>
</p>

<p>
The temperature of the fully mixed tank is calculated as the measured weighted average temperature
</p>

<p>[The temperature in the perfectly stratified tank consists of a high temperature in the upper part of the tank and a low
temperature in the lower part of the tank. In the charging case, the low temperature equals the start temperature of
the tank. The lower part of the tank has a volume equal to the total water volume in the tank minus the water volume
which has entered the tank during the test. Based on the measured temperatures the temperature in the upper part of the tank with a volume equal to the water volume which has entered the tank during the test is determined in such a way that the energy of the perfectly stratified tank is equal to the measured energy in the tank.]
</p>


<h4>References</h4>
<p>Andersen, E., Furbo, S., Fan J., 2007. Multilayer fabric stratification pipes for solar tanks. Solar Energy 81, 1219-1226 </p>


</html>"), Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},
            {100,100}}), graphics));
end MIXnumber;
