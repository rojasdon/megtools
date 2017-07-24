function [bad fftrat spect] = fft_detect_bad_chn(MEG,thresh,varargin)
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

% flatten channel locs to 2d
loc2d = double(thetaphi(MEG.cloc(megi,1:3)'));
loc2d = loc2d(1:2,:);

% set up fft params
N    = size(data,2);
nfft = 2^nextpow2(N);
f    = (MEG.sr+1)/2*linspace(0,1,nfft/2);
flim = get_index(f,200); % limit to 200 Hz
if isempty(flim)
    flim = length(f);
end

% do fft for all channels
Y = zeros(nchn,flim);
for chn = 1:size(data,1)
    fprintf('Computing fft on channel %d\n', chn);
    tmp              = fft(data(chn,:),nfft)/N;
    Y(chn,1:flim)    = tmp(1:flim);
end
spect.fft = mean(abs(Y));
spect.Hz  = f(1:flim);

% find frequency indices of power line to notch out, +/- 1 Hz
% FIXME: make this generic for other countries
if nargin == 3 && varargin{1} == 1
    pl1 = find(f > 59 & f < 61);
    pl2 = find(f > 119 & f < 121);
    pl3 = find(f > 179 & f < 181);
    pl  = [pl1 pl2 pl3];
    Y(:,pl) = 0;
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
fftrat = zeros(1,nchn);
for chn = 1:nchn
    fprintf('Calculating fft ratios for channel %d\n', chn);
    avgfft      = mean(abs(Y(nb{chn},1:flim)));
    chnfft      = abs(Y(chn,1:flim));
    fftrat(chn) = sum(bsxfun(@rdivide,chnfft,avgfft));
end

% bad channel indices
x           = median(fftrat);
sd          = std(fftrat);
ratio_thrp  = x+(thresh*sd);
ratio_thrn  = x-(thresh*sd);
[~, badp]   = find(fftrat > ratio_thrp);
[~, badn]   = find(fftrat < ratio_thrn);
badind      = [badp badn];
bad         = cell(1,length(badind));
fprintf('%d channels identified:\n',length(badind));
for chn = 1:length(badind)
    fprintf('%s\n', MEG.chn(badind(chn)).label);    
    bad{chn} = MEG.chn(badind(chn)).label;
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