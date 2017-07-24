function [src mni] = dipfit_spm_ft(D,start,stop,pair)
% PURPOSE: to use Fieldtrip functions to fit dipole(s) to SPM data
% AUTHOR:  Don Rojas, Ph.D.
% INPUT:   D     - SPM8 meeg structure
%          start - start of fit time in ms
%          stop  - stop fit in ms
%          pair  - flag 1 = symmetric pair of dipoles
%                       0 = single dipole
% 
% OUTPUT:  src - Fieldtrip source structure
%          mni - 1x3 locations in mni coordinates
% EXAMPLE: [src mni] = dipfit_spm_ft(D,60,120,pair)
%          will fit a 2 dipole model between 60 and 120 ms to the SPM
%          MEEG structure D
% NOTES:   1) will have to make more flexible for EEG fits
% TODO:    2) need to add cfg options to dipolefitting call

% spm eeg defaults
spm('defaults','eeg');

val = 1;

% check for inverse field
if ~isfield(D.inv{val},'datareg')
    error('You must first coregister this dataset!');
end

modality = spm_eeg_modality_ui(D, 1, 1);

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
data.trial  = data.trial;
data.time   = data.time;
cfg         = [];
cfg.channel = D.chanlabels(chanind);
data        = ft_timelockanalysis(cfg, data);

% do fit
cfg                 = [];
cfg.vol             = vol;
cfg.inwardshift     = 0;
cfg.grid.resolution = 20;
cfg.grad            = sens;
cfg.reducerank      = 2; % for gradiometers
cfg.latency         = 1e-3*[start stop];

if pair % fit pair of symmetric dipoles
    cfg.numdipoles = 2;
    cfg.symmetry = 'x';
end

src = ft_dipolefitting(cfg, data);

% convert dipole to MNI coordinates
mni      = src.dip.pos;
mni(:,4) = 1;
mni      = mni * (datareg.toMNI * inv(M1))';
mni      = mni(:,1:3);

end