within IBPSA.Media.Refrigerants.R410A;
function density_pT "Return density of refrigerant vapor"
  input Modelica.Units.SI.AbsolutePressure p "Pressure of refrigerant vapor";
  input Modelica.Units.SI.Temperature T "Temperature of refrigerant vapor";

  output Modelica.Units.SI.Density d "Density of refrigerant vapor";


algorithm
  d :=1/specificVolumeVap_pT(p, T);


end density_pT;
