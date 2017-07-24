% example simulated dataset and source analyses

file = 'c,rfhp0.1Hz';
hdr  = ft_read_header(file);
hs   = ft_read_headshape('hs_file');

% trial vectors for simulation
fs      = hdr.Fs;
t       = 0:1/fs:1;
x       = -.2:1/fs:1;
pret    = -.2:1/fs:0;
pre     = zeros(1,length(pret));
Hz      = 25;
AM      = 1-cos(2*pi*1*t);
ntrials = 100;
for i=1:ntrials % trials
    amp=fix(rand(1)*5)+1; %random amplitude for each wave
    tmp=amp*sin(2*pi*Hz*t).*AM;
    tmp=[pre tmp];
    noise=randn(1,length(tmp));
    trials{i} = tmp+noise;
end

% volume conductor
cfg_vol                 = [];
cfg_vol.grad            = hdr.grad;
cfg_vol.headshape   	= hs.pnt;
cfg_vol.singlesphere    = 'yes';
cfg_vol.feedback        = 'no';
vol                     = ft_prepare_localspheres(cfg_vol);
vol.unit                = 'm'; %check might be mm

% simulate a single dipole
cfg_sim.vol            = vol;
cfg_sim.grad           = hdr.grad;
cfg_sim.dip.pos        = [-.01 .05 .06]; % position in meters ap,lr,is (neg is right)
cfg_sim.dip.mom        = [0 0 -1]';
cfg_sim.dip.signal     = trials;
cfg_sim.fsample        = hdr.Fs;
sim                    = ft_dipolesimulation(cfg_sim);
for i=1:ntrials
    sim.time{i} = x;
end

% average simulation
cfg_base.baseline       = [-.2 0];
ft_dip_avg              = ft_timelockanalysis([],sim);
ft_dip_avg              = ft_timelockanalysis(cfg_base,ft_dip_avg);

% plot simulation
cfg_ploter = [];
cfg_ploter.channel = 'MEG';
cfg_ploter.layout  = '4D248.lay';
cfg_ploter.showlabels='yes';
figure;ft_multiplotER(cfg_ploter,ft_dip_avg);

% plot topography
cfg_topoplot = [];
cfg_topoplot.xlim = [.5 .5];
cfg_topoplot.channel = 'MEG';
cfg_topoplot.layout  = '4D248.lay';
figure;ft_topoplotER(cfg_topoplot,ft_dip_avg);

% select time periods of interest in Fieldtrip data
cfg_toi         = [];
cfg_toi.toilim  = [-.2 0];
dataPre         = ft_redefinetrial(cfg_toi,ft_dip_avg);
cfg_toi.toilim  = [.1 .3];
dataPost        = ft_redefinetrial(cfg_toi,ft_dip_avg);

% frequency analysis on time periods
cfg_freq             = [];
cfg_freq.method      = 'mtmfft';
cfg_freq.channel     = 'MEG';
cfg_freq.channelcmb  = {'MEG' 'MEG'};
cfg_freq.output      = 'powandcsd';
cfg_freq.tapsmofrq   = 4;
cfg_freq.foilim      = [25 25];
freqPre              = ft_freqanalysis(cfg_freq,dataPre);
freqPost             = ft_freqanalysis(cfg_freq,dataPost);

% make a grid for source analysis
xyzmax=max(sim.grad.pnt);
xyzmin=min(sim.grad.pnt);
cfg_grid             = [];
cfg_grid.grad        = sim.grad; 
cfg_grid.reducerank  = 2;
cfg_grid.vol         = vol;
cfg_grid.channel     = 'MEG';
cfg_grid.inwardshift = -.01; % helps keep grid boundary from being tightly constrained by anatomy
cfg.grid.xgrid       = xyzmin(1):.01:xyzmax(1);
cfg.grid.ygrid       = xyzmin(2):.01:xyzmax(2);
cfg.grid.zgrid       = xyzmin(3):.01:xyzmax(3);
grid                 = ft_prepare_leadfield(cfg_grid);

% source DICS analysis on pre and post intervals
cfg_dics                 = [];
cfg_dics.frequency       = 25;
cfg_dics.method          = 'dics';
cfg_dics.channel         = 'MEG';
cfg_dics.grad            = sim.grad;
cfg_dics.dics.fixedori   = 'yes';
cfg_dics.dics.realfilter = 'yes';
cfg_dics.dics.powmethod  = 'trace';
cfg_dics.projectnoise    = 'no'; % if you want to compute Neural Activity Index
cfg_dics.grid            = grid;
cfg_dics.vol             = vol;
cfg_dics.lambda          = '2%'; % covariance regularization parameter
cfg_dics.reducerank      = 2;
cfg_dics.keepfilter      = 'yes'; % keep filter - can be used to create virtual sensor later
sourcePre           = ft_sourceanalysis(cfg_dics,freqPre);
sourcePost          = ft_sourceanalysis(cfg_dics,freqPost);
sourceDiff          = sourcePost;
sourceDiff.avg.pow  = (sourcePost.avg.pow - sourcePre.avg.pow) ./ sourcePre.avg.pow;