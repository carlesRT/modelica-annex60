within Annex60.Fluid.Storage.Validations;
model CoolingPhase
  extends Modelica.Icons.Example;
  replaceable package Medium =
      Annex60.Media.Specialized.Water.TemperatureDependentDensity;

  Annex60.Fluid.Storage.StratifiedStorage storage_1(
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
    annotation (Placement(transformation(extent={{-60,18},{-20,58}})));
  Stratified storage_2(
    redeclare package Medium = Medium,
    m_flow_nominal=1,
    d=0.04,
    h_port_a=0,
    h_port_b=0,
    VTan=storage_1.nEle,
    hTan=storage_1.height,
    dIns=storage_1.thickness_ins,
    kIns=storage_1.lambda_ins,
    nSeg=storage_1.nEle,
    T_start=333.15)
    annotation (Placement(transformation(extent={{-60,-60},{-40,-40}})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperature(T=293.15)
    annotation (Placement(transformation(extent={{-70,78},{-50,98}})));
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
            10}}, origin={-90,58})));
  Sources.MassFlowSource_T               source2(
    redeclare package Medium = Medium,
    nPorts=1,
    m_flow=0.0,
    use_m_flow_in=false,
    T=298.15) "Flow source"
    annotation (Placement(transformation(extent={{-100,8},{-80,28}})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperature3(
                                                                          T=293.15)
    annotation (Placement(transformation(extent={{-10,-30},{-30,-10}})));
  Sources.MassFlowSource_T boundary(
    redeclare package Medium = Medium,
    nPorts=1) annotation (Placement(transformation(extent={{-94,-60},{-74,-40}})));
  Sources.Boundary_pT bou(          redeclare package Medium = Medium, nPorts=1)
    annotation (Placement(transformation(extent={{-10,-60},{-30,-40}})));
equation

  connect(fixedTemperature.port, storage_1.heatPort) annotation (Line(
      points={{-50,88},{-40,88},{-40,58.8}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(sink1.ports[1], storage_1.port_b1) annotation (Line(
      points={{-80,58},{-54,58},{-54,56}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(storage_1.port_a1, source2.ports[1]) annotation (Line(
      points={{-54,20},{-54,18},{-80,18}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(storage_2.port_a, boundary.ports[1]) annotation (Line(points={{-60,-50},
          {-68,-50},{-74,-50}}, color={0,127,255}));
  connect(storage_2.port_b, bou.ports[1]) annotation (Line(
      points={{-40,-50},{-30,-50}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(storage_2.heaPorTop, fixedTemperature3.port) annotation (Line(
      points={{-48,-42.6},{-50,-42.6},{-50,-20},{-30,-20}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(storage_2.heaPorSid, fixedTemperature3.port) annotation (Line(
      points={{-44.4,-50},{-42,-50},{-42,-20},{-30,-20}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(storage_2.heaPorBot, fixedTemperature3.port) annotation (Line(
      points={{-48,-56.4},{-42,-56.4},{-42,-20},{-30,-20}},
      color={191,0,0},
      smooth=Smooth.None));
  annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}}),                                                                     graphics));
end CoolingPhase;
