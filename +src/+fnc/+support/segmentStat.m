function [interv, meanVec] = segmentStat(signal, chpVec)
  
  % .sorted chp indexes 
  chpVec = sort(chpVec);
    
  interv = [1, chpVec(1)];
  
  for iI = 1:length(chpVec)-1
  
    iBeg = chpVec(iI);
    iEnd = chpVec(iI+1);
    interv = [interv; iBeg, iEnd];
  end
  interv = [interv; chpVec(end), length(signal)];
  
  meanVec = zeros(size(interv,1), 1);
  for iM  = 1:size(interv,1)
    
    meanVec(iM,1) = mean(signal(interv(iM,1):interv(iM,2)));
  end
  
end