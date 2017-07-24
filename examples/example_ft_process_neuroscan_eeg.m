% defaults
[pth file ext]  =fileparts(which('ft_defaults')); % useful as there can be path issues
ft_defaults;
layout_dir      = fullfile(pth,'layout');
subid           = '1375';
trigval         = 41;

% read in dataset
cfg                         = [];
cfg.headerformat            =  'ns_cnt32'; % fieldtrip has problems without this format specifier
cfg.dataformat              =  'ns_cnt32';
cfg.eventformat             =  'ns_cnt32';
cfg.dataset                 = [subid 'click40session1.cnt']; % name of 4D file here
cfg.trialdef.eventtype      = 'trigger';
cfg.trialdef.eventvalue     = trigval; % a trigger value here
cfg.trialdef.poststim       = .8;
cfg.trialdef.prestim        = .2;
cfg                         = ft_definetrial(cfg);
cfg.reref                   = 'yes';
cfg.refchannel              = 'EEG';
cfg.baselinewindow          = [-.2 0];
cfg.demean                  = 'yes';
ft=ft_preprocessing(cfg);

% correct electrode labels, since fieldtrip uses lower case z, as in AFz
for ii=1:length(ft.label)
    if strcmp(ft.label{ii}(end),'Z')
        ft.label{ii}=[ft.label{ii}(1:end-1) 'z'];
    end
end

% view data
eegsel          = ft_channelselection('EEG',ft.label);
eogsel          = ft_channelselection('EOG',ft.label);
cfg             = [];
cfg.continuous  = 'no';
cfg.channel     = [eegsel;eogsel];
cfg.viewmode    = 'vertical';
cfg.ylim        = 'maxabs';
ft_databrowser(cfg,ft);

% ica to remove eyeblinks and/or ekg
cfg                     = [];
cfg.method              = 'fastica';
cfg.lasteig             = 25;
cfg.fastica.approach    = 'symm';
cfg.channel             = 'EEG';
ic_data                 = ft_componentanalysis(cfg,ft);

% view ica result and remove component(s)
cfg             = [];
cfg.layout      = 'easycapM1.mat';
cfg.comment     = 'no';
cfg.continuous  = 'no';
cfg.viewmode    = 'component';
ft_databrowser(cfg,ic_data);

% remove components
cfg_rem             = [];
cfg_rem.component   = [38,49];
ft_clean            = ft_rejectcomponent(cfg_rem,ic_data);

% average and baseline correct
ft_avg = ft_timelockanalysis([],ft_clean);
cfg    = [];
cfg.baseline = [-.2 0];
ft_avg = ft_timelockbaseline(cfg,ft_avg);

% plot average
cfg = [];
cfg.showlabels = 'yes';
cfg.layout = 'easycapM1.mat';
figure;ft_multiplotER(cfg,ft_avg);
cfg = [];
cfg.channel = 'FCz';
figure;ft_singleplotER(cfg,ft_avg);
