% script using spm8 to do source analysis and signal space 
% projection computation on averaged dataset, applying projection back to 
% epoched dataset for time-frequency

% change path to dir containing a usable file

% spm eeg defaults
spm('defaults','eeg');

% load a file
D        = spm_eeg_load('bfm1040_spm.mat');
modality = spm_eeg_modality_ui(D, 1, 1);

val = 1;

% options configured for fieldtrip call - see spm_eeg_ft_dipolefitting.m
% assumes forward model done
vol         = D.inv{val}.forward(val).vol;
datareg     = D.inv{val}.datareg(val);
sens        = datareg.sensors;
M1          = datareg.toMNI;
[U,L,V]     = svd(M1(1:3, 1:3));
M1(1:3,1:3) = U*V';
vol         = forwinv_transform_vol(M1,vol);
sens        = forwinv_transform_sens(M1,sens);
chanind     = setdiff(meegchannels(D,modality),D.badchannels);

% get data and convert to ft
data        = D.ftraw(0); % convert to fieldtrip struct
data.trial  = data.trial(2);
data.time   = data.time(2);
cfg         = [];
cfg.channel = D.chanlabels(chanind);
data        = ft_timelockanalysis(cfg, data);

% do fit
cfg                 = [];
cfg.vol             = vol;
cfg.inwardshift     = 0;
cfg.grid.resolution = 20;
cfg.grad            = sens;
cfg.reducerank          = 2;

fitstart            = 80;
fitstop             = 100;
cfg.latency         = 1e-3*[fitstart fitstop];

source = ft_dipolefitting(cfg, data);

% plot config
cfg=[];
cfg.xparam='time';
cfg.xlim=[min(source.time) max(source.time)];
cfg.comment ='xlim';
cfg.commentpos='middlebottom';
cfg.electrodes='on';
cfg.rotate = 0;

if strcmp('EEG', modality)
    cfg.elec = sens;
else
    cfg.grad = sens;
end

% plot measured and modeled fields
figure;
subplot(1,2,1);
cfg.zparam='Vdata';
ft_topoplotER(cfg, source);
title('Data');
subplot(1,2,2);
cfg.zparam='Vmodel';
ft_topoplotER(cfg, source);
title('Model');

% convert dipole to MNI coordinates
Slocation = source.dip.pos;
Slocation(:,4) = 1;
Slocation = Slocation * (datareg.toMNI * inv(M1))';
Slocation = Slocation(:,1:3);



