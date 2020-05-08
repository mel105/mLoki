function linePlot(signal, options)
    
  arguments
    signal double
    options.mXlabel (1, 1) string = "Time [idx]"
    options.mYlabel (1, 1) string = "Analysed Time Series"
    options.setChpIdx (1, 1) double = 0
    options.setMeanBf (1, 1) double = 0
    options.setMeanAf (1, 1) double = 0
  end
  
  %{
  % Version [0 0 1] prints last Version and update.
  if ~nargin
    
    Version = "[0 0 1]";
    LastUpdate = "2020-05-08";
    fprintf("f: Version of 'calcMjd': %s - last update: %s\n", ...
        Version, LastUpdate); 
    return;
  end
  %}
  
  import src.sinks.*
  
  assert(~isempty(signal));
  
  index = 1:1:length(signal);
  
  % External code. Defines plot properties
  [fig1, ax1, dc] = fig_open();
  
  %figure('Name', 'Original simulated data plot', 'NumberTitle', 'off');
  plot(ax1, index, signal, '-',...
    'LineWidth',2.5, ...
    'MarkerSize',4);
  
  if options.setChpIdx ~= 0
    hold on
    xline(options.setChpIdx, '--r', 'LineWidth', 3);
  end
  
  if options.setMeanBf ~= 0 && options.setChpIdx ~= 0
    bfVec = ones(options.setChpIdx,1) * options.setMeanBf;
    hold on
    plot(bfVec, '--y', 'LineWidth', 3);
  end
    
  if options.setMeanAf ~= 0 && options.setChpIdx ~= 0
    idx = options.setChpIdx+1:length(signal);
    afVec = ones(length(idx),1) * options.setMeanAf;
    hold on
    plot(idx, afVec, '--y', 'LineWidth', 3);
  end
  
  xlabel(options.mXlabel);
  ylabel(options.mYlabel);
  
  fig1.Visible = "on" ;
  dc.Enable = "off";
  dc.DisplayStyle = "window";
  
end