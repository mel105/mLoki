function deseasSeries = seasonalModelRegression(X, varargin)
  
  import Src.Regression.*
  
  % asserts
  assert(~isempty(X), 'Src:Regression: Input matrix is empty!')
    
  % default nastavenie
  model = "linear"; % default linear model. assert
  order = 1; % default linear model 
  
  % Setting parser
  kIdx = 1;
  while kIdx <= length(varargin)
    
    if ischar(varargin{kIdx})
      
      if varargin{kIdx} == "model"
        
        model = varargin{kIdx+1};
        kIdx = kIdx + 1;  
        
      elseif varargin{kIdx} == "order"
        
        order = varargin{kIdx+1};
        kIdx = kIdx + 1;
      else
        
        warning('Parameter is not recognized');
        disp(varargin{kIdx});
      end
    end
    
    kIdx = kIdx + 1;
  end
 
  
  switch model
    
    case "linear"
      
      warning("TBD")
    case "harmonic"
     
      % Harmonic regression
      % y = A + B*t + C*sin(2*pi*t/P + Phi): P = fixed = 365.25
      period = 365.25;
      fitCoef = harmonicRegression(X, order, period);
      
      % deseasonalization
      deseasSeries = X(:,2) - seasonalDeseas(X, fitCoef, period);
      
      %{
      figure(400)
      subplot(2,1,1)
      plot(X(:,1), X(:,2))
      subplot(2,1,2)
      plot(X(:,1), deseasSeries)
  %}
    case "polynomial"
      
      warning("TBD")
      
    otherwise
        
      error("Method is not implemented")
  end
  
end