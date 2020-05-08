classdef dataReader < handle
  
  % Always set actual version
  % Version [0 0 1] 04.2020 Function data loading: able to lead data format:YYYY-MM-DD hh:mm:ss
  properties(Constant)
    
    Version = "[0 0 1]";
    
    LastUpdate = "2020-05-07";
  end
  
  properties (Access=protected)
    
    %> @details Data format
    DataFormat;
    
    %> @details Path to data file
    FilePath;
    
    %> @details YMD (year mon day) cell array
    YMD;
    
    %> @details HMS (hour min sec) cell array
    HMS;
    
    %> @details VAL (values) double vector
    VAL;
    
  end
  
  
  methods (Access = public)
    
    %> @brief class constructor
    %> @details
    function obj = dataReader(fileName, filePath, dataFmt)
      
      narginchk(2,3);
      
      assert(fileName~="", "No file name string!");
      assert(filePath~="", "No file path string!")
      
      if nargin < 3
        obj.DataFormat = "";
      else
        obj.DataFormat = dataFmt;
      end
      
      % Check fileName existance in the filePath folder
      obj.checkFile(fileName, filePath);
      
      if ~isempty(obj.FilePath)
        
        dataIn = strtrim(strsplit(fileread(obj.FilePath), '\n')');
        dataIn(cellfun(@isempty, dataIn)) = []; % remove empty line in dataIn.
        
        dataInSplited = split(dataIn, " ");
        ymd = convertCharsToStrings(split(dataInSplited(:,1), "-"));
        hms = convertCharsToStrings(split(dataInSplited(:,2), ":"));
        val = str2double(dataInSplited(:,3));
        
        if isempty(val)
          
          error('(202): No data in the file!')
        else
          
          obj.YMD = ymd;
          obj.HMS = hms;
          obj.VAL = val;
        end
        
      else
        
        error('(201): Can not open data file. FilePath is empty!')
      end
    end
    
    % Get functions
    function ymdCell = getYMD(obj)
      
      ymdCell = obj.YMD;
    end
    
    
    function hmsCell = getHMS(obj)
      
      hmsCell = obj.HMS;
    end
    
    
    function valVec = getVal(obj)
      
      valVec = obj.VAL;
    end
    
    function [versionOut, lastUpdOut] = getVersion(obj)
      
      if nargout > 0
        
        versionOut = obj.Version;
        lastUpdOut = obj.LastUpdate;
      else
        
        fprintf("c: Version of 'dataReader': %s - Last update: %s\n", obj.Version, obj.LastUpdate);
      end
    end
  end
  
  
  methods(Access=protected)
    
    
    %> @details Method checks a file existence and folder path.
    function checkFile(obj, fileName, filePath)
      
      if ~exist(filePath, 'dir')
        
        error('(203)::Folder "%s" does not exist!', filePath);
      else
        
        fileNamePath = fullfile(filePath, fileName);
        
        if ~exist(fileNamePath, 'file')
          
          error('(204)::File "%s" does not exist!', fileName);
        else
          
          obj.FilePath = fileNamePath;
        end
      end
    end
  end % end of proteced methods
  
end % classdef

%% HISTORY:
% --------------------------------------------------------------------------------------------------
%  18.04.2020 MEL
%  File development
% --------------------------------------------------------------------------------------------------