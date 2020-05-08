clear variables;
close all;
clc;
% Details

import src.sinks.*

% USER SETTINGS
%   Data format/IO settings
userSetting.epochFmt = "Y-M-D h:m:s"; % neskor preber z nastavenia!
userSetting.fileName = "example2.csv"; % neskor preber z nastavenia!
userSetting.foldName = "dat";
userSetting.sigLevel = 0.05; % neskor preber z nastavenia
userSetting.limitDependence = 0.2; % neskor preber z nastavenia

% run loki
lokiObj = src.loki(userSetting);

% get basic info: versio, last update
lokiObj.getVersion();

[maxT, idxChp, meanBf, meanAf] = lokiObj.chpObj.getChpp;

% plot Analysed series
linePlot(lokiObj.chpObj.getAnalSeries, ...
  "mYlabel", "Analysed Data", ...
  "setChpIdx", idxChp, ...
  "setMeanBf", meanBf, ...
  "setMeanAf", meanAf )

% plot tk vector
linePlot(lokiObj.chpObj.getTkVec, ...
  "mYlabel", "TK", ...
  "setChpIdx", idxChp)


shift = lokiObj.chpObj.getShift;
critVal = lokiObj.chpObj.getCriticalValue;
pVal = lokiObj.chpObj.getPVal;
status = lokiObj.chpObj.getStatus;
