within IBPSA.Media.Refrigerants;
package R407CCoolProp "Refrigerant R407C. Source: CoolProp"
  extends ExternalMedia.Media.CoolPropMedium(
    mediumName = "R407C",
    substanceNames = {"R407C"},
    inputChoice = ExternalMedia.Common.InputChoice.ph,
    ThermoStates = Modelica.Media.Interfaces.Choices.IndependentVariables.ph
    );

    final constant Modelica.Units.SI.Temperature T_min= 200
    "Minimum temperature for correlated properties. PropsSI('Tmin',ref.ref_name)";


end R407CCoolProp;
