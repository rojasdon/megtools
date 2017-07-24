% script using spm8 to do source analysis on averaged dataset
% change path to dir containing a usable file

% spm eeg defaults
spm('defaults','eeg');

% load a file
D=spm_eeg_load('fbmspm_test.mat');

% note: this assumes that coregistration has occured with a particular
% headmodel - use gui
val             = 1;

% compute leadfields
D.inv{val}.forward = struct([]);
D.inv{val}.forward(val).voltype ='Single Sphere';
D=spm_eeg_inv_forward(D);
spm_eeg_inv_checkforward(D, val);

% set options for inversion
inverse              = struct([]);
inverse(val).type    = 'GS'; % type of inverse
inverse(val).woi     = [50 200]; % window of intereset in ms
inverse(val).Han     = 0; % Hanning window?
inverse(val).lpf     = 1; % low cutoff
inverse(val).hpf     = 48; % high cutoff
inverse(val).pQ      = {}; % source priors
inverse(val).trials  = {'250'}; % conditions to invert

% invert
D.con              = val;
D.inv{val}.inverse = inverse;
D = spm_eeg_invert(D,val);

% save file
%D.save;

% note: SPMgainmatrix_filename.mat also saved - it contains the leadfield
% matrix for the headmodel (nchan x nsources)