within IBPSA.Media.Refrigerants;
package R407CCoolProp "Refrigerant R407C. Source: CoolProp"
  extends ExternalMedia.Media.CoolPropMedium(
    mediumName = "R407C",
    substanceNames = {"R407C"},
    inputChoice = ExternalMedia.Common.InputChoice.ph,
    ThermoStates = Modelica.Media.Interfaces.Choices.IndependentVariables.ph
    );
end R407CCoolProp;
