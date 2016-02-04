within Annex60.Fluid.Storage.BaseClasses;
model JetInflow "Model for simulating jet inflow"
  replaceable package Medium = Modelica.Media.Interfaces.PartialMedium;

  parameter Integer nSeg(min=10) "Number of layers in the storage tank";
  parameter Modelica.SIunits.MassFlowRate m_flow_nominal
    "Nominal mass flow rate, used for regularization only";
  parameter Modelica.SIunits.Volume Vlay[nSeg] "Volume of each layer";
  parameter Modelica.SIunits.Length d "Diameter of inlet";
  parameter Modelica.SIunits.Length D "Diameter of tank";
  parameter Modelica.SIunits.Length hIn "Height of inlet center"
    annotation(Evaluate=true);
  parameter Modelica.SIunits.Length hLay[nSeg] "Height of layer centers"
    annotation(Evaluate=true);
  parameter Modelica.SIunits.Length dLay[nSeg]=Vlay/(Modelica.Constants.pi*(D/2)^2)
    "Layer thicknesses"
    annotation(Evaluate=true);
  parameter Modelica.SIunits.Length hTan = max(dLay/2+hLay)-min(hLay-dLay/2)
    "Tank height";

  parameter Modelica.SIunits.Time tau = 60
    "Mixing time constant for calculation of Froude number";
  parameter Real beta(final unit="K-1") = 0.43e-3
    "Volumetric expansion coefficient, default: water at approximately 50 degrees Celsius"
    annotation(Dialog(tab="Advanced"));
  Real[nSeg] wInj = if port_a.m_flow > 0
                    then Vlay.*{min(1,max(0,(1 -(dh[i]/zMix)^4)) +
                                (if hIn<hLay[i]+dLay[i]/2 and Tmix >=Tin_b[i] and Tin_a>= Tin_b[i] or hIn>hLay[i]-dLay[i]/2 and Tmix <Tin_b[i] and Tin_a<Tin_b[i] then 1 else 0))
                                  for i in 1:nSeg}
                    else Vlay.*{if dh[i]<dLay[i]/2 and dh[i]>-dLay[i]/2 then 1 else exp(-6*(dh[i]/zMix)^2) for i in 1:nSeg}
    "Weight for mass injection in each port";
  Real wInjTot = sum(wInj);

  Modelica.Fluid.Interfaces.FluidPort_a port_a(redeclare package Medium =
        Medium)
    annotation (Placement(transformation(extent={{-110,-10},{-90,10}})));
  Modelica.Fluid.Interfaces.FluidPort_b[nSeg] ports_b(redeclare package Medium
      = Medium)
    annotation (Placement(transformation(extent={{90,-10},{110,10}})));

  Modelica.SIunits.Temperature Tin_a = Medium.temperature(Medium.setState_phX(port_a.p, inStream(port_a.h_outflow), inStream(port_a.Xi_outflow)));
  Modelica.SIunits.Temperature[nSeg] Tin_b = Medium.temperature(Medium.setState_phX(ports_b.p, inStream(ports_b.h_outflow), inStream(ports_b.Xi_outflow)));
  Real coeffMix[nSeg]=rMix*wInj/wInjTot;
  Real hMix = if port_a.m_flow > 0 then
                (inStream(port_a.h_outflow)+coeffMix*inStream(ports_b.h_outflow))/(1+rMix) else
                inStream(ports_b.h_outflow)*wInj/wInjTot;
  Real XiMix[Medium.nXi]=
              {if port_a.m_flow > 0 then
                  (XiIn_a[i]+coeffMix*XiIn_b[:,i])/(1+rMix)
               else wInj/wInjTot*XiIn_b[:,i] for i in 1:Medium.nXi};
  Modelica.SIunits.Temperature Tmix=
    if port_a.m_flow > 0 then
      Medium.temperature(Medium.setState_phX(port_a.p, hMix, XiMix))
    else
      Medium.temperature(Medium.setState_phX(port_a.p, hMix, wInj*inStream(ports_b.Xi_outflow)/wInjTot));

  Real Re = abs(port_a.m_flow)*coeff_Re "Reynolds number";
  Real Fr "Froude number";

  Real zMix = max(d, D*(7.09e-6*ResqrtDd*Fr^1.343*exp(-0.203e-6*ResqrtDd)));
  Real rMix = Re*Annex60.Utilities.Math.Functions.spliceFunction(x=port_a.m_flow,pos=0.007, neg=0.004, deltax=m_flow_nominal/1000);

  function mixingCorrelation
    "1st derivative of function that computes pressure drop for given mass flow rate"
    extends Modelica.Icons.Function;

    input Modelica.SIunits.Length ResqrtDd
      "Inlet diameter divided by tank diameter";
    input Modelica.SIunits.Length D "Tank diameter";
    input Real Fr "Froude number";
    output Real zMix;
  algorithm
   zMix:=D*(7.09e-6*ResqrtDd*Fr^1.343*exp(-0.203e-6*ResqrtDd));
   annotation (Inline=true);
  end mixingCorrelation;
protected
  Real XiIn_a[Medium.nXi];
  Real XiIn_b[nSeg,Medium.nXi];
  Real ResqrtDd=Re*sqrt(D/d) "Eliminated subexpression";
  final parameter Medium.ThermodynamicState state_default = Medium.setState_pTX(
      T=Medium.T_default,
      p=Medium.p_default,
      X=Medium.X_default[1:Medium.nXi]) "Medium state at default values";
  final parameter Modelica.SIunits.Density rho_default=Medium.density(
    state=state_default) "Density, used to compute fluid mass";

  final parameter Real coeff_v = rho_default*Modelica.Constants.pi*d^2/4
    "Coefficient for converting mass flow rate to velocity";
  final parameter Real coeff_Re = rho_default*d/coeff_v/Medium.dynamicViscosity(state_default)
    "Coefficient for efficient evaluation of Reynolds number - fixme: non-default state?";
  final parameter Real coeff_Fr =  1/coeff_v/sqrt(Modelica.Constants.g_n*beta*D);
  final parameter Modelica.SIunits.Length dh[nSeg] = hLay-fill(hIn,nSeg)
    "Height difference between inlet and outlets";

equation
  // The state for the Froude number decouples an algebraic loop
  // that would otherwise couple the enthalpy calculations and the mass flow rate calculations
  // this could possibly lead to very large algebraic loops
  der(Fr) =  (abs(port_a.m_flow)*coeff_Fr/max(0.01,abs(Tmix-Tin_a)^0.5)-Fr)/tau;
  port_a.h_outflow= hMix;
  ports_b.h_outflow=fill(hMix,nSeg)*(1+rMix) - inStream(ports_b.h_outflow)*rMix
    "Enthalpy that should flow to volumes after applying conservation of energy to fictive mass flow rate";
  XiIn_a[1:Medium.nXi]=inStream(port_a.Xi_outflow);
  XiIn_b=inStream(ports_b.Xi_outflow);
  ports_b.Xi_outflow=fill(XiMix,nSeg) "fixme: see h";
  port_a.Xi_outflow=XiMix;
  ports_b.m_flow = -port_a.m_flow*wInj/wInjTot;
  ports_b[1].p=port_a.p;

  annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}})));
end JetInflow;
