function fitCoefEst = harmonicRegression(X, order, period)
  
  import Src.Regression.*
  
  % asserts
  
  
  % Inicializuj koeficienty
  fitCoef = fitCoefInit(order, "harmonic");
  
  % Least square method application
  fitCoefEst = fitLsq(X, fitCoef, 'period', period, 'order', order, 'model', 'harmonic');  
end