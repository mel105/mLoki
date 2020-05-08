classdef prepareData < handle
  
  % Always set actual version
  % Version [0 0 1] 04.2020 Process loaded data in YYYY-MM-DD hh:mm:ss format and save the data into 
  % the table in Y M D h m s dmjd val format;
  properties(Constant)
    
    Version = "[0 0 1]";
    
    LastUpdate = "2020-05-07";
  end
  
  
  properties (Access = protected)
    
    %> @details cell array
    ymdCell
    
    %> @details cell array
    hmsCell
    
    %> @details vector<double>
    valVec
    
    %> @details table()
    subDataTable
    dataTable
  end
  
  methods (Access=public)
    
    %> @details class constructor
    function obj = prepareData(val, options)
      
      arguments
        val (:,1) double
        options.ymd (:, 3) double = [];
        options.hms (:, 3) double = [];
      end
      
      assert(~isempty(val), 'No available data!');
      obj.valVec = val;
      
      if ~isempty(options.ymd)
        obj.ymdCell = options.ymd;
      else
        %obj.ymdCell = cell(nVal, 3);
        obj.ymdCell = {};
      end
      
      if ~isempty(options.hms)
        obj.hmsCell = options.hms;
      else
        %obj.hmsCell = cell(nVal, 3);
        obj.hmsCell = {};
      end
      
      obj.prepareTable();
      
    end
    
    % get functions
    function dataTableOut = getTable(obj)
      
      % format: Y M D h m s dmjd val
      dataTableOut = obj.dataTable;
    end
    
    function [versionOut, lastUpdOut] = getVersion(obj)
      
      if nargout > 0
        
        versionOut = obj.Version;
        lastUpdOut = obj.LastUpdate;
      else
        
        fprintf("c: Version of 'prepareData': %s - Last update: %s\n", obj.Version, obj.LastUpdate);
      end
    end
  end
  
  methods (Access = protected)
    
    function prepareTable(obj)
      
      % Case study: in original data, the time string is given in format: yyyy-mm-dd hh:mm:ss
      if (~isempty(obj.ymdCell) && ~isempty(obj.hmsCell))
        
        ymdTablel = table((obj.ymdCell(:,1)), (obj.ymdCell(:,2)), ...
          (obj.ymdCell(:,3)), 'VariableNames', {'Year' 'Mont' 'Day'});
        hmsTablel = table((obj.hmsCell(:,1)), (obj.hmsCell(:,2)), ...
          (obj.hmsCell(:,3)), 'VariableNames', {'Hour' 'Min' 'Sec'});
        valTable = table(obj.valVec(:,1), 'VariableNames', {'Val'});
        
        obj.subDataTable = [ymdTablel, hmsTablel];
        
        mjdVec = src.fnc.mjd.table2mjd(obj.subDataTable);
        mjdTable = table(mjdVec(:,1), 'VariableNames', {'Mjd'});
        
        obj.dataTable = [ymdTablel, hmsTablel, mjdTable, valTable];
        
      else
        
        error('TBD');
      end
    end
  end
  
end