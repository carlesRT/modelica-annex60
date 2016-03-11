within Annex60.Fluid.Storage.Examples;
model SimpleCharge
  extends Modelica.Icons.Example;
  replaceable package Medium = Annex60.Media.Water;
  Annex60.Fluid.Storage.StratifiedStorage storage(
    redeclare package Medium = Medium,
    height=2.0,
    redeclare Annex60.Fluid.Storage.BaseClasses.BuoyancyModels.Buoyancy1
      HeatBuoyancy,
    Ele_HX_1=2,
    nEle=6,
    HX_2=false,
    HX_1=false,
    T_start(displayUnit="degC") = 313.15)
    annotation (Placement(transformation(extent={{-20,-28},{20,12}})));
  Modelica.Blocks.Sources.TimeTable
                                m_flow1(
    startTime=500.0,
    offset=0.0,
    table=[0.0,0.0; 500,0.0; 500,-(1/500*1000); 700,-(1/500*1000); 700,0.0; 900,
        0; 900,1; 1100,1; 1100,0.0; 1300,0; 1300,-(1/500*1000); 1500,-(1/500*
        1000)]) "Mass flow rate"
    annotation (Placement(transformation(extent={{-100,-40},{-80,-20}})));
  Annex60.Fluid.Sources.Boundary_pT sink1(
    redeclare package Medium = Medium,
    use_T_in=false,
    p(displayUnit="Pa"),
    nPorts=1,
    T=343.15) "Sink" annotation (Placement(transformation(extent={{-10,-10},{10,
            10}}, origin={-60,10})));
  Annex60.Fluid.Sources.MassFlowSource_T source1(
    redeclare package Medium = Medium,
    nPorts=1,
    m_flow=0.0,
    use_m_flow_in=true,
    T=313.15) "Flow source"
    annotation (Placement(transformation(extent={{-42,-48},{-22,-28}})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperature(
    T = 298.15)
    annotation (Placement(transformation(extent={{-60,80},{-40,100}})));

  Modelica.Blocks.Math.Gain change_sign(k=-1) "Mass flow rate"
    annotation (Placement(transformation(extent={{-60,40},{-40,60}})));
  BaseClasses.StratificationEfficiency.MIXnumber mIXnumber(
    redeclare package Medium = Medium,
    H=2,
    V_tank=1,
    n=6,
    T_start=313.15)
    annotation (Placement(transformation(extent={{40,40},{60,60}})));
equation
  connect(source1.ports[1], storage.port_a1) annotation (Line(
      points={{-22,-38},{-20,-38},{-20,-26},{-14,-26}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(source1.m_flow_in, m_flow1.y) annotation (Line(
      points={{-42,-30},{-79,-30}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(sink1.ports[1], storage.port_b1) annotation (Line(
      points={{-50,10},{-14,10}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(fixedTemperature.port, storage.heatPort) annotation (Line(
      points={{-40,90},{0,90},{0,12.8}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(m_flow1.y, change_sign.u) annotation (Line(
      points={{-79,-30},{-62,-30},{-62,-8},{-80,-8},{-80,50},{-62,50}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(mIXnumber.T_exp, storage.T) annotation (Line(
      points={{40,57},{8,57},{8,58},{-32,58},{-32,4},{-14.8,4}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(mIXnumber.m_in, change_sign.y) annotation (Line(
      points={{40,53},{38,53},{38,38},{-20,38},{-20,50},{-39,50}},
      color={0,0,127},
      smooth=Smooth.None));
  annotation (    __Dymola_Commands(file="modelica://Annex60/Resources/Scripts/Dymola/Fluid/Storage/Examples/StratifiedStorage.mos"
        "Simulate and plot"), Documentation(info="<html>
<p>Charging once cold through bottom inlet, twice through internal heat exchanger.</p>
</html>"),
    experiment(StopTime=2000),
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{
            100,100}}),
                    graphics));
end SimpleCharge;
