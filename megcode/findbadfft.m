% find bad chans using fft comparison with neighbors in Fieldtrip
% based on correlation with neighbors and mean + 3 SD on 60 Hz
function badchans = findbadfft(data,neighbors)

% find MEG channel labels
megchans = find(ft_chantype(data.label,'meg'));
meglabels = data.label(megchans);

% chop into 2-sec segments with .5 sec overlap
cfg = [];
cfg.length = 2;
cfg.overlap = 0.5;
data_2sec = ft_redefinetrial(cfg,data); clear data;
    
% spectral analysis
cfg              = [];
cfg.channel      = meglabels;
cfg.output       = 'pow';
cfg.method       = 'mtmfft';
cfg.pad          = 'nextpow2';
cfg.taper        = 'dpss';
cfg.tapsmofrq    = 1;             
cfg.keeptrials   = 'no';
datapow          = ft_freqanalysis(cfg,data_2sec);
[~,ind60]        = min(abs(datapow.freq - 60));

% compare channels with neighbors
clear p60;
for ii=1:length(datapow.label)
    chn = meglabels{ii};
    cind = find(ismember({neighbors.label},chn));
    nlabels = neighbors(cind).neighblabel;
    nind = find(ismember(meglabels,nlabels));
    cpow = datapow.powspctrm(ii,:);
    npow = mean(datapow.powspctrm(nind,:));
    [tmpr,tmpp] = corrcoef(cpow,npow);
    r(ii) = tmpr(2);
    p(ii) = tmpp(2);
    cpow60 = datapow.powspctrm(ii,ind60);
    npow60 = mean(datapow.powspctrm(nind,ind60));
    spow60 = std(datapow.powspctrm(nind,ind60));
    if cpow60 > npow60+(3*spow60)
        p60(ii) = 1;
    end
end
badind = unique([find(r<.8) find(p60)]);

% return channel labels
badchans = meglabels(badind);
for ii=1:length(badchans)
    badchans{ii} = ['-' badchans{ii}];
end