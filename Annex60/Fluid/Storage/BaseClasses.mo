within Annex60.Fluid.Storage;
package BaseClasses "Base classes package"
  extends Modelica.Icons.BasesPackage;

  model JetInflow "Model for simulating jet inflow"
    replaceable package Medium = Modelica.Media.Interfaces.PartialMedium;

    parameter Integer nLay "Number of layers in the storage tank";
    parameter Modelica.SIunits.Volume Vlay[nLay] "Volume of each layer";
    parameter Modelica.SIunits.Length d "Diameter of inlet";
    parameter Modelica.SIunits.Length D "Diameter of tank";
    parameter Modelica.SIunits.Length hIn "Height of inlet";
    parameter Modelica.SIunits.Length hLay[nLay] "Height of layer centers";
    Real[nLay] wInj = {min(1, if hIn<hLay[i] and Tin_a >Tin_b[i] then 1 else 0) for i in 1:nLay}
      "Weight for mass injection in each port";

    Modelica.Fluid.Interfaces.FluidPort_a port_a(redeclare package Medium =
          Medium)
      annotation (Placement(transformation(extent={{-110,-10},{-90,10}})));
    Modelica.Fluid.Interfaces.FluidPort_b[nLay] ports_b(redeclare package
        Medium =
          Medium)
      annotation (Placement(transformation(extent={{90,-10},{110,10}})));

    Modelica.SIunits.Temperature Tin_a = Medium.temperature(Medium.setState_phX(port_a.p, inStream(port_a.h_outflow), inStream(port_a.Xi_outflow)));
    Modelica.SIunits.Temperature[nLay] Tin_b = Medium.temperature(Medium.setState_phX(ports_b.p, inStream(ports_b.h_outflow), inStream(ports_b.Xi_outflow)));
    Modelica.SIunits.Temperature Tmix;

    Real Re = abs(port_a.m_flow)*coeff_Re "Reynolds number";
    Real Fr = abs(port_a.m_flow)*coeff_Fr*Annex60.Utilities.Math.Functions.inverseXRegularized(abs(Tmix-Tin_a)^0.5, 0.1);
    Real zMix = mixingCorrelation(Re,d/D,Fr);

    function mixingCorrelation
      "1st derivative of function that computes pressure drop for given mass flow rate"
      extends Modelica.Icons.Function;

      input Real Re "Reynolds number";
      input Modelica.SIunits.Length dD
        "Inlet diameter divided by tank diameter";
      input Real Fr "Froude number";
      output Real delta_z;
    algorithm
     delta_z:=D*(7.09e-6*Re*sqrt(dD)*Fr^1.343*exp(-0.203e-6*Re*sqrt(dD)));
     annotation (Inline=true);
    end mixingCorrelation;
  protected
    final parameter Medium.ThermodynamicState state_default = Medium.setState_pTX(
        T=Medium.T_default,
        p=Medium.p_default,
        X=Medium.X_default[1:Medium.nXi]) "Medium state at default values";
    final parameter Modelica.SIunits.Density rho_default=Medium.density(
      state=state_default) "Density, used to compute fluid mass";
    constant Real beta(final unit="K-1") = 0.43e-3
      "Volumetric expansion coefficient of water at approximately 50 degrees Celsius";
    final parameter Real coeff_v = rho_default*Modelica.Constants.pi*d^2/4
      "Coefficient for converting mass flow rate to velocity";
    final parameter Real coeff_Re = d/coeff_v/Medium.dynamicViscosity(state_default)
      "Coefficient for efficient evaluation of Reynolds number";
    final parameter Real coeff_Fr =  1/coeff_v/sqrt(Modelica.Constants.g_n*beta*D);

  equation
    port_a.m_flow+sum(ports_b.m_flow)=0;
    annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
              -100},{100,100}})));
  end JetInflow;
end BaseClasses;
