% Founder Michal Elias
%
% Details
%  .medianFilter is a function for time series de-seasonalising. Seasonal model represents so-called
% 'median year' series. Each value of median year sequence is calculated as median from specific
% vector. For example, median value of January, 1st is calculated as median from all values of first
% Januaries. Thus, it is very important to analyse long time series to get robust median estimation.
%
% Inputs
%  .prepObj is data class object
%  .timeResolution (scalar) represents analysed time series time resolution
%  .trendModel (boolean). If true, then detrend the analysed data.
%
% Output
%  .res (struct)
%
% Syntax
%  res = medianFilter(prepObj, timeResolution, trendModel)
%
% Examples
%
% Reference


function res = medianFilter(prepObj, timeResolution, trendModel)
  
  % Version [0 0 1] First implementation of median series
  % Version [0 0 2] Some bugs removed
  
  res = struct();
  if ~nargin
    
    res.Version = "[0 0 2]";
    res.LastUpdate = "2020-07-31";
    return;
  end
  
  assert(~isempty(prepObj))
  
  inpTable = prepObj.getTable;
  medianData = zeros(12*31*timeResolution, 3);
  
  cnt = 1;
  for iM = 1:12
    
    for iD = 1:31
      
      idxVec = find(inpTable.Mont == iM & inpTable.Day == iD);
      
      if ~isempty(idxVec)
        
        switch trendModel
          
          case 1
            
            medVal = median(inpTable.Detrend(idxVec));
            
          otherwise
            medVal = median(inpTable.Val(idxVec));
        end
      end
      
      medianData(cnt,:) = [iM, iD, medVal];
      cnt = cnt + 1;
    end
  end
  
  totalIdx = height(inpTable);
  medianSeries = zeros(totalIdx,1);
  counter = 1;
  while counter <= totalIdx
    
    cp = find(medianData(:,1) == inpTable.Mont(counter) & medianData(:,2) == inpTable.Day(counter));
    if ~isempty(cp)
      
      medianSeries(counter,1) = medianData(cp,3);
    end
    
    counter = counter + 1;
  end
  
  res.medianSeries = medianSeries;
  switch trendModel
    
    case 1
      
      res.filtredSeries = inpTable.Detrend - medianSeries;
    otherwise
      
      res.filtredSeries = inpTable.Val - medianSeries;
  end
  
end