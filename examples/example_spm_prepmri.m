% example of SPM8 mri preparation for source modeling

% spm_eeg_inv_imag_api is the shortcut to the gui for modeling

spm('defaults','eeg');

% load MEG file that you want to attach the volume conductor to
D = spm_eeg_load('bfm1003_right_spm.mat');

% choose resolution of cortical mesh and generate
Msize = 3; % 1 = coarse, 2 = normal 3 = fine
sMRI  = 'mri/m0021.img';
mesh  = spm_eeg_inv_mesh(sMRI, Msize);

% You will be overwriting this field if you save this, so make sure you
% don't have any inverse solutions in that file you would mind losing!
D.inv{1}.date = date;
D.inv{1}.comment = {'Piezo'};
D.inv{1}.mesh = mesh;

% check meshes visually if you like
spm_eeg_inv_checkmeshes(D);

D.save;