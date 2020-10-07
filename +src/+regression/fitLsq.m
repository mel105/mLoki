function fit = fitLsq(X, fitCoef, varargin)
  
  import Src.Regression.*

  % default nastavenie
  DEFAULT_PERIOD = 365.25;
  DEFAULT_ORDER = 1;
  FIT_MODEL = "linear";
  
  % Prevzatie nastavenia
  kIdx = 1;
  while kIdx <= length(varargin)
    
    if ischar(varargin{kIdx})
      
      if varargin{kIdx} == "period"
        
        DEFAULT_PERIOD = varargin{kIdx+1};
        kIdx = kIdx + 1;
      elseif varargin{kIdx} == "order"
        
        DEFAULT_ORDER = varargin{kIdx+1};
        kIdx = kIdx + 1;
        
      elseif varargin{kIdx} == "model"
        
        FIT_MODEL = varargin{kIdx + 1};
        kIdx = kIdx + 1;
      else
        
        warning('Parameter is not recognized');
        disp(varargin{kIdx});
      end
    end
    
    kIdx = kIdx + 1;
  end
  
  N_PAR = length(fitCoef);
  [N, M] = size(X);
  
  %vX = zeros(N,1);
  %vY = zeros(N,1);
  
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
  
  fit0 = fitCoefInit(DEFAULT_ORDER, "harmonic");
  
  A = zeros(N, N_PAR);        % desing matrix
  COV = zeros(N_PAR, N_PAR);  % covariance matrix
  %vN = zeros(N_PAR, 1);
  %dp = zeros(N_PAR, 1);
  val = zeros(N, 1);
  %res = zeros(N, 1);
  fitEst = zeros(N, 1);
  %fitRes = zeros(N, 1);
  
  stopCrit = false;
  nIt = 0;
  maxIter = 100;
  
  while (stopCrit == false && nIt <= maxIter)
    
    nIt = nIt + 1;
    
    switch FIT_MODEL
      
      case "linear"
        
        disp("TBD")
      case "harmonic"
        
        val = vHarmFixPer(vX, DEFAULT_PERIOD, fit0); % tbd
      otherwise
        
        error("Model is not implemented!")
    end
    
    res = vY - val;
    
    % design matrix
    switch FIT_MODEL
      
      case "linear"
        
        disp("TBD")
      case "harmonic"
        
        A = dHarmFixPer(vX, DEFAULT_PERIOD, fit0); % tbd
      otherwise
        
        error("Model is not implemented!")
    end
    
    [COV, fit, dp] = lsq(A, fit0, res);
    
    switch FIT_MODEL
      
      case "linear"
        
        disp("TBD")
      case "harmonic"
        
        fitEst = vHarmFixPer(vX, DEFAULT_PERIOD, fit); % tbd
      otherwise
        
        error("Model is not implemented!")
    end
    
    fitRes =  vY - fitEst;
    
    % .convergence's test
    vN = dp ./ fit0;
    
    fit0 = fit;
    
    eps = 1e-3;
    if max(abs(vN)) <= eps && nIt > 2
      
      stopCrit = true;
    end
    
    if nIt == maxIter
      
      stopCrit = true;
    end
    
  end
  
  vDiag = diag(COV);
end