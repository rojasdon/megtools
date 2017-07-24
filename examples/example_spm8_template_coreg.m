% example of spm8 template co-registration and forward model selection
% options
file = 'e,rfhp0_spm.mat'; % spm8 format meeg file
invnum = 1; % 1 for new inverse field in file
usehs  = 1; % 1 to use head shape in coreg, 0 no head shape
invname = 'MyInverse'; % a name for your inverse field

% defaults
spm('defaults','eeg');
fieldtripdefs;

% load existing spm8 format meg file
D=spm_eeg_load(file);

% prep template MRI, not individual MRI
D.inv                   = {struct('mesh', [])};
D.inv{invnum}.date      = strvcat(date,datestr(now,15));
D.inv{invnum}.comment 	= {invname}; % name of your inverse solution
Msize = 3;  % 1 = coarse, 2 = normal 3 = fine
sMRI  = []; % empty if using template
D.inv{invnum}.mesh      = spm_eeg_inv_mesh(sMRI, Msize);

% coregister template with MEG fids - note: if you convert to spm8 directly
% from raw data, not using MEG meg2spm.m function, then you will have 5
% fiducials, most likely, because of the 2 extra coils on head used in our
% laboratory. Next code sets options and input fields. Only first 3
% fiducials are used
meegfid                  = D.fiducials;
mrifid                   = D.inv{invnum}.mesh.fid;
S                        = [];
S.sourcefid              = meegfid;
S.sourcefid.fid.pnt      = meegfid.fid.pnt(1:3,:); %use 1st 3 coils only
S.sourcefid.fid.label    = meegfid.fid.label(1:3,:);
S.targetfid              = mrifid;
S.targetfid.fid.pnt      = [];
S.targetfid.fid.label    = {};
S.targetfid.fid.pnt      = mrifid.fid.pnt(1:3,:);
S.targetfid.fid.label    = S.sourcefid.fid.label;
S.targetfid.fod.label    = S.targetfid.fid.label(1:3, :);
S.useheadshape           = usehs; % try setting to 0 if poor result or bad/no hs info
S.template               = 2;
M1                       = spm_eeg_inv_datareg(S); % actual call to co-register

% set values of D struct from coregistration
ind                                    = 1;
D.inv{invnum}.datareg                  = struct([]);
D.inv{invnum}.datareg(ind).sensors     = D.sensors('MEG');
D.inv{invnum}.datareg(ind).fid_eeg     = S.sourcefid;
D.inv{invnum}.datareg(ind).fid_mri     = ft_transform_headshape(inv(M1), S.targetfid);
D.inv{invnum}.datareg(ind).toMNI       = D.inv{invnum}.mesh.Affine*M1;
D.inv{invnum}.datareg(ind).fromMNI     = inv(D.inv{invnum}.datareg(ind).toMNI);
D.inv{invnum}.datareg(ind).modality    = 'MEG';

% forward model type here
D.inv{invnum}.forward = struct([]);
D.inv{invnum}.forward(invnum).voltype ='Single Sphere'; % also 'Single Shell' if you like
D=spm_eeg_inv_forward(D);
spm_eeg_inv_checkforward(D, invnum);

% save file, which can now be inverted
D.save;