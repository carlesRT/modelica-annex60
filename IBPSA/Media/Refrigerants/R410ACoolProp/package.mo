within IBPSA.Media.Refrigerants;
package R410ACoolProp "Refrigerant R410A. Source: CoolProp"
  extends ExternalMedia.Media.CoolPropMedium(
    mediumName = "R410A",
    substanceNames = {"R410A"},
    inputChoice = ExternalMedia.Common.InputChoice.ph
    );

final constant Modelica.Units.SI.Temperature T_min=200
    "Minimum temperature for correlated properties. PropsSI('Tmin',ref.ref_name)";


end R410ACoolProp;
