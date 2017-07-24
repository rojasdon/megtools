function ssp = resample_ssp(ssp,P,varargin)
% PURPOSE:  function to resample an MEG format to an arbitrary sample rate
% AUTHOR:   Don Rojas, Ph.D.
% INPUT:    MEG     = MEG struct from get4D.m
%           P       = new desired sample rate
%           ntrim   = n samples to eliminate if desired, from end of waveform
% OUTPUT:   MEG - resampled MEG data
% NOTES:    1. Not extensively tested. Beware when downsampling below
%           Niquist for desired frequencies and/or noise
% HISTORY:  11/18/11 - new code derived from resample_meg

tic;
% warning if new sr is below 200 Hz
if P < 200
    warning('New sample rate may be below that necessary for many analyses!');
end

% get input data
datsize                 = size(ssp.Q);
idata                   = ssp.Q;
ssp                     = rmfield(ssp,'Q');
ntrim                   = 0;
if nargin > 2
    ntrim = varargin{1};
end

% original sample rate
sr      = 1/(ssp.epdur/length(ssp.time));

% resample and construct output
Q       = double(round(sr)); % original rate
P       = double(P);         % new sample rate
nlen    = ceil(datsize(2)*P/Q); % nsamples in new epoch
odata   = zeros(datsize(1),nlen);
for ii=1:datsize(1)
    odata(ii,:) = resample(idata(ii,:),P,Q);
end

% repair time field
time1        = abs(ssp.time(1))/1e3;
time         = 1:size(odata,2);
time         = time*(1/P);
time         = time-time1;
if length(time) > size(odata,2)
    time(end)   = [];
end
ssp.time    = time(1:(end-ntrim));
ssp.Q       = odata(:,1:(end-ntrim));
stopt       = toc;
fprintf('Operation took %.2f seconds!\n',stopt);
end