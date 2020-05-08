%> DETAILS

classdef loki < handle
  
  
  % Always set actual version
  % Version [0 0 1] 04.2020 Function for input data control
  % Version [0 0 2] 04.2020 managerProcess development. Contains change point detection functions
  % Version [0 1 2] 04.2020 Basic functionality of change point estimation.
  % Version [0 1 3] 05.2020 Added user parameter - significant level
  % Version [0 1 4] 05.2020 Added getVersion
  properties(Constant)
    
    Version = "[0 1 4]";
    
    LastUpdate = "2020-05-07";
        
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
    
    %> @details print Version of classes/functions
    %getVersionStatus = false;
    
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
  end
  
  
  methods (Access = public)
    
    %> @brief Konstruktor triedy
    %> @details
    %> @param
    %> @retval obj - object of class TemplateModule
    function obj = loki(us)
      
      if (~nargin)
        
      end
      
      narginchk(1,1);
      
      obj.checkUserSetting(us)
      obj.setProb();
      obj.manageProcess()     
      
    end
    
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
      
    end
    
  end
  
  methods (Access = private)
    
    function setProb(obj)
      
      obj.prob = 1.0 - obj.sigLevel;
      obj.confInterProb = 1.0 - obj.sigLevel/2; % two-side test
    end
    
    function checkUserSetting(obj, us)
      
      % Must be as input
      assert(us.fileName~= "" || ~isstring(us.fileName), ... 
         "(101)::No file on input!");
      
       obj.FileName = us.fileName;
       
       % Check epochFmt
       if(us.epochFmt == "")
         obj.EpochFmt = "Idx";
       else
         obj.EpochFmt = us.epochFmt;
       end
       
       % Check foldName
       if(us.foldName == "")
         obj.FoldName = "dat";
       else
         obj.FoldName = us.foldName;
       end
       
       % Check significant level
       if us.sigLevel < 0.0 || us.sigLevel > 1.0
         warning('Wrong value of Significant Level setting (must be defined in interval (0,1)). Default value of 0.95 is used!');
         obj.sigLevel = 0.05;
       else
         obj.sigLevel = us.sigLevel;
       end
              
       % Check limit dependence
       if us.limitDependence < 0.0 || us.limitDependence > 1.0
         warning('Wrong value of Limit Dependence setting (must be given in interval (0,1)). Default value of 0.4 is used!');
         obj.limitDependence = .4;
       else
         obj.limitDependece = us.limitDependence;
       end
      
    end
    
    function manageProcess(obj)
      
      % Load data
      obj.loadData();
      
      % Prepare data table
      obj.prepData();
                 
      % Call method for change point detection
      obj.changePointDetection();
    end
    
    function changePointDetection(obj)
            
      obj.chpObj = src.fnc.chp(obj.prepObj, obj.prob, obj.confInterProb, obj.limitDependece);
      [obj.chpVers, obj.chpLastUpd] = obj.chpObj.getVersion();
    end
    
    function prepData(obj)
      
      obj.prepObj = src.fileIO.prepareData(obj.VAL, 'YMD', obj.YMD, 'HMS', obj.HMS);
      [obj.prepDataVers, obj.prepDataLastUpd] = obj.prepObj.getVersion();
    end
    
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