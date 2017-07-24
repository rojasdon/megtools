% plot a beamformer source
cfg              = [];
cfg.interpmethod = 'nearest';
cfg.parameter    = 'nai';
source_int        = ft_sourceinterpolate(cfg, source, template_mri);
cfg               = [];
cfg.method        = 'ortho';
cfg.funparameter  = 'nai';
cfg.maskparameter = cfg.funparameter;
cfg.funcolorlim   = [0.0 max(source.avg.nai)];
cfg.opacitylim    = [0.0 max(source.avg.nai)];
cfg.opacitymap    = 'rampup';
ft_sourceplot(cfg,source_int);