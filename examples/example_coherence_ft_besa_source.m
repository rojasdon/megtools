% example script for import of generic BESA format data and conversion to
% Fieldtrip structure for source coherence analysis

% read BESA source montage data (could also be exported sensor data)
filename    = 'KL2PD3EyePre-export';
[hdr dat]   = besa_readdat(filename);

% continuous data, so chop data into consecutive 2 sec pieces for FFT
segment = 2;
chunk   = floor(hdr.sr*segment);
extra   = rem(hdr.nsamp,chunk);
dat     = dat(:,1:end-extra);
trials  = size(dat,2)/chunk;
dat     = reshape(dat,hdr.nchan,chunk,trials);
time    = (1:chunk).*(1/hdr.sr);
for ii=1:trials
    ft.trial{ii} = squeeze(dat(:,:,ii));
    ft.time{ii}  = time;
end
for ii=1:hdr.nchan
    ft.label{ii} = num2str(ii);
end

% do frequency analysis in Fieldtrip
cfg             = [];
cfg.foi         = 1:1:55;
cfg.tapsmofrq   = 4;
cfg.output      = 'fourier'; % use 'pow' if all you want is the fft, but need this for coherence
cfg.method      = 'mtmfft';
freq            = ft_freqanalysis(cfg,ft);

% do coherence analysis in Fieldtrip
cfg             = [];
cfg.method      = 'coh'; % replace this with 'granger' for causality analysis
coh             = ft_connectivityanalysis(cfg,freq);

% do graph analysis from within Fieldtrip
cfg             = [];
cfg.method      = 'betweenness'; % or others, see help for function
cfg.parameter   = 'cohspctrm';
between         = ft_networkanalysis(cfg,coh);

% plot coherence results
cfg             = [];
cfg.parameter   = 'cohspctrm';
ft_connectivityplot(cfg,coh);