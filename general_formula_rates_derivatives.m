function rate = general_formula_rates_derivatives(i,k,tau)
%this function implements the formula for the rates derivative
if tau<2 && i-k==0
    rate = - 1/4;
elseif tau<=2*abs(i-k)-2
    rate = 0;
elseif tau>2*abs(i-k)-2 && tau<=2*abs(i-k)
    rate = -1/(2*tau^2) + abs(i-k)/(tau^2) - abs(i-k)^2/(2*tau^2) + 1/8;
elseif tau>2*abs(i-k) && tau<2*abs(i-k)+2 && abs(i-k)>0
    rate = -1/(tau^2) + 1/(2*tau^2) + abs(i-k)/(tau^2) - 1/8 + abs(i-k)^2/(2*tau^2);
elseif tau>=2*abs(i-k) + 2
    rate = -1/(tau^2);
end