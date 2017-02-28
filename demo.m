function demo
%this function calculates the info contained in different temporal scales.
close all
max_firing_rate_1 = 0.1;
max_firing_rate_2 = 0.1;
scales = [9,21];%distances in bins between different peaks
width = 2;
background_firing_rate = 0;
max_jitter = 40;
step = 1;
num_bins = 200;
show_figures = 1;
verbose = 1;
%number of surrogates (number of shufflings for the bias correction)
num_sh = 0;
%num of trials per stimulus
num_trials_per_stim = 5000;
stimulus = [1;2];
max_num_spikes = 3;
results_folder = 'C:\Users\molano\Desktop\data\Scales\test\';

%this is the maximum jitter (in bins) added to each side of the spike time
jitt_mat = [0, step:step:max_jitter];
if ~exist(results_folder,'dir')
    mkdir(results_folder)
end

%simulate responses
patterns_original = build_responses_different_scales(num_bins,scales,width,'gaussian',max_jitter);
patterns_original(1,:) = max_firing_rate_1*patterns_original(1,:);
patterns_original(2,:) = max_firing_rate_2*patterns_original(2,:);
patterns_original = patterns_original + mean(patterns_original(:))*background_firing_rate;
patterns_original(:,1:max_jitter) = 0;
patterns_original(:,end-max_jitter:end) = 0;
patterns = repmat(patterns_original,num_trials_per_stim,1);
patterns = poissrnd(patterns);
presentations = repmat(stimulus,num_trials_per_stim,1);

%name of the file
name = ['frs_' num2str((max_firing_rate_1)) '_' num2str((max_firing_rate_2))...
    '_scales_' num2str((scales(1))) '_' num2str((scales(2)))...
    'width_' num2str((width)) '_bg_' num2str((background_firing_rate)) '_nsh_' num2str((num_sh))...
    '_ntr_' num2str((num_trials_per_stim))  '_nb_' num2str((num_bins))  '_stp_' num2str((step)) '_maxNSpks_' num2str((max_num_spikes))...
    '_mxjtt_' num2str((max_jitter)) '_stim_' num2str(stimulus') '_noCorr'];
name(strfind(name,' ')) = '_';
name(strfind(name,'__')) = '_';
name(strfind(name,'.')) = '';

IJD(patterns,presentations,num_sh,jitt_mat,show_figures,results_folder,name,max_num_spikes,verbose);
end

function rates = build_responses_different_scales(num_bins,scales,width,type,max_jitter)
%first peaks
if scales(2)<num_bins
    centre1 = num_bins/2 - (scales(1) + scales(2) + 1.1*max(max_jitter,scales(2)))/2;
else
    centre1 = num_bins/2 - (scales(1))/2;
end
centre2 = centre1 + scales(1);
%second peaks
centre3 = centre2+1.1*max(1.1*max_jitter,scales(2));
centre4 = centre3 + scales(2);

%1st STIMULUS RESPONSE
bins = 1:num_bins;
if isequal(type,'gaussian')
    rates1 = max([zeros(1,numel(bins));exp(-(bins-centre1).^2/width^2)]) +...
    max([zeros(1,numel(bins));exp(-(bins-centre3).^2/width^2)]) ;
elseif isequal(type,'square')
rates1 = max([zeros(1,numel(bins));1-abs(bins-centre1)/width]) +...
    max([zeros(1,numel(bins));1-abs(bins-centre3)/width]);
rates1(rates1<0 | rates1>1) = 0;
rates1(rates1~=0) = 1;
end

%2nd STIMULUS RESPONSE
if isequal(type,'gaussian')
    rates2 = + max([zeros(1,numel(bins));exp(-(bins-centre2).^2/width^2)]) + max([zeros(1,numel(bins));exp(-(bins-centre4).^2/width^2)]);
elseif isequal(type,'square')
    rates2 =  max([zeros(1,numel(bins));1-abs(bins-centre2)/width])+ max([zeros(1,numel(bins));1-abs(bins-centre4)/width]);
    rates2(rates2<0 | rates2>1) = 0;
    rates2(rates2~=0) = 1;
end
rates = [rates1;rates2];
end


