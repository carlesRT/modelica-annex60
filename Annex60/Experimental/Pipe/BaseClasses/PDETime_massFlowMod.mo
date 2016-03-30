within Annex60.Experimental.Pipe.BaseClasses;
model PDETime_massFlowMod "Delay time for given normalized velocity"

  Modelica.Blocks.Interfaces.RealInput m_flow "Mass flow of fluid" annotation (
      Placement(transformation(extent={{-140,-20},{-100,20}}),
        iconTransformation(extent={{-140,-20},{-100,20}})));
  parameter Modelica.SIunits.Length length "Pipe length";
  parameter Modelica.SIunits.Length diameter=0.05 "diameter of pipe";
  parameter Modelica.SIunits.Density rho=1000 "Standard density of fluid";
  Modelica.SIunits.Time time_out_a "Virtual time after delay at port a";
  Modelica.SIunits.Time time_out_b "Virtual time after delay at port b";
  Modelica.SIunits.Time tau_a "Time delay for input time";
  Modelica.SIunits.Time tau_b "Time delay for input time";
  Modelica.SIunits.Time tau_a_lim "Limited time delay for input time";
  Modelica.SIunits.Time tau_b_lim "Limited time delay for input time";
  Modelica.SIunits.Length x(start=0)
    "Spatial coordiante for spatialDistribution operator";
  Modelica.SIunits.Velocity v "Fluid velocity";
  Modelica.Blocks.Interfaces.RealOutput tau "Time delay"
    annotation (Placement(transformation(extent={{100,-10},{120,10}})));
  Boolean zeroPeriod "true if the mass flow rate is quasi 0";
  Boolean NonZeroPeriod "true if the flow velocity is >epsilon or <-epsilon";
  Boolean track_a_evaluate "used to reinit trackEnd ";
  Boolean track_b_evaluate "used to reinit trackEnd ";
  Boolean trackEnd_NotNeeded "check if this value is needed";
  Modelica.SIunits.Time trackBegin "start time of a zero mass flow rate period";
  Modelica.SIunits.Time trackEnd
    "Delay time of a mass flow rate period is stored";
  Modelica.SIunits.Time track;
    Real epsilon = 0.000001;

equation
 v = m_flow/(rho*(diameter^2)/4*Modelica.Constants.pi);

 der(x) = v;
  (time_out_a,time_out_b) = spatialDistribution(time,
                                       time,
                                       x/length,
                                       noEvent(v>=0),
                                       {0.0, 1.0},
                                       {0.0, 0.0});

  if v>= 0 then
    tau = tau_b_lim;
  else
    tau = tau_a_lim;
  end if;

  if (abs(v) >= epsilon) then
    zeroPeriod    = false;
    NonZeroPeriod = true;
    track = 0;
  else
    zeroPeriod = true;
    NonZeroPeriod = false;
    track = time - trackBegin;
  end if;

  when edge(zeroPeriod) then
    trackBegin = pre(time);
  end when;
  when edge(NonZeroPeriod) then
    reinit(trackBegin,0);
    trackEnd = pre(track);
  end when;

  tau_a_lim = max(trackEnd,max(track,tau_a));
  tau_b_lim = max(trackEnd,max(track,tau_b));
  tau_a = time-time_out_a;
  tau_b = time-time_out_b;

  trackEnd_NotNeeded = track_b_evaluate <> track_a_evaluate;
  track_b_evaluate = trackEnd <= tau_b;
  track_a_evaluate = trackEnd <= tau_a;

  when (edge(track_a_evaluate) or edge(track_b_evaluate)) or edge(trackEnd_NotNeeded) then
    reinit(trackEnd,0);
  end when;

  annotation (
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,
            100}}), graphics),
    Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
        graphics={
        Rectangle(
          extent={{-100,-100},{100,100}},
          lineColor={0,0,127},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Line(
          points={{-92,0},{-80.7,34.2},{-73.5,53.1},{-67.1,66.4},{-61.4,74.6},{-55.8,
              79.1},{-50.2,79.8},{-44.6,76.6},{-38.9,69.7},{-33.3,59.4},{-26.9,44.1},
              {-18.83,21.2},{-1.9,-30.8},{5.3,-50.2},{11.7,-64.2},{17.3,-73.1},{
              23,-78.4},{28.6,-80},{34.2,-77.6},{39.9,-71.5},{45.5,-61.9},{51.9,
              -47.2},{60,-24.8},{68,0}},
          color={0,0,127},
          smooth=Smooth.Bezier),
        Line(points={{-64,0},{-52.7,34.2},{-45.5,53.1},{-39.1,66.4},{-33.4,74.6},
              {-27.8,79.1},{-22.2,79.8},{-16.6,76.6},{-10.9,69.7},{-5.3,59.4},{1.1,
              44.1},{9.17,21.2},{26.1,-30.8},{33.3,-50.2},{39.7,-64.2},{45.3,-73.1},
              {51,-78.4},{56.6,-80},{62.2,-77.6},{67.9,-71.5},{73.5,-61.9},{79.9,
              -47.2},{88,-24.8},{96,0}}, smooth=Smooth.Bezier),
        Text(
          extent={{20,100},{82,30}},
          lineColor={0,0,255},
          textString="PDE"),
        Text(
          extent={{-82,-30},{-20,-100}},
          lineColor={0,0,255},
          textString="tau"),
        Text(
          extent={{-60,140},{60,100}},
          lineColor={0,0,255},
          textString="%name")}),
    Documentation(info="<html>
<p><span style=\"font-family: MS Shell Dlg 2;\">Calculates time delay as the difference between the current simulation time and the inlet time. The inlet time is propagated with the corresponding fluid parcel using the spatialDistribution function.</span></p>
</html>", revisions="<html>
<ul>
<li>
October 13, 2015 by Marcus Fuchs:<br/>
Use <code>abs()</code> of normalized velocity input in order to avoid negative delay times.
</li>
<li>
2015 by Bram van der Heijde:<br/>
First implementation.
</li>
</ul>
</html>"));
end PDETime_massFlowMod;
