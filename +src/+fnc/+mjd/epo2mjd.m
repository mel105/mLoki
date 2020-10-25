% Founder Michal Elias
%
% Details
%  .epo2mjd returns transformed time into mjd (Modified Julian Date) value. 
%
% Inputs
%  .year (int32) index of Year
%  .month (int32) index of Month
%  .day (int32) index of Day
%  .hour (int32) index of Hour
%  .minute (int32) index of Minute
%  .ssecond (double) index of Second
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

function mjd = epo2mjd(year, month, day, hour, min, sec)
  
  % Version [0 0 1] get dmjd calculated from year, month, day, hour, min, sec
  if ~nargin
    mjd = struct();
    mjd.Version = "[0 0 1]";
    mjd.LastUpdate = "2020-05-08";
    return;
  end
  
  %{
  % ToDo: asserts
  assert(year <= 2049 || year >= 1900)
  assert(month < 1 || month > 12)
  assert(day < 1 || day > 31)
  assert(hour < 1 || hour > 24)
  assert(min < 1 || min > 59)
  assert(sec > 59)
  %}
  
  mjd = src.fnc.mjd.calcMjd(year, month, day, hour, min, sec);
end