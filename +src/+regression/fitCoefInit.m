function fit = fitCoefInit(order, model)
  
  %asserts
  
  switch model
    
    case "harmonic"
      
      fit = ones(2+order*2, 1);
    otherwise
      
      error("Model is not implemented!");
  end
end