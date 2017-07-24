function freq = meg_fft(MEG,varargin)
%PURPOSE:   fft on MEG data
%AUTHOR:    Don Rojas, Ph.D.  
%INPUT:     Required: MEG structure - see get4D.m
%           Optional: 'derivative', 0|1 (default = 0) takes 1st temporal
%           derivative of data, which removes 1/f characteristic of fft.
%           This is essentially an AR(1) model effect (see Note 1)
%OUTPUT:    freq struct with fields:
%           .chn = channel labels for MEG data
%           .freq = frequency vector
%           .dat = complex data from fft (plot abs(freq.dat) if you want magnitude
%EXAMPLES:  freq = meg_fft(cnt);
%NOTES:     1) Removing 1/f characteristic. "If  f(t) = sin(w*t), then df/dt = w*cos(w*t)
%              So taking the derivative of a sine multiplies the output with "w" , which 
%              is the frequency in radians per second. This applies to each frequency. 
%              Taking the derivative is a linear operation, so if your data consists of the
%              sum of many sine-waves (which is the premise for Fourier analysis), taking the 
%              derivative of the data is equivalent to taking the derivative of all seperate 
%              sine-wave contributions to your data. The consequence hence is that the derivative 
%              in time results in the Fourier spectrum at frequency f being multiplied by 
%              f (for any frequency). So the 1/f effect in the spectrum is counteracted by a 1*f 
%              effect of the time-domain derivative. This can be considered as estimating and 
%              removing a 1-st order AR model from the data, except that we already know what the 
%              AR model parameters are. It can also be considered as a high-pass FIR filter with a 
%              filter kernel that is [-1 1]." (R. Oostenveld, FieldTrip listserv, Oct. 2011)
%TODO:       1) add options for lower and upper limits - consider using
%               freqz command instead of fft
%HISTORY:   11/22/11 - first working version

% defaults
deriv = 0;
hilim = 200;

% options
if ~isempty(varargin)
    optargin = size(varargin,2);
    if (mod(optargin,2) ~= 0)
        error('Optional arguments must come in option/value pairs');
    else
        for i=1:2:optargin
            switch varargin{i}
                case 'derivative'
                    deriv = varargin{i+1};
                case 'flim'
                    hilim = varargin{i+1};
                otherwise
                    error('Invalid option!');
            end
        end
    end
end
    
% get data and basic info
cind    = meg_channel_indices(MEG,'multi','MEG');
nchan   = length(cind);
switch MEG.type
    case 'epochs'
        MEG  = offset(MEG,[MEG.time(1) MEG.time(end)]);
        data = MEG.data(:,cind,:);
    otherwise
        data = MEG.data(cind,:);
end
data        = data*1e15; % scale to fT
N           = length(data);
f           = MEG.sr*(0:N/2-1)/N; 
tmp.freq    = f;
flim        = get_frequency_index(tmp,hilim);
freq.chn    = deal({MEG.chn(cind).label});
freq.freq   = f(1:flim);
freq.dat    = zeros(nchan,flim);

% take first temporal derivative if requested (removes 1/f characteristic)
if deriv
    data = diff(data,1,2);
end

% loop fft through channels
for chn=1:nchan
    fprintf('Computing fft on channel: %d\n', chn);
    switch MEG.type
        case 'epochs'
            ntrials = size(data,1);
            Y     = zeros(ntrials,flim);
            for trial=1:ntrials
                tmp              = fft(data(trial,:));
                tmp              = tmp(1:length(tmp)/2);
                Y(trial,1:flim)  = tmp(1:flim);
            end
            freq.dat(chn,:) = mean(abs(Y)); clear('Y');
        otherwise
            %win             = hamming(size(data,2))';
            %data            = data.*repmat(win,nchan,1);
            trial            = data(chn,:);
            tmp              = fft(trial);
            tmp              = tmp(1:round(length(tmp)/2));
            freq.dat(chn,:)  = tmp(1:flim);
    end
end

% rescale fft
%freq.dat = freq.dat.^2;            % square to maintain energy
%if rem(nfft,2)
%    freq.dat(:,2:end) = freq.dat(:,2:end)*2;
%else
%    freq.dat(:,2:end-1) = freq.dat(:,2:end-1)*2;
%end
% convert to dB power
% freq.dat = 20*log10(freq.dat + eps);