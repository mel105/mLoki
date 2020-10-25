% Founder Michal Elias
%
% Details
%  .prepareData covers a functionalities for data preparing into the matlab table format

classdef prepareData < handle
  
  % Always set actual version
  % Version [0 0 1] 04.2020 Process loaded data in YYYY-MM-DD hh:mm:ss format and save the data into 
  % the table in Y M D h m s dmjd val format;
  % Version [0 0 2] 07.2020 Added public function setNewCol.
  % Version [0 0 3] 07.2020 Added leapyear identification
  % Version [0 0 4] 07.2020 Added function related with advanced data table.
  properties(Constant)
    
    Version = "[0 0 4]";
    
    LastUpdate = "2020-07-31";
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
    advancedTable
  end
  
  methods (Access=public)
    
    % class constructor
    % inputs: 
    %  val (double) input data vector
    %  arguments
    %    ymd (double) option data vector
    %    hms (double) option data vector
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
    
    % set functions
    function setNewCol(obj, newDataVec, varName)
      
      % .take control: if newDataVec lengths equals to val.size
      M = height(obj.dataTable);
      N = length(newDataVec);
      
      %head(obj.dataTable, 5)
      
      if M ~= N
        
        % what to do? Add zeros vector?
      else
        
        % .from newDataVec prepare table 
        obj.dataTable.(varName) = newDataVec;
       % obj.advancedTable.(varName) = newDataVec;
      end
      
      %head(obj.dataTable, 5)
      
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % get functions
    function dataTableOut = getTable(obj)
      
      % format: Y M D h m s dmjd val
      dataTableOut = obj.dataTable;
    end
    
    % Details
    % .get advanced table that contains leap days
    function dataTableOut = getAdvancedTable(obj)
      
      % format: Y M D h m s dmjd val
      dataTableOut = obj.advancedTable;
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
        
        ymdTable = table((obj.ymdCell(:,1)), (obj.ymdCell(:,2)), ...
          (obj.ymdCell(:,3)), 'VariableNames', {'Year' 'Mont' 'Day'});
        hmsTable = table((obj.hmsCell(:,1)), (obj.hmsCell(:,2)), ...
          (obj.hmsCell(:,3)), 'VariableNames', {'Hour' 'Min' 'Sec'});
        valTable = table(obj.valVec(:,1), 'VariableNames', {'Val'});
        
        obj.subDataTable = [ymdTable, hmsTable];
        
        mjdVec = src.fnc.mjd.table2mjd(obj.subDataTable);
        mjdTable = table(mjdVec(:,1), 'VariableNames', {'Mjd'});
        
        obj.dataTable = [ymdTable, hmsTable, mjdTable, valTable];
         
        % .advancedTable is dataTable copy. Contains leap day info
        obj.advancedTable = obj.dataTable;
        
        % prepare advanced (respecting leap year) table
        minYear = min(obj.dataTable.Year);
        maxYear = max(obj.dataTable.Year);
        idxNum = 0;
        for iYear = minYear:maxYear
          
          yStatus = obj.leapYear(iYear);
          %disp([iYear, yStatus])
          
          switch yStatus
            
            case 1
              
              % leap year. February, 29th exists.
            case 0
            
              % tu kod na doplnenie tabulky
              % najdem si index 28 dna
              [idx28, ~] = find(obj.dataTable.Year == iYear & ...
                           obj.dataTable.Mont == 2          & ...
                           obj.dataTable.Day == 28);
              idx29 = idx28+1;                         
              
              obj.addLeapDay(idx29, idxNum);
              idxNum = idxNum+1;
            otherwise
              
              error("Unknown status!")
          end
          
        end
        % remove zero years
        iZ = obj.advancedTable.Year == 0; obj.advancedTable(iZ,:) = [];
        %disp(obj.advancedTable)
        %disp([size(obj.dataTable), size(obj.advancedTable)])
        
      else
        
        error('TBD');
      end
    end
    
    % details
    function addLeapDay(obj, rowIdx, num)
      
      tmpTable = obj.advancedTable;
      
      if rowIdx ~= 1
        
        obj.advancedTable = tmpTable(1:rowIdx-1+num, : );
        tTable = tmpTable(rowIdx+num:end, :);
        
        obj.advancedTable(rowIdx+num, : ) = tmpTable(rowIdx+num-1, :);
        
        obj.advancedTable = [obj.advancedTable; tTable];
        obj.advancedTable.Day(rowIdx+num) = 29;
        obj.advancedTable.Mjd(rowIdx+num) = obj.advancedTable.Mjd(rowIdx+num)+1;
      end
    end
    
    % details
    function status = leapYear(obj, yr)
      
      leapyear = @(yr)~rem(yr,400)|rem(yr,100)&~rem(yr,4);
      
      status = leapyear(yr);
    end
  end
  
end %classdef