within Annex60.Fluid.Storage.Validations;
model Example1

  parameter Integer nTemp=19;

  Stratified tan(
    redeclare package Medium = Medium,
    m_flow_nominal=1,
    VTan=1.225*Modelica.Constants.pi*0.272^2,
    hTan=1.225,
    dIns=0.1,
    d=0.04,
    h_port_a=1.035,
    h_port_b=0.18,
    T_start=287.9,
    nSeg=50,
    vol(T_start={287.15125,287.15125,287.21155,287.34283,287.47412,287.60544,
          287.73672,287.65414,287.62244,287.82025,288.01807,288.21588,288.4137,
          288.51889,288.57764,288.65463,288.73166,288.80865,288.88568,288.93793,
          288.96661,288.98773,289.00885,289.02994,289.05106,289.0979,289.18372,
          289.23633,289.2879,289.33948,289.39102,289.39963,289.29517,289.30582,
          289.33725,289.36868,289.40012,289.41263,289.32034,289.32346,289.36279,
          289.40213,289.4415,289.47662,289.37833,289.39484,289.48724,289.57968,
          289.44125,289.36893}))
             annotation (Placement(transformation(extent={{0,0},{20,20}})));
  Sources.MassFlowSource_T boundary(
    redeclare package Medium = Medium,
    use_m_flow_in=true,
    use_T_in=true,
    nPorts=1) annotation (Placement(transformation(extent={{-34,0},{-14,20}})));
  replaceable package Medium = Annex60.Media.Water;
  Sources.Boundary_pT bou(          redeclare package Medium = Medium, nPorts=1)
    annotation (Placement(transformation(extent={{100,0},{80,20}})));
  Modelica.Blocks.Sources.CombiTimeTable combiTimeTable(
    tableOnFile=true,
    tableName="data",
    columns=2:21,
    fileName="test1.mat")
    annotation (Placement(transformation(extent={{-100,40},{-80,60}})));
  Modelica.Blocks.Math.Add add[nTemp]
    annotation (Placement(transformation(extent={{-68,20},{-48,40}})));
  Modelica.Blocks.Sources.Constant const(k=273.15)
    annotation (Placement(transformation(extent={{-100,14},{-80,34}})));
  Modelica.Blocks.Math.Gain lmin2kgs(k=1/60) "Conversion of liters to kg/s"
    annotation (Placement(transformation(extent={{-68,-10},{-48,10}})));
  Sensors.TemperatureTwoPort senTemOut(
    redeclare package Medium = Medium,
    m_flow_nominal=1,
    tau=0) annotation (Placement(transformation(extent={{40,0},{60,20}})));
equation
  connect(tan.port_a, boundary.ports[1])
    annotation (Line(points={{0,10},{-8,10},{-14,10}}, color={0,127,255}));
  connect(lmin2kgs.y, boundary.m_flow_in) annotation (Line(points={{-47,0},{-42,
          0},{-42,18},{-34,18}}, color={0,0,127}));
  connect(tan.port_b, senTemOut.port_a)
    annotation (Line(points={{20,10},{30,10},{40,10}}, color={0,127,255}));
  connect(senTemOut.port_b, bou.ports[1])
    annotation (Line(points={{60,10},{70,10},{80,10}}, color={0,127,255}));
  connect(lmin2kgs.u, combiTimeTable.y[1])
    annotation (Line(points={{-70,0},{-79,0},{-79,50}}, color={0,0,127}));
  connect(add[1:nTemp].u1, combiTimeTable.y[2:nTemp+1]) annotation (Line(points={{-70,36},{-72,36},{
          -72,44},{-72,50},{-79,50}}, color={0,0,127}));

  for i in 1:nTemp loop
    connect(const.y, add[i].u2)
    annotation (Line(points={{-79,24},{-70,24},{-70,24}}, color={0,0,127}));
  end for;
  connect(boundary.T_in, add[1].y)
    annotation (Line(points={{-36,14},{-47,14},{-47,30}}, color={0,0,127}));
   annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}})),
    experiment(StopTime=3000),
    __Dymola_experimentSetupOutput(events=false));
end Example1;
