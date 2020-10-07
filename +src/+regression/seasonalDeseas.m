function seasonalSeries = seasonalDeseas(X, fit, period)
  
  % asserts
  
  [N, M] = size(X);
  
  switch M
    
    case 1
      
      vX = 1:1:N;
      vX = vX';
      vY = X;
    case 2
      
      vX = X(:,1);
      vY = X(:,2);
    otherwise
      
      error("Problem s nastavenim vektoru X!")
  end
  
  seasonalSeries = zeros(length(X),1);
  
  for i = 1:length(X)
    
    seasonalSeries(i,1) = fit(1) + fit(2) * vX(i,1);
    
    j = 3;
    while j < length(fit)
      
      seasonalSeries(i,1) = seasonalSeries(i,1) + fit(j) * sin((j-1) * pi * vX(i,1) / period  + fit(j+1));
      j = j + 2;
    end
  end
 
  %{
  figure(300)
  plot(vX, vY)
  hold on
  plot(vX, seasonalSeries, '-r', 'LineWidth', 2)
  %}
end