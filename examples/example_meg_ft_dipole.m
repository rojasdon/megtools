% example fit dipole to part sensors from 4D

load audef.mat;

ft = meg2ft(eps);

% build single sphere volume conductor from sphere fit to input channels
cfg = [];
cfg.grad = ft.grad;
cfg.headshape = eps.fiducials.pnt;
cfg.singlesphere = 'yes';
cfg.feedback = 'no';
vol = ft_prepare_localspheres(cfg);

% leadfield prep
cfg = [];
cfg.grad = ft.grad;
cfg.vol = vol;
cfg.resolution = 1;
lf = ft_prepare_leadfield(cfg);

