within IBPSA.Media.Refrigerants;
package R290CoolProp "Refrigerant R290. Source: CoolProp"
  extends ExternalMedia.Media.CoolPropMedium(
    mediumName = "R290",
    substanceNames = {"R290"},
    inputChoice = ExternalMedia.Common.InputChoice.ph,
    ThermoStates = Modelica.Media.Interfaces.Choices.IndependentVariables.ph
    );


  final constant Modelica.Units.SI.Temperature T_min= 85.525
    "Minimum temperature for correlated properties. PropsSI('Tmin',ref.ref_name)";

end R290CoolProp;
