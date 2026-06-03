within IBPSA.Media.Refrigerants;
package R32CoolProp "Refrigerant R32. Source: CoolProp"
  extends ExternalMedia.Media.CoolPropMedium(
    mediumName = "R32",
    substanceNames = {"R32"},
    inputChoice = ExternalMedia.Common.InputChoice.ph,
    ThermoStates = Modelica.Media.Interfaces.Choices.IndependentVariables.ph
    );

  final constant Modelica.Units.SI.Temperature T_min= 136.34
    "Minimum temperature for correlated properties. PropsSI('Tmin',ref.ref_name)";


end R32CoolProp;
