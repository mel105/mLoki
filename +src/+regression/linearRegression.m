function res = linearRegression(dataObj, x, y)
  
  % Version [0 0 1] estimates and removes the linear trend from the input data.
  if ~nargin
    res = struct();
    res.Version = "[0 0 1]";
    res.LastUpdate = "2020-07-27";
    return;
  
  elseif nargin == 1
    
    Data = dataObj.getTable();
    x = Data.Mjd;
    y = Data.Val;
  else
    
    % dataObj is ignored
  end
  
  regCoef = polyfit(x, y, 1);
  
  res = struct('linearModel', polyval(regCoef, x), ...
               'detrendedSeries', y - polyval(regCoef, x));
    
  %{
  subplot(2,1,1)
  plot(y)
  hold on
  plot(res.linearModel)
  subplot(2,1,2)
  plot(res.detrendedSeries)
  %}
  
end