function A = dHarmFixPer(X, period, fit)
  
  A = zeros(length(X), length(fit));
  
  for i = 1:length(X)
    
    A(i,1) = 1.0;
    A(i,2) = X(i,1);
    
    
    %for j = 3:length(fit)
    j = 3;
     while j < length(fit) 
      
       A(i,j)    =          sin((j-1) * pi * X(i,1) / period + fit(j+1));
       A(i, j+1) = fit(j) * cos((j-1) * pi * X(i,1) / period + fit(j+1));
       
       j = j + 2;
    end
  end
end