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
  % Version [0 2 1] 08.2020 Segmentation plot
    
  properties(Constant)
    
    Version = "[0 2 1]";
    
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
    segmentPlot % True - plot segmentation
    
    resTable = table();
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
    
    
    function resTable = getResTable(obj)
     
      resTable = obj.resTable;
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
      medianFilter = src.medianFilter.medianFilter();
      fprintf("f: Version of 'medianFilter': %s - last update: %s\n", ...
        medianFilter.Version, medianFilter.LastUpdate);          
      linearRegression = src.regression.linearRegression();
      fprintf("f: Version of 'linearRegression': %s - last update: %s\n", ...
        linearRegression.Version, linearRegression.LastUpdate);                      
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
       
       % Check filtring model
       if ~isempty(us.filterModel)
         
         if us.filterModel == "medianFilter" || us.filterModel == "lsqFilter"
                        
             obj.filterModel = us.filterModel;
         else             
             
             error('Unknown filter model!')
         end
       else
         
         % Original series is analysed
       end
       
       % Check detrendData setting
       switch us.detrendData
         
         case true
           
           obj.detrendModel = us.detrendData;
         otherwise
             
           % trend removing is not requested!
       end
         
       
       % Check multichange point setting
       if ~isempty(us.multiChangePoint)
         
         obj.multiChangePoint = us.multiChangePoint;
         
       else
         
         obj.multiChangePoint = false;
       end
      
       % Check time resolution
       if us.timeResolution ~= 0
         
         obj.timeResolution = us.timeResolution;
       end
       
        % Check if segment plot is true
       if us.segmentPlot == true
         
         obj.segmentPlot = us.segmentPlot;
       else
         
         obj.segmentPlot = false;
       end
    end
    
    function manageProcess(obj)
      
      % Load data
      obj.loadData();
      
      % Prepare data table
      obj.prepData();
      
      % .If requested, remove linear trend from the data
      if obj.detrendModel
        
        obj.detrendData();
      end
      
      switch obj.filterModel
        
        case "medianFilter"
          
          obj.medianFilter();
        case "lsqFilter"
          
          %obj.lsqFilter();
        otherwise
          
          % mala by sa spracovat originalna rada.
      end
      
      % {
      % Call method for change point detection
      obj.changePointDetection();
      % }
    end
    
    function detrendData(obj)
      
      % .call method to linear trend estimation
      detr = src.regression.linearRegression(obj.prepObj);
      
      % .prepObj.dataTable contains new column with detrended data.
      obj.prepObj.setNewCol(detr.detrendedSeries, "Detrend");
    end
    
    function medianFilter(obj)
      
      %[medianSeries, filtredSeries] = src.medianFilter.medianFilter(obj.prepObj);
      deseas = src.medianFilter.medianFilter(obj.prepObj, obj.timeResolution, obj.detrendModel);
    
      %plot(obj.prepObj.getTable.Detrend)
      %hold on
      %plot(deseas.medianSeries)
      %hold on
      %plot(deseas.filtredSeries)
      
      % .prepObj.dataTable contains new column with detrended data.
      obj.prepObj.setNewCol(deseas.filtredSeries, "Deseasonal");
    end
    
    function changePointDetection(obj)
      
      %resTable = table();
      res = [];
      iNo = 1;
      
      obj.chpObj = src.fnc.chp(obj.prepObj, obj.prob, obj.confInterProb, obj.limitDependece, ...
        obj.detrendModel, obj.filterModel, 1, height(obj.prepObj.getTable));

      [maxTOut, idxTOut, m1, m2] = obj.chpObj.getChpp;
      % results on screen
      %{
      fprintf("Velkost orig. suboru: %4.0f vs. velkost tk vec %4.0f \n", ...
        length(obj.chpObj.getAnalSeries), length(obj.chpObj.getTkVec));
      fprintf("change point estimation: maxTk %4.3f idx(maxTk) %4.0f  mean(bf) %4.3f  mean(aft)  %4.3f \n", maxTOut, idxTOut, m1, m2);
      fprintf("critical value: %4.3f \n",obj.chpObj.getCriticalValue);
      fprintf("p-value: %4.3f \n",obj.chpObj.getPVal);
      fprintf("Shift: %4.3f \n",obj.chpObj.getShift);
      fprintf("Status: %4.0f \n",obj.chpObj.getStatus);
      %}
      
      if obj.chpObj.getStatus
        
        
        res = [res; iNo, 1, height(obj.prepObj.getTable), ...
          height(obj.prepObj.getTable), idxTOut, maxTOut, obj.chpObj.getCriticalValue, ...
          obj.chpObj.getNormAcf, obj.chpObj.getPVal, obj.chpObj.getSigmaStar];
        
        iNo = iNo + 1;
      end
      
      %{
      figure(100)
      plot(obj.prepObj.getTable.Mjd, obj.prepObj.getTable.Val, '.')
      xlabel("TIME [MJD]")
      ylabel("X Crd")
      
      figure(200)
      subplot(2,1,1)
      plot(obj.chpObj.getAnalSeries, '.')
      hold on
      xline(idxTOut, '-r')
      subplot(2,1,2)
      plot(obj.chpObj.getTkVec,'.')
      hold on
      yline(obj.chpObj.getCriticalValue, '-black')
      hold on
      xline(idxTOut, '-r')
      %}
      
      % .multi-change point
      if obj.multiChangePoint == true && obj.chpObj.getStatus
        
        disp("Multi-Cahnge point detection")
      
        idxVec = [1; idxTOut;length(obj.chpObj.getAnalSeries)];
        
        statInter = []; % interval, kde cast casovej rady je uz stacionarna.
        interMat = src.fnc.support.prepareIntervals(idxVec, statInter);
        
        while (~isempty(interMat))
          
          %fprintf('\nIteration No: %2.0f\n', iNo);
        
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
                
                %{
                fprintf('\nAnalysed series from idx %4.0f to idx %4.0f: %4.0f - with status %4.0f\n', ...
                  jBeg, jEnd, idxTOut, obj.chpObj.getStatus);
                %}
                idxVec = [idxVec; idxTOut];
                
                res = [res; iNo, jBeg, jEnd, ...
                  jEnd - jBeg + 1, idxTOut, maxTOut, obj.chpObj.getCriticalValue, ...
                  obj.chpObj.getNormAcf, obj.chpObj.getPVal, obj.chpObj.getSigmaStar];
                
                %obj.resTable = [obj.resTable; {res}];
              else
                
                %{
                fprintf('\nAnalysed series from idx %4.0f to idx %4.0f: %4.0f - with status %4.0f\n', ...
                  jBeg, jEnd, idxTOut, obj.chpObj.getStatus);
                %}
                
                statInter = [statInter; jBeg, jEnd];
                %ifd = idxVec==jBeg; idxVec(ifd) = [];
              end
              
              idxIt = idxIt + 1;
              
              %{
              fprintf("Velkost orig. suboru: %4.0f vs. velkost tk vec %4.0f \n", ...
                length(obj.chpObj.getAnalSeries), length(obj.chpObj.getTkVec));
              [maxTOut, idxTOut, m1, m2] = obj.chpObj.getChpp;
              fprintf("change point estimation: maxTk %4.3f idx(maxTk) %4.0f  mean(bf) %4.3f  mean(aft)  %4.3f \n", maxTOut, idxTOut, m1, m2);
              fprintf("critical value: %4.3f \n",obj.chpObj.getCriticalValue);
              fprintf("p-value: %4.3f \n",obj.chpObj.getPVal);
              fprintf("Shift: %4.3f \n",obj.chpObj.getShift);
              fprintf("Status: %4.0f \n",obj.chpObj.getStatus);
              %}
              
              fI = interMat(:,1)==jBeg;
              interMat(fI,:) = [];
            end
            
            interMat = src.fnc.support.prepareIntervals(idxVec, statInter);
            
            if obj.chpObj.getStatus
              iNo = iNo + 1;
            end
            
          end
         
        end % end while loop
        
      end
      
      res(:,11) = res(:,7)./res(:,6);
      res(:,12) = 100 * (1 - res(:,11));
      res(:,13) = res(:,4)./height(obj.prepObj.getTable);
      res(:,14) = res(:,12) .* res(:,13);
      
      obj.resTable = array2table(res);
      obj.resTable.Properties.VariableNames = {'Idx', 'Beg', 'End', 'N', 'ChpIdx', 'maxTk', 'CritVal',...
        'NormAcf', 'pVal', 'Sigma*', 'CritVal/maxTk', '100*(1-CritVal/maxTk)', 'N/N_Tot',...
        '100*(1-CritVal/maxTk)*N/N_Tot'};
      
      
%      src.sinks.segmentPlot(obj.prepObj.getTable.Detrend, ...
%        obj.prepObj.getTable.Mjd,...
%       res(:,5), "mXlabel", "Time [MJD]");
      
      %{
      
      %disp(res(:,1:10))
      
      %fR = res(:,14)>10;
      %reduChpIdx = [res(fR, 5), res(fR, 13)];
      %gopeAntenna = [51486; 51749; 51821; 53755; 53930; 55179];
      %gopeReceiver = [50609; 50618; 51486; 51749; 51821; 52108; 55179; 55336];
      
      origChpIdx = res(:,5);
      
      src.sinks.segmentPlot(obj.prepObj.getTable.Detrend, ...
        obj.prepObj.getTable.Mjd,...
        origChpIdx, "mXlabel", "Time [MJD]");
      
      % .este odstranim tie podozrive chp odhady, ktorych n < 400 (mozno by tam mohla byti podmienka, ze v zavislosti na rozliseni, aby rada obsahovala viacej ako jeden rok.)
      idxSmallNum = res(:,4) < 400;
      res(idxSmallNum,:) = [];
      origChpIdx = res(:,5);
            
      import src.fnc.support.*
      [interv, meanVec] = segmentStat(obj.prepObj.getTable.Detrend, origChpIdx);
      
      % .Penalty calculations
      % C = sum_tauI+1^TauI ( Xt - mean)^2
      cost = zeros(size(interv, 1), 1);
 
      for iC = 1:size(interv, 1)
        
        actT = (interv(iC,1):interv(iC,2))';
        
        tmp = 0;
        for j = 1:length(actT)
          
          % Pozor tu musim parsrovat segmenty
          tmp = tmp + (obj.prepObj.getTable.Deseasonal(actT(j)) - meanVec(iC))^2;
        end
        
        cost(iC,1) = tmp / length(actT);
      end
      
      % .beta*f(m)
      mN = height(obj.prepObj.getTable);
      mV = var(obj.prepObj.getTable.Detrend);
      for i = 1:size(interv,1)
        
        mD = i;
        MAL = 2.0 * mV * mD/mN;
        BIC = mV * mD/mN * log(mN);
        PEN = mV * mD/mN * (2.0 * log(mN / mD) + 5.0);
      
%        fprintf('N/Var/Malows/BIC/PEN: %4.0f  %4.10f  %4.10f  %4.10f  %4.10f\n\n', ... 
%          mN, mV, MAL, BIC, PEN)
      end
      
      %format long
      crit = cost + BIC;
      
      %disp([crit, interv])
      %disp(["min: ", min(crit)])
      
      % .zisti si min(crit)
      minCritIdx = find(crit == min(crit));
      optNumChp = minCritIdx - 1;
      optChpIdx = origChpIdx(1:optNumChp);
      
      src.sinks.segmentPlot(obj.prepObj.getTable.Detrend, ...
        obj.prepObj.getTable.Mjd,...
        optChpIdx, "mXlabel", "Time [MJD]");
      
      
      % .Jaruskova
      %disp(length(origChpIdx))
      %[a, b] = mchpnewopr2015(obj.prepObj.getTable.Deseasonal, length(origChpIdx))
      %}
      % .get class version
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