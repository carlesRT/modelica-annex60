within Annex60.Experimental.Pipe.Examples.Comparisons;
model Reverse_knowVelocity
  "Comparison of KUL A60 pipes with heat loss without reverse flow"
  import Annex60;
  extends Modelica.Icons.Example;

  package Medium = Annex60.Media.Water;

  parameter Modelica.SIunits.Diameter diameter=0.1 "Pipe diameter";
  parameter Modelica.SIunits.Length length=100 "Pipe length";

  parameter Modelica.SIunits.Pressure dp_test = 200
    "Differential pressure for the test used in ramps";

  Modelica.Blocks.Sources.Constant PAtm(k=101325) "Atmospheric pressure"
      annotation (Placement(transformation(extent={{126,76},{146,96}})));

  Annex60.Fluid.Sources.MassFlowSource_T
                                    sou1(          redeclare package Medium =
        Medium,
    use_T_in=true,
    nPorts=2,
    m_flow=5*7.819344,
    use_m_flow_in=true,
    T=293.15)
    "Source with high pressure at beginning and lower pressure at end of experiment"
                          annotation (Placement(transformation(extent={{-88,16},
            {-68,36}})));
  Annex60.Fluid.Sources.Boundary_pT sin1(          redeclare package Medium =
        Medium,
    nPorts=2,
    use_p_in=true,
    T=283.15)
    "Sink at with constant pressure, turns into source at the end of experiment"
                          annotation (Placement(transformation(extent={{140,28},
            {120,48}})));
  Annex60.Fluid.Sensors.MassFlowRate masFloA60(redeclare package Medium =
        Medium) "Mass flow rate sensor for the A60 temperature delay"
    annotation (Placement(transformation(extent={{88,30},{108,50}})));

  Modelica.Blocks.Sources.Step stepT(
    height=10,
    offset=273.15 + 20,
    startTime=10000)
    "Step temperature increase to test propagation of temperature wave"
    annotation (Placement(transformation(extent={{-150,-58},{-130,-38}})));
  Annex60.Experimental.Pipe.PipeHeatLossA60Mod2 A60PipeHeatLossMod2(
    redeclare package Medium = Medium,
    m_flow_small=1e-4*0.5,
    diameter=diameter,
    length=length,
    m_flow_nominal=0.5,
    thicknessIns=0.02) "Annex 60 pipe with heat losses"
    annotation (Placement(transformation(extent={{20,30},{40,50}})));
  Annex60.Fluid.Sensors.TemperatureTwoPort senTemA60Out(redeclare package
      Medium = Medium, m_flow_nominal=0.5)
    "Temperature sensor for the outflow of the A60 temperature delay"
    annotation (Placement(transformation(extent={{56,30},{76,50}})));
  Annex60.Fluid.Sensors.TemperatureTwoPort senTemA60In(redeclare package Medium
      = Medium, m_flow_nominal=0.5)
    "Temperature of the inflow to the A60 temperature delay"
    annotation (Placement(transformation(extent={{-60,30},{-40,50}})));
  Modelica.Blocks.Sources.CombiTimeTable combiTimeTable(table=[0,-1; 3000,1;
        5000,0; 10000,0; 12000,-1; 17000,-1; 19000,0; 30000,0; 32000,1; 50000,1;
        52000,0; 80000,0; 82000,-1; 100000,-1; 102000,0; 150000,0; 152000,1;
        160000,1; 162000,0; 163500,0; 165500,-1; 200000,-1], smoothness=
        Modelica.Blocks.Types.Smoothness.LinearSegments)
    annotation (Placement(transformation(extent={{-190,60},{-170,80}})));
  Modelica.Blocks.Math.Gain gain(k=2*0.07819344)
    annotation (Placement(transformation(extent={{-150,60},{-130,80}})));
  Modelica.Blocks.Math.Add add
    annotation (Placement(transformation(extent={{-118,66},{-98,86}})));
  Modelica.Blocks.Sources.Constant PAtm1(k=0) "Atmospheric pressure"
      annotation (Placement(transformation(extent={{-158,88},{-138,108}})));
  Annex60.Fluid.Sensors.MassFlowRate masFloA60Mod(redeclare package Medium =
        Medium) "Mass flow rate sensor for the A60 modified temperature delay"
    annotation (Placement(transformation(extent={{88,70},{108,90}})));
  Annex60.Experimental.Pipe.PipeHeatLossA60Mod A60PipeHeatLossMod(
    redeclare package Medium = Medium,
    m_flow_small=1e-4*0.5,
    diameter=diameter,
    length=length,
    m_flow_nominal=0.5,
    thicknessIns=0.02,
    lambdaI=0.01) "Annex 60 modified pipe with heat losses"
    annotation (Placement(transformation(extent={{20,70},{40,90}})));
  Annex60.Fluid.Sensors.TemperatureTwoPort senTemA60ModOut(redeclare package
      Medium = Medium, m_flow_nominal=0.5)
    "Temperature sensor for the outflow of the A60 modified temperature delay"
    annotation (Placement(transformation(extent={{56,70},{76,90}})));
  Annex60.Fluid.Sensors.TemperatureTwoPort senTemA60ModIn(redeclare package
      Medium = Medium, m_flow_nominal=0.5)
    "Temperature of the inflow to the A60 modified temperature delay"
    annotation (Placement(transformation(extent={{-62,68},{-42,88}})));
  Modelica.Blocks.Sources.Constant const3(k=5)
    annotation (Placement(transformation(extent={{-40,100},{-20,120}})));
equation
  connect(PAtm.y, sin1.p_in)
                            annotation (Line(points={{147,86},{154,86},{154,46},
          {142,46}},
                   color={0,0,127}));
  connect(sin1.ports[1],masFloA60. port_b) annotation (Line(
      points={{120,40},{114,40},{114,40},{108,40}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(A60PipeHeatLossMod2.port_b, senTemA60Out.port_a) annotation (Line(
      points={{40,40},{56,40}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(masFloA60.port_a,senTemA60Out. port_b) annotation (Line(
      points={{88,40},{76,40}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(sou1.ports[1],senTemA60In. port_a) annotation (Line(
      points={{-68,28},{-66,28},{-66,40},{-60,40}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(senTemA60In.port_b, A60PipeHeatLossMod2.port_a)
    annotation (Line(points={{-40,40},{20,40}}, color={0,127,255}));
  connect(combiTimeTable.y[1], gain.u)
    annotation (Line(points={{-169,70},{-152,70}}, color={0,0,127}));
  connect(gain.y, add.u2)
    annotation (Line(points={{-129,70},{-120,70}},        color={0,0,127}));
  connect(PAtm1.y, add.u1) annotation (Line(points={{-137,98},{-124,98},{-124,
          82},{-120,82}},
                     color={0,0,127}));
  connect(A60PipeHeatLossMod.port_b,senTemA60ModOut. port_a) annotation (Line(
      points={{40,80},{56,80}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(masFloA60Mod.port_a,senTemA60ModOut. port_b) annotation (Line(
      points={{88,80},{76,80}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(senTemA60ModIn.port_b,A60PipeHeatLossMod. port_a)
    annotation (Line(points={{-42,78},{-12,78},{-12,80},{20,80}},
                                                color={0,127,255}));
  connect(const3.y,A60PipeHeatLossMod. T_amb)
    annotation (Line(points={{-19,110},{30,110},{30,90}},
                                                        color={0,0,127}));
  connect(sou1.ports[2], senTemA60ModIn.port_a)
    annotation (Line(points={{-68,24},{-66,24},{-66,78},{-62,78}},
                                                   color={0,127,255}));
  connect(sin1.ports[2], masFloA60Mod.port_b) annotation (Line(points={{120,36},
          {120,80},{108,80}},       color={0,127,255}));

  connect(sou1.m_flow_in, add.y) annotation (Line(
      points={{-88,34},{-90,34},{-90,76},{-97,76}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(const3.y, A60PipeHeatLossMod2.T_amb) annotation (Line(
      points={{-19,110},{0,110},{0,50},{30,50}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(stepT.y, sou1.T_in) annotation (Line(
      points={{-129,-48},{-112,-48},{-112,30},{-90,30}},
      color={0,0,127},
      smooth=Smooth.None));
    annotation (experiment(StopTime=200000, __Dymola_NumberOfIntervals=5000),
__Dymola_Commands(file="modelica://Annex60/Resources/Scripts/Dymola/Experimental/PipeAdiabatic/PipeAdiabatic_TStep.mos"
        "Simulate and plot"),
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-200,-180},{
            160,140}}),
                    graphics),
    Documentation(info="<html>
<p>This example compares the KUL and A60 pipe with heat loss implementations.</p>
<p>This is only a first glimpse at the general behavior. Next step is to parameterize 
both models with comparable heat insulation properties. In general, the KUL pipe seems 
to react better to changes in mass flow rate, but also does not show cooling effects at 
the period of zero-mass flow.</p>
</html>", revisions="<html>
<ul>
<li>
October 1, 2015 by Marcus Fuchs:<br/>
First implementation.
</li>
</ul>
</html>"),
    __Dymola_experimentSetupOutput);
end Reverse_knowVelocity;
