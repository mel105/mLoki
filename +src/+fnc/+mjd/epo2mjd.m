function dmjd = epo2mjd(year, month, day, hour, min, sec)
  
  % Version [0 0 1] get dmjd calculated from year, month, day, hour, min, sec
  if ~nargin
    dmjd = struct();
    dmjd.Version = "[0 0 1]";
    dmjd.LastUpdate = "2020-05-08";
    return;
  end
  
  %{
  % ToDo: asserty
  assert(year <= 2049 || year >= 1900)
  assert(month < 1 || month > 12)
  assert(day < 1 || day > 31)
  assert(hour < 1 || hour > 24)
  assert(min < 1 || min > 59)
  assert(sec > 59)
  %}
  dmjd = src.fnc.mjd.calcMjd(year, month, day, hour, min, sec);
  
end