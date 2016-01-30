within Annex60.Fluid.HeatPumps;
model Carnot_y
  "Reversible heat pump with performance curve adjusted based on Carnot efficiency"
 extends Annex60.Fluid.Chillers.BaseClasses.PartialCarnot_y(
  effInpEva=Annex60.Fluid.Types.EfficiencyInput.port_a,
  effInpCon=Annex60.Fluid.Types.EfficiencyInput.port_b,
  final COP_is_for_cooling = false);

  annotation (
defaultComponentName="heaPum",
Documentation(info="<html>
<p>
This is model of a heat pump whose coefficient of performance COP changes
with temperatures in the same way as the Carnot efficiency changes.
The input signal <i>y</i> is the control signal for the compressor.
</p>
<p>
The COP at the nominal conditions can be specified by a parameter, or
it can be computed by the model based on the Carnot effectiveness, in which
case
</p>
<p align=\"center\" style=\"font-style:italic;\">
  COP<sub>0</sub> = &eta;<sub>car</sub> COP<sub>car</sub>
= &eta;<sub>car</sub> T<sub>con</sub> &frasl; (T<sub>con</sub>-T<sub>eva</sub>),
</p>
<p>
where <i>T<sub>eva</sub></i> is the evaporator temperature
and <i>T<sub>con</sub></i> is the condenser temperature.
On the <code>Advanced</code> tab, a user can specify the temperatures that
will be used as the evaporator (or condenser) temperature.
</p>
<p>
The heat pump COP is computed as the product
</p>
<p align=\"center\" style=\"font-style:italic;\">
  COP = &eta;<sub>car</sub> COP<sub>car</sub> &eta;<sub>PL</sub>,
</p>
<p>
where <i>&eta;<sub>car</sub></i> is the Carnot effectiveness,
<i>COP<sub>car</sub></i> is the Carnot efficiency and
<i>&eta;<sub>PL</sub></i> is a polynomial in the heating part load ratio <i>y<sub>PL</sub></i>
that can be used to take into account a change in <i>COP</i> at part load
conditions.
This polynomial has the form
</p>
<p align=\"center\" style=\"font-style:italic;\">
  &eta;<sub>PL</sub> = a<sub>1</sub> + a<sub>2</sub> y<sub>PL</sub> + a<sub>3</sub> y<sub>PL</sub><sup>2</sup> + ...
</p>
<p>
where the coefficients <i>a<sub>i</sub></i> are declared by the parameter <code>a</code>.
</p>
<p>
On the <code>Dynamics</code> tag, the model can be parametrized to compute a transient
or steady-state response.
The transient response of the model is computed using a first
order differential equation for the evaporator and condenser fluid volumes.
The heat pump outlet temperatures are equal to the temperatures of these lumped volumes.
</p>
<h4>Typical use and important parameters</h4>
<p>
When using this component, make sure that the evaporator and the condenser have sufficient mass flow rate.
Based on the mass flow rates, the compressor power, temperature difference and the efficiencies,
the model computes how much heat will be added to the condenser and removed at the evaporator.
If the mass flow rates are too small, very high temperature differences can result.
</p>
<p>
The condenser heat flow rate <code>QCon_flow_nominal</code> is used to assign
the default value for the mass flow rates, which are used for the pressure drop
calculations.
It is also used to compute the part load efficiency.
Hence, make sure that <code>QCon_flow_nominal</code> is set to a reasonable value.
</p>
<p>
The maximum heating capacity is set by the parameter <code>QCon_flow_max</code>,
which is by default set to infinity.
</p>
<p>
By default, the coefficient of performance depends on the
evaporator entering temperature and the condenser leaving
temperature.
This can be changed with the parameters
<code>effInpEva</code> and
<code>effInpCon</code>.
</p>
<h4>Notes</h4>
<p>
For a similar model that can be used as a chiller, see
<a href=\"modelica://Annex60.Fluid.Chillers.Carnot_y\">Annex60.Fluid.Chillers.Carnot_y</a>.
</p>
</html>",
revisions="<html>
<ul>
<li>
January 26, 2016, by Michael Wetter:<br/>
Refactored model to use the same base class as
<a href=\"modelica://Annex60.Fluid.Chillers.Carnot_y\">Annex60.Fluid.Chillers.Carnot_y</a>.<br/>
Changed part load efficiency to depend on heating part load ratio rather than on the compressor
part load ratio.
</li>
<li>
January 20, 2015, by Damien Picard:<br/>
Add Carnot model to Annex 60 from the Buildings library.<br/>
Removed the flow direction dependency of
<code>staA1</code>, <code>staB1</code>, <code>staA2</code> and <code>staB2</code> as the
efficiency of the Carnot machine should only be computed in the design flow direction.<br/>
</li>
<li>
December 18, 2015, by Michael Wetter:<br/>
Corrected wrong computation of <code>staB1</code> and <code>staB2</code>
which mistakenly used the <code>inStream</code> operator
for the configuration without flow reversal.
This is for
<a href=\"modelica://https://github.com/lbl-srg/modelica-buildings/issues/476\">
issue 476</a>.
</li>
<li>
November 25, 2015 by Michael Wetter:<br/>
Changed sign convention for <code>dTEva_nominal</code> to be consistent with
other models.
The model will still work with the old values for <code>dTEva_nominal</code>,
but it will write a warning so that users can transition their models.
<br/>
Corrected <code>assert</code> statement for the efficiency curve.
This is for
<a href=\"modelica://https://github.com/lbl-srg/modelica-buildings/issues/468\">
issue 468</a>.
</li>
<li>
September 3, 2015 by Michael Wetter:<br/>
Expanded documentation.
</li>
<li>
May 6, 2015 by Michael Wetter:<br/>
Added <code>prescribedHeatFlowRate=true</code> for <code>vol2</code>.
</li>
<li>
October 9, 2013 by Michael Wetter:<br/>
Reimplemented the computation of the port states to avoid using
the conditionally removed variables <code>sta_a1</code>,
<code>sta_a2</code>, <code>sta_b1</code> and <code>sta_b2</code>.
</li>
<li>
May 10, 2013 by Michael Wetter:<br/>
Added electric power <code>P</code> as an output signal.
</li>
<li>
October 11, 2010 by Michael Wetter:<br/>
Fixed bug in energy balance.
</li>
<li>
March 3, 2009 by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"),
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{
            100,100}})),
    Icon(graphics={
        Line(points={{0,68},{0,90},{90,90},{90,90},{100,90}},
                                                 color={0,0,255})}));
end Carnot_y;
