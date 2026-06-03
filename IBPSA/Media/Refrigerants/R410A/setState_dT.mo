within IBPSA.Media.Refrigerants.R410A;
function setState_dT "Return state of refrigerant vapor Dummy values for pressure and enthalpy"

  input Modelica.Units.SI.Density d;
  input Modelica.Units.SI.Temperature T;

  output ThermodynamicState state;

algorithm
  state.d := d;
  state.T := T;
  state.h := 1;
  state.p := 1;


end setState_dT;
