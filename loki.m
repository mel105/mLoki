clear variables;
close all;
clc;
% Details

import src.sinks.*

% USER SETTINGS
%   Data format/IO settings
userSetting.epochFmt = "Y-M-D h:m:s"; % neskor preber z nastavenia!
userSetting.fileName = "example.dat"; % neskor preber z nastavenia!
userSetting.foldName = "dat";
userSetting.sigLevel = 0.05; % neskor preber z nastavenia
userSetting.limitDependence = 0.4; % neskor preber z nastavenia
userSetting.detrendData = 1; % v pripade true odstranim linearny trend
userSetting.timeResolution = 1; % [day]
userSetting.filterModel = "medianFilter";
userSetting.multiChangePoint = 1; %
userSetting.segmentPlot = 1; % plot segment part.

% run loki
lokiObj = src.loki(userSetting);

% get basic info: versio, last update
%lokiObj.getVersion();

% {

[maxT, idxChp, meanBf, meanAf] = lokiObj.chpObj.getChpp;

% .plot
src.sinks.segmentPlot(lokiObj.prepObj.getTable.Detrend, ...
  sort(lokiObj.prepObj.getTable.Mjd),...
  lokiObj.getResTable.ChpIdx, "mXlabel", "Time [MJD]");


%shift = lokiObj.chpObj.getShift;
%critVal = lokiObj.chpObj.getCriticalValue;
%pVal = lokiObj.chpObj.getPVal;
%status = lokiObj.chpObj.getStatus;
