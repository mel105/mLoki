%> DETAILS

classdef loki < handle
  
  
  % Always set actual version
  % Version [0 0 1] 04.2020 Function for input data control
  % Version [0 0 2] 04.2020 managerProcess development. Contains change point detection functions
  % Version [0 1 2] 04.2020 Basic functionality of change point estimation.
  % Version [0 1 3] 05.2020 Added user parameter - significant level
  % Version [0 1 4] 05.2020 Added getVersion
  % Version [0 1 5] 05.2020 First implementation of median filter
  % Version [0 1 6] 07.2020 Linear trend regression implementation (reg. coef, detrend)
  % Version [0 2 0] 07.2020 Multi-Change point process implementation
      
  properties(Constant)
    
    Version = "[0 2 0]";
    
    LastUpdate = "2020-08-10";
  end
  
  properties (SetAccess = protected, Hidden)
    
    %> @details
    dataReaderVers; dataReaderLastUpd 
    prepDataVers; prepDataLastUpd
    chpVers; chpLastUpd
    
    %> @details 
    prepObj
  end
    
  properties (SetAccess = protected)
    
    %> @details
    FileName
    
    %> @details
    EpochFmt
    
    %> @details
    FoldName
    
    %> @details
    YMD
    
    %> @details
    HMS
    
    %> @details
    VAL
    
    %> @details Significant level setting
    sigLevel
    
    %> @details Used for critical value estimation
    prob
        
    %> @details Used for critical value estimation
    confInterProb
        
    %> @details Used for updated critical value estimation
    limitDependece
    
    %> @details 
    chpObj
    
    %> @details 
    filterModel
    
    %> @details 
    medianSeries
    
    %> @details 
    filtredSeries
    
    %> @details
    detrendModel
    
    %> @details
    timeResolution
    
    %> @details 
    multiChangePoint % True - analyse multi-change point if exist
        
    %> @details
    resTable = table();
  end
  
  
  methods (Access = public)
    
    %> .class constructor
    function obj = loki(us)
      
      if (~nargin)
        
      end
      
      narginchk(1,1);
      
      obj.checkUserSetting(us)
      obj.setProb();
      obj.manageProcess()     
    end
    
    % .public functions
    % .get the matrix of results. Results are given in matlab table format.
    function resTable = getResTable(obj)
     
      resTable = obj.resTable;
    end
    
    % .get functions/classes version
    function getVersion(obj)
      % Static method: prints a Version of all classes or functions (if exists)
            
      narginchk(1,1)
      
      % Classes
      fprintf("c: Version of 'loki': %s - last update: %s\n", obj.Version, obj.LastUpdate);
      fprintf("c: Version of 'dataReader': %s - last update: %s\n", ...
        obj.dataReaderVers, obj.dataReaderLastUpd);
      fprintf("c: Version of 'prepareData': %s - last update: %s\n", ...
        obj.prepDataVers, obj.prepDataLastUpd);    
      fprintf("c: Version of 'chp': %s - last update: %s\n", ...
        obj.chpVers, obj.chpLastUpd);          
      
      % Functions
      calcMjd = src.fnc.mjd.calcMjd();
      fprintf("f: Version of 'calcMjd': %s - last update: %s\n", ...
        calcMjd.Version, calcMjd.LastUpdate);          
      epo2mjd = src.fnc.mjd.epo2mjd();
      fprintf("f: Version of 'epo2mjd': %s - last update: %s\n", ...
        epo2mjd.Version, epo2mjd.LastUpdate);          
      table2mjd = src.fnc.mjd.table2mjd();
      fprintf("f: Version of 'table2mjd': %s - last update: %s\n", ...
        table2mjd.Version, table2mjd.LastUpdate);          
      medianFilter = src.medianFilter.medianFilter();
      fprintf("f: Version of 'medianFilter': %s - last update: %s\n", ...
        medianFilter.Version, medianFilter.LastUpdate);          
      linearRegression = src.regression.linearRegression();
      fprintf("f: Version of 'linearRegression': %s - last update: %s\n", ...
        linearRegression.Version, linearRegression.LastUpdate);                      
    end
    
  end
  
  methods (Access = private)
    
    % .set statistical criteria
    function setProb(obj)
      
      obj.prob = 1.0 - obj.sigLevel;
      obj.confInterProb = 1.0 - obj.sigLevel/2; % two-side test
    end
    
    % .check user setting
    function checkUserSetting(obj, us)
      
      % .name of input file
      assert(us.fileName~= "" || ~isstring(us.fileName), ... 
         "loki::No input file!");
      
       % .TODO: check the file existence in 'dat' folder
       obj.FileName = us.fileName;
       
       % .check input data's epoch format
       if(us.epochFmt == "")
         
         obj.EpochFmt = "Idx";
       else
         
         obj.EpochFmt = us.epochFmt;
       end
       
       % .check folder name
       if(us.foldName == "")
         
         obj.FoldName = "dat";
       else
         
         obj.FoldName = us.foldName;
       end
       
       % .check significant level parameter setting
       if us.sigLevel < 0.0 || us.sigLevel > 1.0
         war_msg = ['Wrong value of significant level parameter setting. '...
                     'Parameter must be defined in interval (0,1). '...
                     'Default value of 0.95 is used!'];
         warning(war_msg);
         obj.sigLevel = 0.05;
       else
         obj.sigLevel = us.sigLevel;
       end
              
       % .check limit dependence. Parameter is used in case of critical value estimation. If acf
       % parameter in lag = 1 is over the limitDependence parameter, then the critical value depends
       % on 'sigma star' estimation.
       if us.limitDependence < 0.0 || us.limitDependence > 1.0
         war_msg = ['Wrong value of limit dependence parameter setting. '...
                    'Parameter is given in interval (0,1). Default value of 0.4 is used!'];
         warning(war_msg);
         obj.limitDependence = .4;
       else
         obj.limitDependece = us.limitDependence;
       end
       
       % .check the method for seasonal model elimination
       if ~isempty(us.filterModel)
         
         if us.filterModel == "medianFilter" || us.filterModel == "lsqFilter"
                        
             obj.filterModel = us.filterModel;
         else             
             
             error('Unknown filter model!')
         end
       else
         
         % .original series is analysed
       end
       
       % .check the method for trend elimination
       switch us.detrendData
         
         case true
           
           obj.detrendModel = us.detrendData;
         otherwise
             
           % .trend removing is not requested!
       end
         
       
       % .check multi-change point setting
       if ~isempty(us.multiChangePoint)
         
         obj.multiChangePoint = us.multiChangePoint;
         
       else
         
         obj.multiChangePoint = false;
       end
      
       % .check time resolution
       if us.timeResolution ~= 0
         
         obj.timeResolution = us.timeResolution;
       end
       
    end
    
    % .function for chnage point detection process managing
    function manageProcess(obj)
      
      % .load data
      obj.loadData();
      
      % .prepare data table
      obj.prepData();
      
      % .if requested: remove linear trend from the data
      if obj.detrendModel
        
        obj.detrendData();
      end
      
      % .if requested: remove seasonal model from the data
      switch obj.filterModel
        
        % .use median year model
        case "medianFilter"
          
          obj.medianFilter();
        % .use LSQ for seasonal data filter  
        case "lsqFilter"
          
          % not tested
          %obj.lsqFilter();
        otherwise
          
          % original data should be analysed (without any seasonal model elimination): not tested
          % yet.
      end
      
      % .call method for change point detection
      obj.changePointDetection();
    end
    
    % .manager function: trend elimination from the original data 
    function detrendData(obj)
      
      % .call method to linear trend estimation
      detr = src.regression.linearRegression(obj.prepObj);
      
      % .prepObj.dataTable contains new column with detrended data.
      obj.prepObj.setNewCol(detr.detrendedSeries, "Detrend");
    end
    
    % .manager function: seasonal model elimination from the original data.
    function medianFilter(obj)
      
      deseas = src.medianFilter.medianFilter(obj.prepObj, obj.timeResolution, obj.detrendModel);
    
      % .prepObj.dataTable contains new column with detrended data.
      obj.prepObj.setNewCol(deseas.filtredSeries, "Deseasonal");
    end
    
    function changePointDetection(obj)
      
      res = [];
      iNo = 1;
      
      obj.chpObj = src.fnc.chp(obj.prepObj, obj.prob, obj.confInterProb, obj.limitDependece, ...
        obj.detrendModel, obj.filterModel, 1, height(obj.prepObj.getTable));

      [maxTOut, idxTOut, ~, ~] = obj.chpObj.getChpp;
      
      if obj.chpObj.getStatus
        
        res = [res; iNo, 1, height(obj.prepObj.getTable), ...
          height(obj.prepObj.getTable), idxTOut, maxTOut, obj.chpObj.getCriticalValue, ...
          obj.chpObj.getNormAcf, obj.chpObj.getPVal, obj.chpObj.getSigmaStar];
        
        iNo = iNo + 1;
      end
      
      % .multi-change point
      if obj.multiChangePoint == true && obj.chpObj.getStatus
        
        idxVec = [1; idxTOut;length(obj.chpObj.getAnalSeries)];
        
        % .intervals of time series when the series is stationary
        statInter = []; 
        interMat = src.fnc.support.prepareIntervals(idxVec, statInter);
        
        while (~isempty(interMat))
          
          idxIt = 1;
          n = size(interMat, 1);
        
          while idxIt <= n
            
            jBeg = interMat(1,1);
            jEnd = interMat(1,2);
            
            % .call change point detection method
            obj.chpObj = src.fnc.chp(obj.prepObj, obj.prob, obj.confInterProb, obj.limitDependece,...
              obj.detrendModel, obj.filterModel, jBeg, jEnd);
            
            [maxTOut, idxTOut, ~, ~] = obj.chpObj.getChpp;
            
            idxTOut = idxTOut + jBeg;
            
            if (idxTOut == jBeg) || (idxTOut == jEnd)
              
              interMat = [];
              break;
            else
              
              % .new suspected change point index.
              if obj.chpObj.getStatus == 1
                
                idxVec = [idxVec; idxTOut];
                
                res = [res; iNo, jBeg, jEnd, ...
                  jEnd - jBeg + 1, idxTOut, maxTOut, obj.chpObj.getCriticalValue, ...
                  obj.chpObj.getNormAcf, obj.chpObj.getPVal, obj.chpObj.getSigmaStar];
              else
                
                % .statInter matrix update
                statInter = [statInter; jBeg, jEnd];
              end
              
              idxIt = idxIt + 1;
              
              fI = interMat(:,1) == jBeg;
              
              % .interMat update
              interMat(fI,:) = [];
            end
            
            % .interMat update
            interMat = src.fnc.support.prepareIntervals(idxVec, statInter);
            
            if obj.chpObj.getStatus
              
              iNo = iNo + 1;
            end
            
          end
         
        end % end while loop
        
      end
      
      % .CritVal/maxTk
      res(:,11) = res(:,7)./res(:,6);
      % .100*(1-CritVal/maxTk)
      res(:,12) = 100 * (1 - res(:,11));
      % .N/N_Tot
      res(:,13) = res(:,4)./height(obj.prepObj.getTable);
      % 100*(1-CritVal/maxTk)*N/N_Tot
      res(:,14) = res(:,12) .* res(:,13);
      
      obj.resTable = array2table(res);
      obj.resTable.Properties.VariableNames = {'Idx', 'Beg', 'End', 'N', 'ChpIdx', 'maxTk', ...
        'CritVal', 'NormAcf', 'pVal', 'Sigma*', 'CritVal/maxTk', '100*(1-CritVal/maxTk)', ...
        'N/N_Tot', '100*(1-CritVal/maxTk)*N/N_Tot'};
      
      % .get class version
      [obj.chpVers, obj.chpLastUpd] = obj.chpObj.getVersion();
    end
    
    % .prepare data for change point analysis
    function prepData(obj)
      
      obj.prepObj = src.fileIO.prepareData(obj.VAL, 'YMD', obj.YMD, 'HMS', obj.HMS);
      [obj.prepDataVers, obj.prepDataLastUpd] = obj.prepObj.getVersion();
    end
    
    % .load data
    function loadData(obj)
      
      dataFolderPath = fullfile(pwd, obj.FoldName);
      dataReaderObj = src.fileIO.dataReader(obj.FileName, dataFolderPath);
      
      obj.YMD = dataReaderObj.getYMD();
      obj.HMS = dataReaderObj.getHMS();
      obj.VAL = dataReaderObj.getVal();
     
      [obj.dataReaderVers, obj.dataReaderLastUpd] = dataReaderObj.getVersion();
            
    end
  end
  
end