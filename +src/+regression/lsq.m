function [COV, fit, dp] = lsq(A, fit0, Res)
  
  M  = A' * A;
  COV = inv(M);
  dp = M \ A' * Res;
  
  fit = fit0 + dp;
end