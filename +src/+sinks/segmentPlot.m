function res = segmentPlot(signal, timeVec, chpVec, options)
    
  arguments
    signal double
    timeVec double
    chpVec double
    options.mXlabel (1, 1) string = "Time [idx]"
    options.mYlabel (1, 1) string = "Analysed Time Series"
    options.setChpIdx (1, 1) double = 0
    options.setMeanBf (1, 1) double = 0
    options.setMeanAf (1, 1) double = 0
  end
  
  
  import src.sinks.*
  import src.fnc.support.*
  
  assert(~isempty(signal));
  assert(~isempty(timeVec));
  assert(size(signal,1)==size(timeVec,1));
  assert(~isempty(chpVec));
  
  % .external code. Defines plot properties
  [fig1, ax1, dc] = fig_open();
  
  chpVec = sort(chpVec);
  
  % .prepare segments
  [interv, meanVec] = segmentStat(signal, chpVec);
  
  %figure('Name', 'Segment Plot', 'NumberTitle', 'off');
  plot(ax1, timeVec, signal, '.black', ...
    'LineWidth',2.5, ...
    'MarkerSize',4);
  for iO = 1:length(chpVec)
    xline(ax1, timeVec(chpVec(iO)), ':black', 'LineWidth', 2)
  end
  for iN = 1:size(interv,1)
    actTime = timeVec(interv(iN,1):interv(iN,2));
    actMean = ones(length(actTime),1).*meanVec(iN);
    plot(ax1, actTime, actMean, '-black', 'LineWidth', 4)
  end
        
  xlabel(options.mXlabel);
  ylabel(options.mYlabel);
  
  fig1.Visible = "on";
  dc.Enable = "off";
  dc.DisplayStyle = "window"; 
  hold off
  
  % .results
  res = struct("meanVec", meanVec, ...
               "interv", interv);
    
end