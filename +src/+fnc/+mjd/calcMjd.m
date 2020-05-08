function mjd = calcMjd(Y, M, D, h, m, s)
  
  % Version [0 0 1] get mjd calculated from Y, M, D, h, m, s
  if ~nargin
    mjd = struct();
    mjd.Version = "[0 0 1]";
    mjd.LastUpdate = "2020-05-08";
    return;
  end
  
  %{
  %TODO asserty
  assert(Y <= 2049 || Y >= 1900)
  assert(M < 1 || M > 12)
  assert(D < 1 || D > 31)
  assert(h < 1 || h > 24)
  assert(m < 1 || m > 59)
  assert(s > 59)
  %}
  
  if M <= 2
     Y = Y - 1;
     M = M + 12;
  end
  
  i = floor(Y / 100);
  k = floor(2 - i + i/4);
  
  mjd = (floor(365.25 * Y) + floor(30.6001 * (M + 1)) + D + k - 679006.0);
  sod = (h * 3600.0) + (m * 60.0) + s;
  
  mjd = mjd + (sod/24)/3600;
end