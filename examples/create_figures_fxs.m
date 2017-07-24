% create figures for Control Parent 3-mod paper

% assumes t-test results are all saved and can be loaded into workspace

% get corrected levels and masked t-scores
freqind    = 6:46;
data       = pvals.data(freqind,:);
mask       = pvals.mask(freqind,:);
ind        = find(mask);
nind       = find(pvals.mask == 0);
pdat       = pvals.data;
pdat(nind) = nan;
p          = data(ind);
[pID,pN]   = FDR(p,.05);
tdat       = tvals.data;
nind       = find(tvals.mask < 1);
tdat(nind) = NaN;
cscale     = [0 4];

% condition mean controls
figure('color','white','name','Phase-locked amplitude');
subplot(3,1,1); contourf(mean1.time,mean1.freq,mean1.data,20,'linestyle','none');
ylabel('Frequency (Hz)'); h = colorbar(); ylabel(h,'Normalized Amplitude');
title('Control Group'); caxis(cscale);
subplot(3,1,2); contourf(mean2.time,mean2.freq,mean2.data,20,'linestyle','none');
ylabel('Frequency (Hz)'); h = colorbar(); ylabel(h,'Normalized Amplitude');
title('FXS Group'); caxis(cscale);
subplot(3,1,3); contourf(tvals.time,tvals.freq,tdat,20,'linestyle','none');
ylabel('Frequency (Hz)'); xlabel('Time (ms)');
title('Group Comparison'); h = colorbar(); ylabel(h,'T-score');
%hold on; contour(pvals.time,pvals.freq,pvals.data,[pID pID],'w-');
%contour(pvals.time,pvals.freq,pvals.mask,[.9 .9],'k:');
hold on;
contour(pvals.time,pvals.freq,pdat,[.01 .01],'m-.'); % uncorrected p .01

% consider masking out < 20 Hz in all the testing