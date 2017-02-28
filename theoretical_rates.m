function patterns_rates_th = theoretical_rates(rates,tau)
%this function calculates the rates for a
%given jitter (tau) added to the spike times.
if nargin==0
    rates = [[0 0.1 0];[0 0 0]]+0.01;
    tau = 1;
end


num_bins = size(rates,2);
%we first calculate the jittered rates and their derivative
patterns_rates_th = zeros(size(rates));
patterns_rates_th_derivative = zeros(size(rates));
%go over all bins 
for ind=1:num_bins
    %the set of bins that can influence the rate on the current bin depends on the jitter
    %the limits could be a bit tighter (limits = max([1,floor(ind-tau/2-1/2)]):min([num_bins,ceil(ind+tau/2+1/2)]))
    %but I just make sure I include all relevant bins.
    limits = max([1,floor(ind-tau/2-1)]):min([num_bins,ceil(ind+tau/2+1)]);
    for ind_bin=limits
        for ind_st=1:size(rates,1)
            %the rate in the given bin are just the sum of the rates
            %contributing to that bin weigthed by the values provided by
            %the formulas derived and computed by 'general_formula_rates' and
            %'general_formula_rates_derivatives'
            patterns_rates_th(ind_st,ind) = patterns_rates_th(ind_st,ind) + rates(ind_st,ind_bin)*general_formula_rates(ind,ind_bin,tau);
            patterns_rates_th_derivative(ind_st,ind) =...
                patterns_rates_th_derivative(ind_st,ind) + rates(ind_st,ind_bin)*general_formula_rates_derivatives(ind,ind_bin,tau);
        end
    end
end

end
