% read in dipole file output from 4D system and use as start for new fit on
% data processed differently - response to review for Molecular Autism
% paper

% options
id      = '0947';
dipfile = '_Ldip.txt';

% read in data and convert to Fieldtrip
files   = dir('all_e,rfhp*');
all_eps = get4D(files.name);
ep32    = epoch_extractor(all_eps,32);
ep40    = epoch_extractor(all_eps,40);
ep48    = epoch_extractor(all_eps,48);
ft32    = meg2ft(ep32);
ft40    = meg2ft(ep40); 
ft48    = meg2ft(ep48);

% perhaps clear MEG formatted files here or do I need them for later?

% parameters for reading dipoles
param.line_to_skip = 31;
param.xyz_units    = 'cm';
param.func         = '1';
param.lat          = 1;
param.xcol         = 2;
param.ycol         = 3;
param.zcol         = 4;
param.Qx           = 5;
param.Qy           = 6;
param.Qz           = 7;
param.Gof          = 12;

bfs  = read_msi_bfs([id dipfile]);
dpl  = read_msi_dipole([id dipfile],param);
dip  = find_msi_dip(dpl,0);


% OK TO HERE

% need to put code here to do prep of fieldtrip - should input be in
% meters, fT, etc.

% change best fit sphere scale from cm to to meters
lbfs = lbfs/1e2;
rbfs = rbfs/1e2;

% change dipole scale from mm to meters
ldip.x = ldip.x/1e3;
ldip.y = ldip.y/1e3;
ldip.z = ldip.z/1e3;
rdip.x = rdip.x/1e3;
rdip.y = rdip.y/1e3;
rdip.z = rdip.z/1e3;

% see tutorial for dipole model in FT

% Need to do averaging etc. here to get proper dataset for FT
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
