within IBPSA.Media.Refrigerants;
package R32CoolProp "Refrigerant R32. Source: CoolProp"
  extends ExternalMedia.Media.CoolPropMedium(
    mediumName = "R32",
    substanceNames = {"R32"},
    inputChoice = ExternalMedia.Common.InputChoice.ph,
    ThermoStates = Modelica.Media.Interfaces.Choices.IndependentVariables.ph
    );
end R32CoolProp;
