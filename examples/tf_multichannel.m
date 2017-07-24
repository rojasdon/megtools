% script to loop through MEG channels doing time-frequency analysis on all
% or subsets of sensors

infile  = '0030LAI1.BTI';
base    = '0030';
outmeg  = [base '_eps.mat'];
outtft  = [base '_tft.mat'];

% read meg file
trials = get37chn(infile);

% save meg file
save(outmeg,'trials');

chn2include = [1:35 37]; % a subset could be specified as follows [1 3 21:200 211]
low   = 10; % time-frequency options
hi    = 80;
waven = 7;

nchan = length(chn2include);

% do time-frequency by channel
for i=1:nchan
    tf(i) = TFT(trials,[low hi],chn2include(i),waven);
end

% compute/plot a mean nepower of all channels
tfsize = size(tf(1).mplf);
tmp = reshape([tf.nepower],tfsize(1),tfsize(2),nchan);
mtf = squeeze(mean(tmp,3));
figure('color','w');
contourf(tf(1).time,tf(1).freq,mtf,20,'linestyle','none');
title('Normalized Evoked Power'); xlabel('Time (ms)'); ylabel('Freq (Hz)');
h = colorbar(); ylabel(h,'Mean evoked power');

% save tf structure
save(outtft,'tf');