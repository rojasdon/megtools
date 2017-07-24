function [mag chan] = findmaxfreq(MEG,freq)
%PURPOSE:   plots fft for all channels in array and finds peak channel and
%           power from channel
%AUTHOR:    Don Rojas, Ph.D.  
%INPUT:     Required: MEG structure - see get4D.m
%           freq = frequency to report in Hz
%OUTPUT:    mag = power at freq
%           chan = channel with maximum power at freq
%EXAMPLES:  [mag chan] = findmaxfreq(avg,40);
%TO DO:     1. separate plotting and finding components
%           2. fix scaling options and rel vs. total power issues
%SEE ALSO:  

%HISTORY:   03/24/11 - first working version


% currently only works with avg type
if ~strcmp(MEG.type,'avg'); error('This function requires average input'); end;
rel   = 1;
scale = 1e15; % use fT

% set up fft params
N    = size(MEG.data,2);
nfft = 2^nextpow2(N);
f    = (MEG.sr+1)/2*linspace(0,1,nfft/2);
upnt = ceil((nfft+1)/2);
f    = (0:upnt-1)*MEG.sr/nfft;
fftx = zeros(size(MEG.data,1),upnt);

% iterate the fft through the channels
for i=1:size(MEG.data,1)
    Y          = fft(MEG.data(i,:)*scale,nfft)/N;
    fftx(i,:)  = Y(1:upnt);
    if rel
        totpow = sum(abs(Y));
        relpow = Y/totpow;
    end
end

mx = abs(fftx); clear fftx;
mx = mx.^2;

% may need to implement to avoid DC and Nyquist components
%if rem(nfft, 2) % odd nfft excludes Nyquist point 
%  mx(2:end) = mx(2:end)*2;
%else
%  mx(2:end -1) = mx(2:end -1)*2;
%end

plot(f,mx); xlim([0 100]);
xlabel('Frequency (Hz)'); ylabel('Power (fT^2)');

% find peak channel and power at requested freq
[junk ind]  = min(abs(f - freq));
[junk chan] = max(mx(:,ind));
mag         = mx(chan,ind);

end