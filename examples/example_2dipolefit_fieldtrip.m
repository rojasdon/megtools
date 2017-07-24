% example of 2-dipole fit to auditory evoked field data

% spm and fieldtrip defaults
fieldtripdefs; spm('defaults','eeg'); 

% load files (SPM is used only for headmodel)
load 0976_ft.mat;
D = spm_eeg_load('fm0976_spm.mat');

% average, filter and baseline correction
cfg                 = [];
cfg.channel         = 'all';
cfg.trials          = 'all';
avg                 = ft_timelockanalysis(cfg,ft);
cfg                 = [];
cfg.lpfilter        = 'yes';
cfg.lpfreq          = 50;
cfg.lpfiltord       = 2;
avg                 = ft_preprocessing(cfg,avg);
cfg                 = [];
cfg.baseline        = [-.2 0];
avg                 = ft_timelockbaseline(cfg,avg);

% make a butterfly plot
figure; plot(avg.time*1e3,avg.avg*1e15); axis tight;

% plot it using Fieldtrip function
cfg         = [];
cfg.xlim    = [-0.2 1];
cfg.ylim    = [-1e-13 1e-13];
cfg.layout  = '4D248.lay';
cfg.showlabels = 'yes';
figure; multiplotER(cfg,avg);

% plot topography in Fieldtrip
cfg         = [];
cfg.comment = 'xlim';
cfg.commentpos = 'leftbottom';
cfg.xlim    = 0.015:.01:0.095;
cfg.zlim    = [-6e-14 6e-14];
cfg.layout  = '4D248.lay';
figure; ft_topoplotER(cfg,avg);

% configure head model
val         = 1;
modality    = spm_eeg_modality_ui(D, 1, 1);
vol         = D.inv{val}.forward(val).vol;
datareg     = D.inv{val}.datareg(val);
sens        = datareg.sensors;
M1          = datareg.toMNI;
[U,L,V]     = svd(M1(1:3, 1:3));
M1(1:3,1:3) = U*V';
vol         = ft_transform_vol(M1,vol);
sens        = ft_transform_sens(M1,sens);

% do fit - first pass is symmetrically constrained 2-dipole fit
cfg                 = [];
cfg.symmetry        = 'x';
cfg.numdipoles      = 2;
cfg.vol             = vol;
cfg.inwardshift     = 0;
cfg.grid.resolution = 8;
cfg.grad            = sens;
cfg.reducerank      = 2; % for gradiometers
cfg.latency         = 1e-3*[60 65];
src                 = ft_dipolefitting(cfg, avg);

% fit again using no symmetry constraint and last iteration as start
cfg                 = [];
cfg.numdipoles      = 2;
cfg.dip.pos         = src.dip.pos;
cfg.vol             = vol;
cfg.nonlinear       = 'yes';
cfg.gridsearch      = 'no';
cfg.grad            = sens;
cfg.reducerank      = 2; % for gradiometers
cfg.latency         = 1e-3*[60 75];
src                 = ft_dipolefitting(cfg, avg);

% plot fit on mri scan
mri = ft_read_mri('0976_corr.nii');
cfg = [];
cfg.location = src.dip.pos(1,:);
figure; ft_sourceplot(cfg,mri);

% do source space projection on dipoles to get source waveforms
% first left
pos = src.dip.pos(1,:); moment = mean(src.dip.mom,2);
L   = ft_compute_leadfield(pos,sens,vol); % see NOTES
Li  = pinv(L);
Qn  = double(moment(1:3))/norm(moment(1:3));
% compute weight vector
W = zeros(1,length(L),'single');
for i = 1:length(L)
    W(i) = dot(Li(:,i),Qn(1:3));
end
ntrials = length(ft.trial); nsamp = size(ft.trial{1},2);
ssp = zeros(ntrials,nsamp);
Wt   = repmat(W',1,nsamp);
for trial = 1:D.ntrials
    data         = ft.trial{trial};
    ssp(trial,:) = dot(data,Wt);
end