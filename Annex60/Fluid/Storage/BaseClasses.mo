within Annex60.Fluid.Storage;
package BaseClasses "Base classes package"
  extends Modelica.Icons.BasesPackage;

  model JetInflow "Model for simulating jet inflow"
    replaceable package Medium = Modelica.Media.Interfaces.PartialMedium;

    parameter Integer nLay(min=10) "Number of layers in the storage tank";
    parameter Modelica.SIunits.MassFlowRate m_flow_nominal
      "Nominal mass flow rate, used for regularization only";
    parameter Modelica.SIunits.Volume Vlay[nLay] "Volume of each layer";
    parameter Modelica.SIunits.Length d "Diameter of inlet";
    parameter Modelica.SIunits.Length D "Diameter of tank";
    parameter Modelica.SIunits.Length hIn "Height of inlet center";
    parameter Modelica.SIunits.Length hLay[nLay] "Height of layer centers";
    parameter Real beta(final unit="K-1") = 0.43e-3
      "Volumetric expansion coefficient, default: water at approximately 50 degrees Celsius"
      annotation(Dialog(tab="Advanced"));
    Real[nLay] wInj = if port_a.m_flow > 0
                      then {min(1, max(0,1 -(dh[i]/zMix)^4) + (if hIn<hLay[i] and Tin_a >Tin_b[i] or hIn>hLay[i] and Tin_a <Tin_b[i] then 1 else 0)) for i in 1:nLay}
                      else  {exp(-6*(dh[i]/zMix))^2 for i in 1:nLay}
      "Weight for mass injection in each port";
    Real wInjTot = sum(wInj);

    Modelica.Fluid.Interfaces.FluidPort_a port_a(redeclare package Medium =
          Medium)
      annotation (Placement(transformation(extent={{-110,-10},{-90,10}})));
    Modelica.Fluid.Interfaces.FluidPort_b[nLay] ports_b(redeclare package
        Medium =
          Medium)
      annotation (Placement(transformation(extent={{90,-10},{110,10}})));

    Modelica.SIunits.Temperature Tin_a = Medium.temperature(Medium.setState_phX(port_a.p, inStream(port_a.h_outflow), inStream(port_a.Xi_outflow)));
    Modelica.SIunits.Temperature[nLay] Tin_b = Medium.temperature(Medium.setState_phX(ports_b.p, inStream(ports_b.h_outflow), inStream(ports_b.Xi_outflow)));
    Real coeffMix[nLay]=rMix*wInj/wInjTot;
    Real hMix = port_a.m_flow*(inStream(port_a.h_outflow)+coeffMix*inStream(ports_b.h_outflow))/(port_a.m_flow*(1+rMix));
    Real XiMix[Medium.nXi] = {port_a.m_flow*(XiIn_a[i]+coeffMix*XiIn_b[:,i]) for i in 1:Medium.nXi};
    Modelica.SIunits.Temperature Tmix = Medium.temperature(Medium.setState_phX(port_a.p, inStream(port_a.h_outflow), inStream(port_a.Xi_outflow)));

    Real Re = abs(port_a.m_flow)*coeff_Re "Reynolds number";
    Real Fr = abs(port_a.m_flow)*coeff_Fr*Annex60.Utilities.Math.Functions.inverseXRegularized(abs(Tmix-Tin_a)^0.5, 0.01)
      "Froude number";
    Real zMix = mixingCorrelation(Re,d/D,D,Fr);
    Real rMix = Re*Annex60.Utilities.Math.Functions.spliceFunction(x=port_a.m_flow,pos=0.007, neg=0.004, deltax=m_flow_nominal/1000);

    function mixingCorrelation
      "1st derivative of function that computes pressure drop for given mass flow rate"
      extends Modelica.Icons.Function;

      input Real Re "Reynolds number";
      input Modelica.SIunits.Length dD
        "Inlet diameter divided by tank diameter";
      input Modelica.SIunits.Length D "Tank diameter";
      input Real Fr "Froude number";
      output Real zMix;
    algorithm
     zMix:=D*(7.09e-6*Re*sqrt(dD)*Fr^1.343*exp(-0.203e-6*Re*sqrt(dD)));
     annotation (Inline=true);
    end mixingCorrelation;
  protected
    Real XiIn_a[Medium.nXi];
    Real XiIn_b[nLay,Medium.nXi];
    final parameter Medium.ThermodynamicState state_default = Medium.setState_pTX(
        T=Medium.T_default,
        p=Medium.p_default,
        X=Medium.X_default[1:Medium.nXi]) "Medium state at default values";
    final parameter Modelica.SIunits.Density rho_default=Medium.density(
      state=state_default) "Density, used to compute fluid mass";

    final parameter Real coeff_v = rho_default*Modelica.Constants.pi*d^2/4
      "Coefficient for converting mass flow rate to velocity";
    final parameter Real coeff_Re = d/coeff_v/Medium.dynamicViscosity(state_default)
      "Coefficient for efficient evaluation of Reynolds number";
    final parameter Real coeff_Fr =  1/coeff_v/sqrt(Modelica.Constants.g_n*beta*D);
    final parameter Modelica.SIunits.Length dh[nLay] = hLay-fill(hIn,nLay)
      "Height difference between inlet and outlets";

  equation
    port_a.m_flow+sum(ports_b.m_flow)=0;
    ports_b.h_outflow=fill(hMix,nLay);
    XiIn_a[1:Medium.nXi]=inStream(port_a.Xi_outflow);
    XiIn_b=inStream(ports_b.Xi_outflow);
    ports_b.m_flow = -ports_a.m_flow*(1+zMix)*wInj/wInjTot;

    annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
              -100},{100,100}})));
  end JetInflow;
end BaseClasses;
