within IBPSA.Media.Refrigerants;
package R410ACoolProp "Refrigerant R410A. Source: CoolProp"
  extends ExternalMedia.Media.CoolPropMedium(
    mediumName = "R410A",
    substanceNames = {"R410A"},
    inputChoice = ExternalMedia.Common.InputChoice.ph
    );
end R410ACoolProp;
