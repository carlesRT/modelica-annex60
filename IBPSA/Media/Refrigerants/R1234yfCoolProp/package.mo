within IBPSA.Media.Refrigerants;
package R1234yfCoolProp "Refrigerant R1234yf. Source: CoolProp"
  extends ExternalMedia.Media.CoolPropMedium(
    mediumName = "R1234yf",
    substanceNames = {"R1234yf"},
    inputChoice = ExternalMedia.Common.InputChoice.ph,
    ThermoStates = Modelica.Media.Interfaces.Choices.IndependentVariables.ph
    );
end R1234yfCoolProp;
