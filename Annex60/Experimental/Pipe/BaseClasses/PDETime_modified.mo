within Annex60.Experimental.Pipe.BaseClasses;
model PDETime_modified "Delay time for given normalized velocity"

  Real x( start = 0) "Normalized transport quantity";
  Modelica.SIunits.Time TimeOut_a
    "Time at which the fluid is leaving the pipe at port_a";
  Modelica.SIunits.Time TimeOut_b
    "Time at which the fluid is leaving the pipe at port_b";
  parameter Modelica.SIunits.Length len = 100 "length";
  Modelica.SIunits.Time track1;
  Modelica.SIunits.Time track2;
  Modelica.SIunits.Time track3;
  Modelica.SIunits.Time track4;
  Modelica.SIunits.Time track5;
  Modelica.SIunits.Time track6;
  Modelica.SIunits.Time trackStart;
  Modelica.SIunits.Time trackEnd;
  Modelica.SIunits.Time DeltaTrack;
  Modelica.SIunits.Time RealTime;
  Modelica.SIunits.Time tau_a;
  Modelica.SIunits.Time tau_b;

  Boolean Check1;
  Boolean Check_u;
  Real accel;
  Real Eps;
  Boolean v_a "Is the fluid flowing from a to b?";
  Boolean v_b "Is the fluid flowing from b to a?";

  Modelica.Blocks.Interfaces.RealInput u "Normalized fluid velocity"
    annotation (Placement(transformation(extent={{-140,-20},{-100,20}}),
        iconTransformation(extent={{-140,-20},{-100,20}})));

  Modelica.Blocks.Interfaces.RealOutput tau "Time delay"
    annotation (Placement(transformation(extent={{100,-10},{120,10}})));
equation
  //Speed
  der(x) = u;
  accel = der(u);

  RealTime = time;

  //Spatial distribution of the time
  (TimeOut_a,TimeOut_b) = spatialDistribution(time,time,x/len,u >= 0,{0.0,1.0},{0.0,0.0});
  tau_a = max(0,Annex60.Utilities.Math.Functions.smoothMax(time - TimeOut_a,DeltaTrack,1));
  tau_b = max(0,time - TimeOut_b);

  if u >= 0 then
    tau = max(0,tau_b);
  else
    tau = max(0,tau_a);
  end if;

  if u>0 and tau_b <= 0 then
    Check1 = true;
  else
    Check1 = false;
  end if;

  Check_u = u>=0;

  Eps   = 100000 * Modelica.Constants.eps;
  v_a   =  (u  >=   Eps);
  v_b   =  (u  <=  -Eps);

  when (change(v_b)) and v_a == false and v_b == false then
    track1 = pre(time);
  end when;

  track2 = track1;

  when change(v_a) and v_a == true then
    track5 = pre(time);
  end when;

  when change(v_b) and v_b == true then
    track6 = pre(time);
  end when;

  when (change(v_a)) and v_b == false and v_a == false then
    track3 = pre(time);
  end when;

  when (change(v_b)) and v_b == false and v_a == false then
    track4 = pre(time);
  end when;

  trackStart = max(track3,track4);
  trackEnd   = max(track5,track6);
  DeltaTrack = abs(trackEnd - trackStart);

/*when time-TimeOut_a > (DeltaTrack) and v_b then
    reinit(track3,0);
    reinit(track4,0);
    reinit(track5,0);
    reinit(track6,0);
   // reinit(DeltaTrack,0);
end when;
*/

  annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}}), graphics), Icon(coordinateSystem(
          preserveAspectRatio=false, extent={{-100,-100},{100,100}}), graphics={
                                Rectangle(
        extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
    Line(points={{-92,0},{-80.7,34.2},{-73.5,53.1},{-67.1,66.4},{-61.4,74.6},{-55.8,
              79.1},{-50.2,79.8},{-44.6,76.6},{-38.9,69.7},{-33.3,59.4},{-26.9,44.1},
              {-18.83,21.2},{-1.9,-30.8},{5.3,-50.2},{11.7,-64.2},{17.3,-73.1},{
              23,-78.4},{28.6,-80},{34.2,-77.6},{39.9,-71.5},{45.5,-61.9},{51.9,
              -47.2},{60,-24.8},{68,0}},
      color={0,0,127},
      smooth=Smooth.Bezier),
    Line(points={{-64,0},{-52.7,34.2},{-45.5,53.1},{-39.1,66.4},{-33.4,74.6},{-27.8,
              79.1},{-22.2,79.8},{-16.6,76.6},{-10.9,69.7},{-5.3,59.4},{1.1,44.1},
              {9.17,21.2},{26.1,-30.8},{33.3,-50.2},{39.7,-64.2},{45.3,-73.1},{51,
              -78.4},{56.6,-80},{62.2,-77.6},{67.9,-71.5},{73.5,-61.9},{79.9,-47.2},
              {88,-24.8},{96,0}},
      smooth=Smooth.Bezier),
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
end PDETime_modified;
