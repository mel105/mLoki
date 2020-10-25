% Founder Michal Elias
%
% Details
%  .table2mjd returns mjd (Modified Julian Date) values. 
%
% Inputs
%  .Y (int32) index of Year
%  .M (int32) index of Month
%  .D (int32) index of Day
%  .h (int32) index of Hour
%  .m (int32) index of Minute
%  .s (int32) index of Second
%
% Output
%  .mjd (double)
%
% Syntax
%  res = calcMjd(Y, M, D, h, m, s)
%
% Examples
%
% Reference

function dmjdVec = table2mjd(inpTable)

  % Version [0 0 1] get mjd calculated from table format
  if ~nargin
    dmjdVec = struct();
    dmjdVec.Version = "[0 0 1]";
    dmjdVec.LastUpdate = "2020-05-08";
    return;
  end
  
  assert(~isempty(inpTable) | size(inpTable,2)~=6)
  %{
  assert(inpTable.Year <= 2049 & inpTable.Year >= 1900)
  assert(inpTable.Mont < 1 | inpTable.Mont > 12)
  assert(inpTable.Day < 1 | inpTable.Day > 31)
  assert(inpTable.Hour < 1 | inpTable.Hour > 24)
  assert(inpTable.Min < 1 | inpTable.Min > 59)
  assert(inpTable.Sec > 59)
  %}
  
  
  dmjdVec = src.fnc.mjd.calcMjd(inpTable.Year, inpTable.Mont, inpTable.Day, ...
      inpTable.Hour, inpTable.Min, inpTable.Sec);
 %{
  for i = 1:n
    
    dmjdVec(i,1) = src.fnc.mjd.calcMjd( inpTable(i,1).Year, inpTable(i,2).Mont, inpTable(i,3).Day, ...
      inpTable(i,4).Hour, inpTable(i,5).Min, inpTable(i,6).Sec);
  end
  %}
end