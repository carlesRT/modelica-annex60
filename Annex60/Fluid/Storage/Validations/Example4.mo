within Annex60.Fluid.Storage.Validations;
model Example4
  extends Example1(combiTimeTable(fileName="test4.mat"), tan(T_start=285));
  annotation (experiment(StopTime=600), __Dymola_experimentSetupOutput(events=
          false));
end Example4;
