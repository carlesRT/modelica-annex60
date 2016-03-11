within Annex60.Fluid.Storage.Examples;
model StratifiedStorage
  extends Modelica.Icons.Example;
  replaceable package Medium = Annex60.Media.Water;
  Annex60.Fluid.Storage.StratifiedStorage storage(
    redeclare package Medium = Medium,
    height=2.0,
    T_start(displayUnit="degC") = 313.15,
    redeclare Annex60.Fluid.Storage.BaseClasses.BuoyancyModels.Buoyancy1
      HeatBuoyancy,
    HX_1=true,
    Ele_HX_1=2,
    nEle=6,
    AdditionalFluidPorts=false,
    HX_2=false)
    annotation (Placement(transformation(extent={{-20,-28},{20,12}})));
  Annex60.Fluid.Sources.MassFlowSource_T source2(
    redeclare package Medium = Medium,
    nPorts=1,
    m_flow=0,
    use_m_flow_in=true,
    T=343.15) "Flow source"
    annotation (Placement(transformation(extent={{48,-48},{28,-28}})));
  Annex60.Fluid.Sources.Boundary_pT sink2(
    redeclare package Medium = Medium,
    use_T_in=false,
    p(displayUnit="Pa"),
    nPorts=1,
    T=293.15) "Sink" annotation (Placement(transformation(extent={{10,-10},{-10,
            10}}, origin={38,2})));
  Modelica.Blocks.Sources.Pulse m_flow1(
    startTime=500.0,
    offset=0.0,
    amplitude=0.2,
    period=400.0,
    nperiod=1) "Mass flow rate"
    annotation (Placement(transformation(extent={{-72,-58},{-52,-38}})));
  Annex60.Fluid.Sources.Boundary_pT sink1(
    redeclare package Medium = Medium,
    use_T_in=false,
    p(displayUnit="Pa"),
    nPorts=1,
    T=293.15) "Sink" annotation (Placement(transformation(extent={{-10,-10},{10,
            10}}, origin={-60,10})));
  Annex60.Fluid.Sources.MassFlowSource_T source1(
    redeclare package Medium = Medium,
    nPorts=1,
    m_flow=0.0,
    use_m_flow_in=true,
    T=298.15) "Flow source"
    annotation (Placement(transformation(extent={{-42,-48},{-22,-28}})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperature(
    T = 298.15)
    annotation (Placement(transformation(extent={{-60,80},{-40,100}})));
  Modelica.Blocks.Sources.Pulse m_flow2(
    offset = 0.0,
    amplitude = 0.2,
    nperiod = 2,
    period = 500.0,
    startTime = 1200.0) "Mass flow rate"
    annotation (Placement(transformation(extent={{76,-40},{56,-20}})));
//  BaseClasses.StratificationEfficiency.MIXnumber mIXnumber(    redeclare package Medium = Medium,    H=2,    V_tank=1,    n=6) annotation (Placement(transformation(extent={{40,40},{60,60}})));

equation
  connect(source1.ports[1], storage.port_a1) annotation (Line(
      points={{-22,-38},{-20,-38},{-20,-26},{-14,-26}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(storage.port_HX_1_a, source2.ports[1]) annotation (Line(
      points={{14,-16},{20,-16},{20,-38},{28,-38}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(source1.m_flow_in, m_flow1.y) annotation (Line(
      points={{-42,-30},{-48,-30},{-48,-48},{-51,-48}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(source2.m_flow_in, m_flow2.y) annotation (Line(
      points={{48,-30},{55,-30}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(sink2.ports[1], storage.port_HX_1_b) annotation (Line(
      points={{28,2},{26,2},{26,-14},{14,-14},{14,-20}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(sink1.ports[1], storage.port_b1) annotation (Line(
      points={{-50,10},{-14,10}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(fixedTemperature.port, storage.heatPort) annotation (Line(
      points={{-40,90},{0,90},{0,12.8}},
      color={191,0,0},
      smooth=Smooth.None));
  annotation (    __Dymola_Commands(file="modelica://Annex60/Resources/Scripts/Dymola/Fluid/Storage/Examples/StratifiedStorage.mos"
        "Simulate and plot"), Documentation(info="<html>
<p>Charging once cold through bottom inlet, twice through internal heat exchanger.</p>
</html>"),
    experiment(StopTime=2000),
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,
            100}}), graphics));
end StratifiedStorage;
