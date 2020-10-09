classdef chp < handle
  
  % Always set actual version
  % Version [0 0 1] 04.2020 Added 'prepareConstVectors' function
  % Version [0 0 2] 04.2020 Added 'estimateDependence' function
  % Version [0 0 3] 04.2020 Added 'estimateCritValue' function
  % Version [0 1 3] 04.2020 Basic functionality of change point detection alg. ToDo: problem with
  % large time series!!!
  % Version [0 1 4] 04.2020 Added 'normalizeSeries' function
  % Version [0 1 5] 04.2020 Added 'estimateSigmaStar' function
  % Version [0 1 6] 04.2020 Added 'updateCritValue' function
  % Version [0 1 7] 04.2020 Added 'estimatePval' function
  % Version [0 1 8] 04.2020 Added 'estimateShift' function
  % Version [0 1 9] 04.2020 Added 'estimateConfidenceInterval' function
  % Version [0 1 10] 04.2020 Added 'testHypo' function
  
  properties(Constant)
    
    Version = "[0 1 10]";
    
    LastUpdate = "2020-05-07";
  end
  
  properties (Access = protected)
    
    %> @details Analysed Time Series. It is given as (nx1) vector.
    analSeries
    
    %> @details Vector of k in 1, ..., N-1
    kIdxVec
    
    %> @details Vector of (n - k) constants
    nmkIdxVec
    
    %> @details Vector of sqrt((n-k)*k/n) constants
    cstIdxVec
    
    %> @details Vector of {T(k)} statistics
    tkVec
    
    %> @details max({T(k)}) statistic
    maxT
    
    %> @details index of max({T(k)}) statistic
    idxT
    
    %> @details mCoef for dependence estimation
    mCoef
    
    %> @details prob. for critical value estimation
    prob
    
    %> @details prob. for critical value estimation
    ciProb
    
    %> @details
    critValue
    
    %> @details Normalised series used for signal * estimation
    normalSeries
    
    %> @details sigma star parameter
    sigmaS
    
    %> @details
    limitDependence;
    
    %> @details
    normAcf
    
    %> @details
    pVal
    
    %> @details
    meanBfr
    
    %> @details
    meanAft
    
    %> @details
    shift
    
    %> @details
    analSeriesStatus
    
    %> @details
    skSq
    
    %> @details
    uppConfInter
    
    %> @details
    lowConfInter
  end
  
  methods (Access = public)
    
    %> @details Class constructor
    function obj = chp(datObj, prob, ciProb, limDep, detrendStatus, deseas, iB, iE)
      
      % .get data
      mTable = datObj.getTable();
      assert(~isempty(mTable), "No input data in the process of change point detection!")
      assert(iB > 0, "iB is non-possitive. Change the iB setting!");
      assert(iE <= height(mTable), "iE index is heigher that the data table length!")
      
      % .access data in mTable respecting the iB and iE indexes
      mTable = mTable(iB:iE, :);
      
      % .if detrended series is requested, then
      if detrendStatus
        
        assert(~isempty(mTable.Detrend), "No Input detrended data!")
        
        if deseas == "medianFilter" || deseas == "lsqFilter"
          
          obj.analSeries = mTable.Deseasonal;
        else
          
          obj.analSeries = mTable.Detrend;
        end
      else
                
        if deseas == "medianFilter" || deseas == "lsqFilter"
          
          obj.analSeries = mTable.Deseasonal;
        else
          
          obj.analSeries = mTable.Val;
        end
      end
      
      % .settings
      
      obj.prob = prob;
      obj.ciProb = ciProb;
      obj.limitDependence = limDep;
      %obj.analSeries = [1; 1; 2; 6; 5];
      
      % process the change point detection in the 'analSeries'
      processDetection(obj);
      
    end
    
    % get functions
    function [versionOut, lastUpdOut] = getVersion(obj)
      
      if nargout > 0
        
        versionOut = obj.Version;
        lastUpdOut = obj.LastUpdate;
      else
        
        fprintf("c: Version of 'chp': %s - Last update: %s\n", obj.Version, obj.LastUpdate);
      end
    end
    
    function acfOut = getNormAcf(obj)
      
      acfOut = obj.normAcf;
    end
    
    function shiftOut = getShift(obj)
      
      shiftOut = obj.shift;
    end
    
    function cvOut = getCriticalValue(obj)
      
      cvOut = obj.critValue;
    end
    
    function [maxTOut, idxTOut, m1, m2] = getChpp(obj)
      
      maxTOut = obj.maxT;
      idxTOut = obj.idxT;
      m1 = obj.meanBfr;
      m2 = obj.meanAft;
    end
    
    function tkVecOut = getTkVec(obj)
      
      tkVecOut = obj.tkVec;
    end
    
    function analSeriesOut = getAnalSeries(obj)
      
      analSeriesOut = obj.analSeries;
    end
        
    function pVal = getPVal(obj)
      
      pVal = obj.pVal;
    end
    
    function stat = getStatus(obj)
      
      stat = obj.analSeriesStatus;
    end
    
    function sigS = getSigmaStar(obj)
      
      sigS = obj.sigmaS;
    end
    
  end
  
  % Protected methods
  methods (Access = protected)
    
    function processDetection(obj)
      
      % prepare useful vecs
      prepareConstVectors(obj);
      
      % Estimate dependence
      estimateDependence(obj);
      
      % T statistics estimation
      estimateTStatistics(obj);
      
      % Estimate Crit. Value
      estimateCritValue(obj);
      
      % Normalize original series: clean series
      normalizeSeries(obj);
      
      % Estimate sigma star
      estimateSigmaStar(obj);
      
      % Update critVal
      updateCritValue(obj)
      
      % Estimate P-val
      estimatePval(obj); %fprintf('%4.15\nf', obj.pVal)
      
      % Estimate Shift
      estimateShift(obj);
      
      % Estimate Interval Confidence
      estimateConfidenceInterval(obj);
      
      % Test H0 hypothesis
      testHypo(obj);
      
    end
    
    %> @details estimate values of confidence interval for detected change point.
    function estimateConfidenceInterval(obj)
      
      % ToDo: Addaptation to sigma star is needed.
      
      P = [0.900 4.696;
        0.950 7.687;
        0.975 11.033;
        0.990 15.868;
        0.995 19.767];
      
      [pRow, ~] = find(P == obj.ciProb);
      
      if ~isempty(pRow)
        
        alpha = P(pRow, 2);
      elseif obj.ciProb < P(1,1)
        
        alpha = P(1,2);
      elseif obj.ciProb > P(end,1)
        
        alpha = P(end,2);
        
      else
        
        [ ~, ix ] = min( abs( P(:,1)-obj.ciProb ) );
        X = P(ix-1:ix,1);
        Y = P(ix-1:ix,2);
        alpha = interp1(X,Y,obj.ciProb);
      end
      
      tmpCoef = alpha * obj.skSq(obj.idxT)^2 / (obj.shift / 2);
      
      obj.uppConfInter = obj.idxT + tmpCoef;
      obj.lowConfInter = obj.idxT - tmpCoef;
      
    end
    
    %> @details estimate P value
    function estimatePval(obj)
      
      Tn2norm = obj.maxT / obj.sigmaS;
      
      an = sqrt(2.0 * log(log(length(obj.normalSeries))));
      bn = 2.0 * log(log(length(obj.normalSeries))) + ...
        0.5 * log(log(log(length(obj.normalSeries)))) - 0.5 * log(pi);
      
      y = an * Tn2norm - bn;
      obj.pVal = 1.0 - exp(-2.0 * exp(-y));
    end
    
    
    %> @details estimate shift value
    function estimateShift(obj)
      
      obj.shift = obj.meanAft - obj.meanBfr;
    end
    
    
    %> @details test zero hypothesis
    function testHypo(obj)
      
      if obj.maxT > obj.critValue
        
        obj.analSeriesStatus = true; % analysed series is non-stationary
      else
        
        obj.analSeriesStatus = false; % analysed series is stationary
      end
    end
    
    
    %> @details update critical value, if the condition is accepted
    function updateCritValue(obj)
      
      if obj.normAcf > obj.limitDependence
        
        obj.critValue = obj.critValue * obj.sigmaS;
      else
        
        %
      end
      
    end
    
    
    %> @details Function estimates value of sigma*
    function normalizeSeries(obj)
      
      obj.meanBfr = mean(obj.analSeries(1:obj.idxT));
      obj.meanAft = mean(obj.analSeries(obj.idxT+1:end));
      
      obj.normalSeries = obj.analSeries(1:obj.idxT) - obj.meanBfr;
      obj.normalSeries = [obj.normalSeries; obj.analSeries(obj.idxT+1:end) - obj.meanAft];
      
      %{
      plot(obj.analSeries)
      hold on
      plot(obj.normalSeries)
      legend("orig", "normal")
      %}
    end
    
    
    %> @details Function estimates value of sigma*
    function estimateSigmaStar(obj)
      
      N = length(obj.normalSeries);
      L = ceil( N^(1/3));
      acf = xcov(obj.normalSeries, 'normalized');  obj.normAcf = acf(N+1); 
      wgt = ones(1, L) - ((1:L) / L);
      
      f0est = acf(N) + 2.0 * wgt * acf(N + 1 : N + L);
      
      obj.sigmaS = sqrt(abs(f0est));
    end
    
    %> @details Function estimates critical value
    function estimateCritValue(obj)
      
      an = 1.0 / sqrt( 2.0 * log(log(length(obj.analSeries))) );
      bn = 1.0 / an + (an / 2.0) * log(log(log(length(obj.analSeries))));
      
      crvl = -log(-(sqrt(pi) / 2.0) * log(obj.prob));
      
      obj.critValue = (crvl*an) + bn;
    end
    
    %> @details functions estimates dependency coefficient
    function estimateDependence(obj)
      
      N = length(obj.analSeries);
      
      %acfVec = xcov(obj.analSeries, 'normalized');
      acfVec = xcov(obj.analSeries, 'biased');
      
      obj.mCoef = sqrt( (1.0 + acfVec(N)) / (1.0 - acfVec(N)) );
    end
    
    %> @details function prepares some useful vectors (full of constants)
    function prepareConstVectors(obj)
      
      assert(~isempty(obj));
      assert(~isempty(obj.analSeries) || ~isvector(obj.analSeries))
      
      nVals = length(obj.analSeries);
      
      obj.kIdxVec = 1:(nVals-1); obj.kIdxVec = obj.kIdxVec';
      
      obj.nmkIdxVec = nVals - obj.kIdxVec;
      
      obj.cstIdxVec = sqrt( (obj.kIdxVec .* obj.nmkIdxVec) ./ nVals );
      
      %disp([obj.kIdxVec, obj.nmkIdxVec, obj.cstIdxVec])
    end
    
    function estimateTStatistics(obj)
      
      
      N = length(obj.analSeries);
      
      %[obj.maxT, obj.idxT] = max(obj.tVec);
      
      % Zi - Z: i = 1:k
      sk = cumsum(obj.analSeries(obj.kIdxVec));
      z = sk ./ obj.kIdxVec;
      %partA  = table(obj.kIdxVec, sk, z, 'VariableNames', {'k', 'sk', 'z'});
      
      aMat = ones(length(obj.kIdxVec), N-1) .* obj.analSeries(1:N-1)'; aMat = tril(aMat);
      bMat = ones(length(obj.kIdxVec), N-1) .* z; bMat = tril(bMat);
      cMat = sum((aMat - bMat).^2, 2);
      
      % Zi - Zs: i = k+1:n
      SK = cumsum(obj.analSeries(end:-1:obj.kIdxVec+1));
      SK = rot90(rot90(SK));
      Z = SK ./ obj.nmkIdxVec;
      %partB  = table(obj.kIdxVec+1, SK, Z, 'VariableNames', {'k+1', 'SK', 'Z'});
      
      
      AMat = ones(length(obj.kIdxVec), N-1) .* obj.analSeries(2:N)'; AMat = triu(AMat);
      BMat = ones(length(obj.kIdxVec), N-1) .* Z; BMat = triu(BMat);
      CMat = sum((AMat - BMat).^2 ,2);
      
      obj.skSq = sqrt((cMat + CMat) ./ (N-2));
      
      obj.tkVec =  abs(obj.cstIdxVec .* (z - Z) ./ obj.skSq);
      
      [obj.maxT, obj.idxT] = max(obj.tkVec);
      %plot(obj.tkVec)
    end
  end
end