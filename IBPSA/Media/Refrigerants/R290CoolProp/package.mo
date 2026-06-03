within IBPSA.Media.Refrigerants;
package R290CoolProp "Refrigerant R290. Source: CoolProp"
  extends ExternalMedia.Media.CoolPropMedium(
    mediumName = "R290",
    substanceNames = {"R290"},
    inputChoice = ExternalMedia.Common.InputChoice.ph,
    ThermoStates = Modelica.Media.Interfaces.Choices.IndependentVariables.ph
    );
end R290CoolProp;
