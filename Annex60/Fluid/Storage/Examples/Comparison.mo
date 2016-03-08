within Annex60.Fluid.Storage.Examples;
model Comparison
  extends Modelica.Icons.Example;
  replaceable package Medium = Annex60.Media.Water;

  Annex60.Fluid.Storage.StratifiedStorage storage(
    redeclare package Medium = Medium,
    T_start(displayUnit="degC") = 313.15,
    redeclare Annex60.Fluid.Storage.BaseClasses.BuoyancyModels.Buoyancy1
      HeatBuoyancy,
    Ele_HX_1=2,
    nEle=6,
    AdditionalFluidPorts=false,
    HX_2=false,
    HX_1=false,
    V=3,
    alpha_out=10,
    thickness_ins=0.02,
    thickness_wall=0.01,
    height=2.05)
    annotation (Placement(transformation(extent={{-64,-20},{-24,20}})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperature(T=293.15)
    annotation (Placement(transformation(extent={{-70,40},{-50,60}})));
  Annex60.Fluid.Storage.GlobalModel globalModel(
    redeclare package Medium = Medium,
    height=2.05,
    U=2.1,
    Ra=1.56*10^12)                              annotation (Placement(transformation(extent={{40,0},{
            60,20}})));
  Sources.Boundary_pT               sink1(
    redeclare package Medium = Medium,
    use_T_in=false,
    p(displayUnit="Pa"),
    nPorts=1,
    T=293.15) "Sink" annotation (Placement(transformation(extent={{-10,-10},{10,
            10}}, origin={-90,18})));
  Sources.MassFlowSource_T               source2(
    redeclare package Medium = Medium,
    nPorts=1,
    m_flow=0.0,
    use_m_flow_in=false,
    T=298.15) "Flow source"
    annotation (Placement(transformation(extent={{-100,-28},{-80,-8}})));
equation

  connect(fixedTemperature.port, storage.heatPort)
    annotation (Line(
      points={{-50,50},{-44,50},{-44,20.8}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(sink1.ports[1], storage.port_b1) annotation (Line(
      points={{-80,18},{-58,18}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(storage.port_a1, source2.ports[1]) annotation (Line(
      points={{-58,-18},{-80,-18}},
      color={0,127,255},
      smooth=Smooth.None));
  annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}}),                                                                     graphics));
end Comparison;
