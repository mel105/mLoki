function val = vHarmFixPer(X, period, fit)
  
  val = zeros(length(X),1);
  
  for i = 1:length(X)
    
    val(i,1) = fit(1) + fit(2)*X(i,1);
    j = 3;
    %for j = 3:length(fit)
    while j < length(fit)  
    
      val(i,1) = val(i,1) + fit(j) * sin((j-1) * pi * X(i,1) / period  + fit(j+1));
      j = j + 2;
    end
  end
end