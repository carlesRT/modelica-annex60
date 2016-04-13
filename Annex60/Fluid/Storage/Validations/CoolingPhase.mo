within Annex60.Fluid.Storage.Validations;
model CoolingPhase
  extends Modelica.Icons.Example;
  replaceable package Medium =
      Annex60.Media.Specialized.Water.TemperatureDependentDensity;

  Annex60.Fluid.Storage.StratifiedStorage storage(
    redeclare package Medium = Medium,
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
    height=2.05,
    T_start(displayUnit="degC") = 333.15)
    annotation (Placement(transformation(extent={{-60,-20},{-20,20}})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperature(T=293.15)
    annotation (Placement(transformation(extent={{-70,40},{-50,60}})));
  Annex60.Fluid.Storage.Validations.GlobalModel globalModel(
    redeclare package Medium = Medium,
    U=2.1,
    lam_ins=0.1,
    th_ins=0,
    Ra=2.87*10^12,
    T_start=333.15,
    Ratio_HD=2) annotation (Placement(transformation(extent={{40,0},{60,20}})));
  Sources.Boundary_pT               sink1(
    redeclare package Medium = Medium,
    use_T_in=false,
    p(displayUnit="Pa"),
    nPorts=1,
    T=293.15) "Sink" annotation (Placement(transformation(extent={{-10,-10},{10,
            10}}, origin={-90,20})));
  Sources.MassFlowSource_T               source2(
    redeclare package Medium = Medium,
    nPorts=1,
    m_flow=0.0,
    use_m_flow_in=false,
    T=298.15) "Flow source"
    annotation (Placement(transformation(extent={{-100,-30},{-80,-10}})));
equation

  connect(fixedTemperature.port, storage.heatPort)
    annotation (Line(
      points={{-50,50},{-40,50},{-40,20.8}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(sink1.ports[1], storage.port_b1) annotation (Line(
      points={{-80,20},{-54,20},{-54,18}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(storage.port_a1, source2.ports[1]) annotation (Line(
      points={{-54,-18},{-54,-20},{-80,-20}},
      color={0,127,255},
      smooth=Smooth.None));
  annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}}),                                                                     graphics));
end CoolingPhase;
