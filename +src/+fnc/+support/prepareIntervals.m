function interval = prepareIntervals(intVec, statInterval)
  
  assert(size(intVec,1)>=3, 'Interval vector length is less than 3!')
  
  intVec = sort(intVec);
  
  interval = zeros(length(intVec)-1, 2);
  
  for i = 1:length(intVec)-1
    
    mBeg = intVec(i,1);
    mEnd = intVec(i+1,1);
    
    interval(i,:) = [mBeg, mEnd];
  end
  
  %statInterval = [statInterval; statInter];
  
  if ~isempty(statInterval)
    
    for iS = 1:size(statInterval,1)
      
      fnd = interval(:,1) == statInterval(iS,1);
      interval(fnd,:) = [];
    end
  end
end
