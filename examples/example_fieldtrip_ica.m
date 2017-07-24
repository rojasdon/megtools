% example using Fieldtrip to do ica artifact removal. Fieldtrip uses EEGLAB
% runica algorithm by default but can use others

fieldtripdefs;

id          = '1070'; % change to your subject's id
file        = 'c,rfhp0.1Hz';
trigval     = 10;

% get file
cfg                        = [];
cfg.dataset                = 'c,rfhp0.1Hz,n';
cfg.trialdef.eventtype     = 'TRIGGER';
cfg.trialdef.eventvalue    = 4096+trigval; % needed for triggers which set bit 0
cfg.trialdef.prestim       = .2;
cfg.trialdef.poststim      = 1.0;
cfg = ft_definetrial(cfg);
cfg.channel                 = {'MEG'};
% cfg.channel                 = {'MEG', '-A117', '-A195'}; this is how you
% can delete bad channels right away
cfg.continuous              = 'yes';
ft                          = ft_preprocessing(cfg);

% use Fieldtrip function to review data
cfg                   = [];
cfg.continuous        = 'no';
%cfg.viewmode          = 'butterfly';
cfg.selectmode        = 'eval';
cfg.selcfg.layout     = '4D248.lay';
cfg.selfun            = 'browse_topoplotER';
cfg.channel           = 'MEG';
cfg = ft_databrowser(cfg,ft);

% do ica in Fieldtrip
cfg = [];
cfg.channel = 'MEG';
cfg.method  = 'runica';
cfg.runica.pca = 25;
ic_data = ft_componentanalysis(cfg,ft);

% plot component topography
cfg = [];
cfg.component = 1:25;
cfg.layout    = '4D248.lay';
cfg.comment   = 'no';
ft_topoplotIC(cfg,ic_data);

% plot timecourses of compoenents
cfg.continuous        = 'no';
cfg.viewmode          = 'component';
ft_databrowser(cfg,ic_data);

% prompt at command line in MATLAB for components to remove
fprintf('Enter component numbers to remove (e.g., [1:4, 10])\n');
noise = input('Which ones to remove? ');
cfg             = [];
cfg.component   = noise;
ft_rej          = ft_rejectcomponent(cfg,ic_data);

% average, first before
cfg             = [];
cfg.channel     = 'all';
cfg.trials      = 'all';
tmp             = ft_timelockanalysis(cfg,ft);
cfg             = [];
cfg.baseline    = [-.2 0];
before          = ft_timelockbaseline(cfg,tmp);
% then after
axis tight;
cfg             = [];
cfg.channel     = 'all';
cfg.trials      = 'all';
tmp             = ft_timelockanalysis(cfg,ft_rej);
cfg             = [];
cfg.baseline    = [-.2 0];
after            = ft_timelockbaseline(cfg,tmp);

% plot before and after averages
figure;
subplot(2,1,1);plot(before.time,before.avg); axis tight; xlabel('Before ICA');
subplot(2,1,2);plot(after.time,after.avg); axis tight; xlabel('After ICA');

% do whatever you like with your ica corrected data - you can put it back
% in the 4D software (put4D.m), convert to SPM directly (spm_eeg_ft2spm) 
% or continue to use a combination of tools from whatever package
% you like.
