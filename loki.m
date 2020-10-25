clear variables;
close all;
clc;

import src.sinks.*

%% .USER SETTINGS
% .Data format/IO settings
% .input data's time format: actually tested: Y-M-D h:m:s
%  (Y:Year, M:Month, D:Day, h:hour, m:month, s:second)
userSetting.epochFmt = "Y-M-D h:m:s";
% .data file name
userSetting.fileName = "example.dat";
% .data folder
userSetting.foldName = "dat";
% .significant level given from interval (0,1)
userSetting.sigLevel = 0.05; 
% .limit value of dependence. Used in case of critical value calculation. Given in interval (0,1).
userSetting.limitDependence = 0.4; %
% .boolean parameter. If true (1), original series is reduced by linear model
userSetting.detrendData = 1; % v pripade true odstranim linearny trend
% .input data time resolution (timestamp).
userSetting.timeResolution = 1; % [day]
% .method for time series de-seasonalisation. In today, a median filter (given by median year) 
% and LSQ are implemented and tested. 
userSetting.filterModel = "medianFilter";
% .boolean parameter. If true, then multi-change point is investigated
userSetting.multiChangePoint = 1; %

%% .RUN LOKI APPLICATION
lokiObj = src.loki(userSetting);

% .example of getting the results
%[maxT, idxChp, meanBf, meanAf] = lokiObj.chpObj.getChpp;


%shift = lokiObj.chpObj.getShift;
%critVal = lokiObj.chpObj.getCriticalValue;
%pVal = lokiObj.chpObj.getPVal;
%status = lokiObj.chpObj.getStatus;

%% .PLOT RESULTS
src.sinks.segmentPlot(lokiObj.prepObj.getTable.Detrend, ...
  sort(lokiObj.prepObj.getTable.Mjd),...
  lokiObj.getResTable.ChpIdx, "mXlabel", "Time [MJD]");

%% .GET VERSION
%lokiObj.getVersion();