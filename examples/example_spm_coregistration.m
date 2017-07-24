% example SPM8 co-registration of MEG data from 4D dataset - the example
% assumes that there is no existing inverse solution in the file - it will
% overwrite without checking so beware. You should always evaluate the
% quality of your coregistration procedure visually at some point. 

spm('defaults','eeg');
val  = 1; % number of the inverse in your dataset
file = '0003_leps_spm.mat';
load('0003_meshes.mat');
D    = spm_eeg_load(file);

% coregister to template MRI, not individual MRI
D.inv              = {struct('mesh', [])};
D.inv{val}.date    = strvcat(date,datestr(now,15));
D.inv{val}.comment = {'Piezo'}; % name of your inverse solution

%sMRI = []; % sMRI should be empty for template registration
%Msize = 2; % coarse mesh = 1, normal = 2, fine = 3
%D.inv{val}.mesh = spm_eeg_inv_mesh(sMRI, Msize);
D.inv{val}.mesh = mesh;
spm_eeg_inv_checkmeshes(D); % comment out if you don't want to see meshes

% coregister template with MEG fids - note: if you convert to spm8 directly
% from raw data, not using MEG meg2spm.m function, then you will have 5
% fiducials, most likely, because of the 2 extra coils on head used in our
% laboratory. Next code sets options and input fields.
meegfid                  = D.fiducials;
mrifid                   = D.inv{val}.mesh.fid;
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
S.useheadshape           = 0; % try setting to 0 if poor result or bad/no hs info
S.template               = 2;

% actual coregistration procedure
M1                       = spm_eeg_inv_datareg(S);

% set values in D of coregistration procedure
ind                                 = 1;
D.inv{val}.datareg                  = struct([]);
D.inv{val}.datareg(ind).sensors     = D.sensors('MEG');
D.inv{val}.datareg(ind).fid_eeg     = S.sourcefid;
D.inv{val}.datareg(ind).fid_mri     = ft_transform_headshape(inv(M1), S.targetfid);
D.inv{val}.datareg(ind).toMNI   	= D.inv{val}.mesh.Affine*M1;
D.inv{val}.datareg(ind).fromMNI     = inv(D.inv{val}.datareg(ind).toMNI);
D.inv{val}.datareg(ind).modality    = 'MEG';
spm_eeg_inv_checkdatareg(D); % comment out if you don't want to see registration

% uncomment to save resulting meshes and coregistration
%D.save;