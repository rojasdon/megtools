function [bad fftrat freq] = fft_detect_bad_chn(MEG,thresh,varargin)
% PURPOSE: function to identify bad channels automatically by comparing fft
%          with median of neighboring channels
% AUTHOR:  Don Rojas, Ph.D. (credit to Dan Collins for idea)
% INPUT:   Required: MEG epoch structure - see get4D.m
%          thresh: threshold for standard deviation from mean)
%          notch: set to 1 to notch filter the powerline and 2 harmonics of
%          it. See notes.
%          fig: optional - plot good/bad fft data, set to 1 if desired
% OUTPUT:  bad = indices of bad channels
%          fftrat = ratios of channel to median channel
%          spect      = struct containing mean fft and frequencies
% EXAMPLE: [bad fftrat f] = fft_detect_bad_chn(cnt,2);
% NOTES:   1. 2 is decent threshold, but this can be modified as needed
%          2. Epoched data may or may not identify same channels depending
%          on whether data has been offset corrected, probably due to
%          concatenation of epochs and introduction of artificial
%          frequencies at epoch boundaries. Seems to be better without
%          baseline correction, but not thoroughly tested. Continuous and
%          averaged data generally produce similar results.
%          3. Preliminary testing indicated that notching the data in the
%          fft might reduce sensitivity to bad channels, possibly because
%          they sometimes pick up more power line artifact. Use cautiously.
%          4. Detecting bad channels seems to work best on average data. It
%          is also much faster, so computationally might be easier in
%          scripts to average first, then call this function, even if you
%          want to apply it to epoch or continuous data.
% HISTORY: 11/22/10 - first working version
%          12/14/10 - added notch filter option
%          06/02/11 - minor fixes to speed up code
%          06/15/11 - fixed bug with channel selection
%          09/23/11 - fixed output to be compatible with changes to deleter
%          11/22/11 - uses new fft function instead of computing fft within

tic;
% determine data type and do necessary things
switch MEG.type
    case {'avg' 'cnt'}
        data = MEG.data;
    case {'epochs'}
        fprintf('Warning: Use epoched data with caution. See help.\n');
        data = deepoch(MEG.data);
end
megi  = find(strcmp({MEG.chn.type},'MEG'));
data  = data(megi,:);
        
% detect bad channels using frequency domain
nchn = size(data,1);
freq = meg_fft(MEG,'flim',100);

% flatten channel locs to 2d
loc2d = double(thetaphi(MEG.cloc(megi,1:3)'));
loc2d = loc2d(1:2,:);

% find frequency indices of power line to notch out, +/- 1 Hz
% FIXME: make this generic for other countries
if nargin == 3 && varargin{1} == 1
    pl1 = find(f > 59 & f < 61);
    pl2 = find(f > 119 & f < 121);
    pl3 = find(f > 179 & f < 181);
    pl  = [pl1 pl2 pl3];
    freq.dat(:,pl) = 0;
end

% get 2d neighbors from each channel
d       = .3; % normed distance to define neighbors
nb      = cell(1,size(data,1));
for chn = 1:length(nb)   
    fprintf('Calculating neighbors for channel %d\n', chn);
    dist        = sqrt((loc2d(1,:)-loc2d(1,chn)).^2+(loc2d(2,:)-loc2d(2,chn)).^2);
    tmp         = find(dist < d);
    [~, ind]  = find(tmp == chn);
    tmp(ind)    = []; % do not include index channel in neighbors
    nb{chn}     = tmp;
end

% compare channels to median of neighbors
fftrat = zeros(nchn,length(freq.freq));
for chn = 1:nchn
    fprintf('Calculating fft ratios for channel %d\n', chn);
    avgfft      = mean(abs(freq.dat(nb{chn},:)));
    chnfft      = abs(freq.dat(chn,:));
    fftrat(chn,:) = bsxfun(@rdivide,chnfft,avgfft);
end

% bad channel indices
x          = mean(fftrat);
sd         = std(fftrat);
ratio_thrp = x+(thresh*sd);
ratio_thrn = x-(thresh*sd);
badh       = [];
badl       = [];
for ii = 1:length(ratio_thrp)
    [~, badh]   = find(fftrat(ii,:) > ratio_thrp);
    [~, badl]   = find(fftrat(ii,:) < ratio_thrn);
end
tmp         = sort([badl badh]);
fprintf('%d channels identified:\n',length(tmp));
bad = cell(1,length(tmp));
for chn = 1:length(tmp)
    fprintf('%s\n', MEG.chn(tmp(chn)).label);
    bad{chn} = MEG.chn(tmp(chn)).label;
end

% plot channels
if nargin > 3 && varargin{2} == 1
    figure('color','white','name','FFT results');
    good = abs(Y)*1e15; good(bad,:) = [];
    arti = abs(Y(bad,:))*1e15;
    plot(f,good(:,1:nfft/2),'g');
    hold on;
    plot(f,arti(:,1:nfft/2),'r');
    ylim([0 max(good(:))]); xlim([0 100]);
    xlabel('Hz'); ylabel('Amplitude');
end
t=toc;
fprintf('Process took %.4f seconds.\n',t);

end