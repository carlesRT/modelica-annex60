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
    AdditionalFluidPorts=false,
    HX_2=false,
    HX_1=false,
    height=globalModel.height,
    V=globalModel.V,
    thickness_ins=globalModel.th_ins,
    thickness_wall(displayUnit="mm") = 0.003,
    T_start(displayUnit="degC") = globalModel.T_start,
    alpha_out=globalModel.h_ext,
    lambda_ins=globalModel.lam_ins,
    nEle=12)
    annotation (Placement(transformation(extent={{-60,32},{-40,52}})));
  Stratified storage_2(
    redeclare package Medium = Medium,
    m_flow_nominal=1,
    d=0.04,
    nSeg=storage_1.nEle,
    h_port_a=0.2,
    h_port_b=0.2,
    VTan=globalModel.V,
    hTan=globalModel.height,
    dIns=globalModel.th_ins,
    kIns=globalModel.lam_ins,
    T_start=globalModel.T_start)
    annotation (Placement(transformation(extent={{-66,-90},{-46,-70}})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature BC_Storage_1(T=293.15)
    annotation (Placement(transformation(extent={{-80,70},{-60,90}})));
  Annex60.Fluid.Storage.Validations.GlobalModel globalModel(
    redeclare package Medium = Medium,
    lam_ins=0.1,
    th_ins=0.1,
    Ra_exp=9.5*10^12,
    Ratio_HD=3.45,
    U_exp=8.224,
    T_start=333.15)
                annotation (Placement(transformation(extent={{-80,-20},{-60,0}})));
  Sources.Boundary_pT               sink1(
    redeclare package Medium = Medium,
    use_T_in=false,
    p(displayUnit="Pa"),
    nPorts=1,
    T=293.15) "Sink" annotation (Placement(transformation(extent={{-10,-10},{10,
            10}}, origin={-90,58})));
  Sources.MassFlowSource_T               source1(
    redeclare package Medium = Medium,
    nPorts=1,
    m_flow=0.0,
    use_m_flow_in=false,
    T=298.15) "Flow source"
    annotation (Placement(transformation(extent={{-100,20},{-80,40}})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature BC_Storage_2(T=293.15)
    annotation (Placement(transformation(extent={{-20,-60},{-40,-40}})));
  Sources.MassFlowSource_T source2(redeclare package Medium = Medium, nPorts=1)
    annotation (Placement(transformation(extent={{-100,-90},{-80,-70}})));
  Sources.Boundary_pT sink2(redeclare package Medium = Medium, nPorts=1)
    annotation (Placement(transformation(extent={{-16,-90},{-36,-70}})));
  Modelica.Blocks.Sources.RealExpression storage_1_T_Bot(y=(storage_1.T[1] +
        storage_1.T[2] + storage_1.T[3] + storage_1.T[4])/4 - 273.15)
    annotation (Placement(transformation(extent={{0,70},{20,80}})));
  Modelica.Blocks.Sources.RealExpression storage_1_T_Mid(y=(storage_1.T[5] +
        storage_1.T[6] + storage_1.T[7] + storage_1.T[8])/4 - 273.15)
    annotation (Placement(transformation(extent={{0,80},{20,90}})));
  Modelica.Blocks.Sources.RealExpression storage_1_T_Top(y=(storage_1.T[9] +
        storage_1.T[10] + storage_1.T[11] + storage_1.T[12])/4 - 273.15)
    annotation (Placement(transformation(extent={{0,90},{20,100}})));
  Modelica.Blocks.Sources.RealExpression storage_2_T_Bot(y=(storage_2.vol[1].T
         + storage_2.vol[2].T + storage_2.vol[3].T + storage_2.vol[4].T)/4 -
        273.15)
    annotation (Placement(transformation(extent={{0,-100},{20,-90}})));
  Modelica.Blocks.Sources.RealExpression storage_2_T_Mid(y=(storage_2.vol[5].T
         + storage_2.vol[6].T + storage_2.vol[7].T + storage_2.vol[8].T)/4 -
        273.15)
    annotation (Placement(transformation(extent={{0,-90},{20,-80}})));
  Modelica.Blocks.Sources.RealExpression storage_2_T_Top(y=(storage_2.vol[9].T
         + storage_2.vol[10].T + storage_2.vol[11].T + storage_2.vol[12].T)/4
         - 273.15)
    annotation (Placement(transformation(extent={{0,-80},{20,-70}})));
  Modelica.Blocks.Sources.RealExpression storage_1_U_H(y=storage_1.UA_wall/(
        Modelica.Constants.pi*storage_1.diameter_ext*storage_1.height))
    annotation (Placement(transformation(extent={{40,90},{60,100}})));
equation

  connect(BC_Storage_1.port, storage_1.heatPort) annotation (Line(
      points={{-60,80},{-50,80},{-50,52.4}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(sink1.ports[1], storage_1.port_b1) annotation (Line(
      points={{-80,58},{-57,58},{-57,51}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(storage_1.port_a1,source1. ports[1]) annotation (Line(
      points={{-57,33},{-57,30},{-80,30}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(storage_2.port_a, source2.ports[1]) annotation (Line(points={{-66,-80},
          {-74,-80},{-80,-80}}, color={0,127,255}));
  connect(storage_2.port_b, sink2.ports[1]) annotation (Line(
      points={{-46,-80},{-36,-80}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(storage_2.heaPorTop, BC_Storage_2.port) annotation (Line(
      points={{-54,-72.6},{-56,-72.6},{-56,-50},{-40,-50}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(storage_2.heaPorSid, BC_Storage_2.port) annotation (Line(
      points={{-50.4,-80},{-48,-80},{-48,-50},{-40,-50}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(storage_2.heaPorBot, BC_Storage_2.port) annotation (Line(
      points={{-54,-86.4},{-48,-86.4},{-48,-50},{-40,-50}},
      color={191,0,0},
      smooth=Smooth.None));
  annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}}),                                                                     graphics),
    experiment(StopTime=18000, Tolerance=1e-005),
    __Dymola_experimentSetupOutput);
end CoolingPhase;
