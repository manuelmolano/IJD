function [info_derivative,info] = IJD(responses,stimulus,num_sh,jitt_mat,show_figures,results_folder,name,max_num_spikes,verbose)
%this function takes a matrix response (number of trials x number of bins)
%and a stimulus identity vector and calculates the information and its
%derivative for the jitter values specified by jitt_mat.
screensize = get(groot,'Screensize');
num_bins = size(responses,2);
%calculate the average response to each stimulus
%also calculate the probability of each stimulus
stimuli = unique(stimulus);
patterns = zeros(numel(stimuli),size(responses,2));
stim_probs = zeros(1,numel(stimuli));
for ind_st=1:numel(stimuli)
    patterns(ind_st,:) = mean(responses(stimulus==stimuli(ind_st),:),1);
    stim_probs(ind_st) = nnz(stimulus==stimuli(ind_st))/numel(stimulus);
end

%this vector keeps the info for the different jitter values
info = nan(1,numel(jitt_mat));
H = nan(1,numel(jitt_mat));
HS = nan(1,numel(jitt_mat));

if show_figures
    %these variables will be used to plot the rates
    minimo = min(patterns(:));
    maximo = max(patterns(:));
    h4 = figure('name','rates','Position',[50 50 screensize(3)-100 screensize(4)-150]);
    hold on
end

%go over all jitter values
for ind_jitt=1:numel(jitt_mat)
    %this is the current jitter
    jitter = jitt_mat(ind_jitt);
    if jitter==0
        patterns_rates_th = patterns;
    elseif jitter>=1
        patterns_rates_th = theoretical_rates(patterns,jitter);
    else
        keyboard
    end
    %get all non-zero bins.
    indices = find(max(patterns_rates_th,[],1)>0);
    if verbose
        display(['jitter: ' num2str(jitter)])
        display(['num bins: ' num2str(numel(indices))])
        disp('---------------------------------')
    end
    %get entropies
    [entropy, cond_entropy] = entropies_calculation_stim_separate(patterns_rates_th,stim_probs,max_num_spikes);
   
    %get information
    info(ind_jitt) = -entropy + cond_entropy;
    H(ind_jitt) = -entropy;
    HS(ind_jitt) = -cond_entropy;
    num_subplots = 9;
    if  mod(ind_jitt-1,ceil(numel(jitt_mat)/num_subplots))==0 && show_figures %
        set(0,'CurrentFigure',h4)
        set(gca,'fontSize',16)
        subplot(ceil(sqrt(num_subplots)),ceil(sqrt(num_subplots)),(ind_jitt-1)/ceil(numel(jitt_mat)/num_subplots)+1)%
        hold on
        plot(patterns_rates_th','lineWidth',2)
        title(num2str(jitter))
        ylim([minimo maximo])
        xlim([0 num_bins+jitt_mat(end)])
        if ind_jitt==1
            xlabel('time (ms)')
            ylabel('f. rate')
        end
        
    end
end

%Bias correction: shuffle stimulus identity and calculate info.
info_sh = nan(num_sh,numel(jitt_mat));
for ind_sh=1:num_sh
    if mod(ind_sh,5)==0 && verbose
        display(['shuffling ' num2str(ind_sh)])
    end
    %build the shuffled rates
    patterns_sh = zeros(numel(stimuli),size(responses,2));
    stimulus_sh = stimulus(randperm(numel(stimulus)));
    for ind_st=1:numel(stimuli)
        patterns_sh(ind_st,:) = mean(responses(stimulus_sh==stimuli(ind_st),:),1);
    end
    for ind_jitt=1:numel(jitt_mat)
        %this is the actual jitter
        jitter = jitt_mat(ind_jitt);
        if jitter==0
            patterns_rates_th = patterns_sh;
        elseif jitter>=1
            patterns_rates_th = theoretical_rates(patterns_sh,jitter);
        end
        
        [entropy, cond_entropy] = entropies_calculation_stim_separate(patterns_rates_th,stim_probs,max_num_spikes);
        info_sh(ind_sh,ind_jitt) = -entropy + cond_entropy;
    end
end

%infoMax
info_max = zeros(size(info));
info_max_sh = zeros(size(info_sh));
for ind_jitt=1:numel(info)
    info_max(ind_jitt) = max(info(ind_jitt:end));
    info_max_sh(:,ind_jitt) = max(info_sh(:,ind_jitt:end),[],2);
end

%approximate the derivative dividing by the step
info_derivative = -diff(info_max)./diff(jitt_mat);
info_derivative_sh = -diff(info_max_sh,[],2)./repmat(diff(jitt_mat),num_sh,1);

%FIGURES
if show_figures
    h2 = figure('name','Info','Position',[50 50 screensize(3)-100 screensize(4)-150]);
    hold on
    h = area(jitt_mat,[prctile(info_max_sh,5,1);...
        prctile(info_max_sh,95,1)-prctile(info_max_sh,5,1)]','lineStyle','none');
    h(1).FaceColor = [1 1 1];
    h(2).FaceColor = [.8 .8 .8];
    plot(jitt_mat,info,'lineWidth',1,'color',[.6 .6 .6])
    plot(jitt_mat,info_max,'b','lineWidth',2)
    plot([jitt_mat(1) jitt_mat(end)],I_rate*ones(1,2),'--','lineWidth',2,'color',[.6 .6 .6])
    xlabel('jitter in bins')
    ylabel('info')
    
    h1 = figure('name',[name ' 1st derivative'],'Position',[50 50 screensize(3)-100 screensize(4)-150]);
    hold on
    h = area(jitt_mat(1:end-1)+diff(jitt_mat)/2,[prctile(info_derivative_sh,5,1);...
        prctile(info_derivative_sh,95,1)-prctile(info_derivative_sh,5,1)]','lineStyle','none');
    h(1).FaceColor = [1 1 1];
    h(2).FaceColor = [.8 .8 .8];
    
    plot(jitt_mat(1:end-1)+diff(jitt_mat)/2,info_derivative,'-','lineWidth',2)
    xlabel('jitter in bins')
    ylabel('info derivative')
end

save([results_folder name 'infoMax'],'info_derivative','info_derivative_sh','info','info_max','info_sh','info_max_sh','jitt_mat','patterns')
if show_figures
    saveas(h2,[results_folder name 'info jitter infoMax'],'png')
    saveas(h2,[results_folder name 'info jitter infoMax'],'fig')
    saveas(h4,[results_folder name 'original rates infoMax'],'png')
    saveas(h4,[results_folder name 'original rates infoMax'],'fig')
    saveas(h1,[results_folder name '1stDerivative infoMax'],'png')
    saveas(h1,[results_folder name '1stDerivative infoMax'],'fig')
end

end


function [entropy, cond_entropy] = entropies_calculation_stim_separate(patterns_rates_th,stim_probs,max_num_spikes)
indices = find(max(patterns_rates_th,[],1)>0);
%prob of having 0 spikes
p_r_s = prod(poisspdf(zeros(size(patterns_rates_th)),patterns_rates_th),2);
if stim_probs*p_r_s~=0
    entropy = (stim_probs*p_r_s)*log2(stim_probs*p_r_s);
end
aux =  p_r_s.*log2(p_r_s);
aux(p_r_s==0) = 0;
cond_entropy = aux;
%prob of having more than 0 spikes up to max_num_spikes
for ind_nSpk=1:max_num_spikes
    %all possible responses with ind_nSpk spikes. We allow several spikes to occur in the same bin
    active_bins = combinator(numel(indices),ind_nSpk,'c','r')';
    %tranform each possible response into a frequency vector (number of spikes per bin)
    if ind_nSpk==1
        %this is just a little trick so the function hist interprets the active bins as columns (even if they are one-row columns).
        active_bins_hist = hist([active_bins;active_bins],min(active_bins(:)):max(active_bins(:)))';
        %The frequency of each value will be doubled and so we divide by 2 afterwards.
        active_bins_hist = active_bins_hist/2;
    else
        active_bins_hist = hist(active_bins,min(active_bins(:)):max(active_bins(:)))';
    end
   
    p_r_s = zeros(numel(stim_probs),size(active_bins,2));
    for ind_st=1:numel(stim_probs)
        bins_aux = patterns_rates_th(ind_st,indices);
        indx_aux = sum(active_bins_hist(:,bins_aux==0)~=0,2)==0;
        p_r_s(ind_st,indx_aux) = prod(poisspdf(active_bins_hist(indx_aux,:),repmat(bins_aux,nnz(indx_aux),1)),2);
    end
    %remove impossible responses
    p_r_s(:,sum(p_r_s,1)==0) = [];
    %calculate entropy
    entropy = entropy + sum(stim_probs*p_r_s.*log2(stim_probs*p_r_s));
    %calculate conditional entropy
    aux =  p_r_s.*log2(p_r_s);
    aux(p_r_s==0) = 0;
    cond_entropy = cond_entropy + sum(aux,2);
end
cond_entropy = stim_probs*cond_entropy;
end

