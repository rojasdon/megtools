function [tomeg,tomri] = spm8_manual_coreg(varargin)

% MEG SPM8 co-registration procedure simplified to make it easier to batch
%       process
% tomeg = homogeneous transform from mri 2 meg headframe
% tomri = inverse transform from meg 2 mri

% NOTE: to take an mri with a transform to meg, write it with the new
%       transform.tomeg*mri_transform. To take that volume with the new
%       transformation back to the original mri space, read it and apply the
%       following transform (transform.tomri*mri_transformed2meg).

% SEE ALSO: MRI2MEG, MEG2MRI, SPM8_APPLY_XFORM2D

% process input
if nargin < 3
    if nargin < 1
        mrifile = spm_select(1,...
            'image','Select MRI to co-register with...');
        megfile = spm_select(1,'mat',...
            'Select MEG file for co-registration...','','','.*');
        mtype   = 'spm';
    else
        error('Input unclear: either give 3 inputs or none!');
    end
else
    mrifile = varargin{1};
    megfile = varargin{2};
    mtype   = 'spm';
end

% figure out type of file for MEG fiducials
mtype = lower(mtype);
switch mtype
    case 'spm'
        D = spm_eeg_load(megfile);
        megfids = D.fiducials.fid.pnt;
        clear D;
    case 'megtools'
        meg  = load(megfile);
        type = getfields(MEG);
        megfids = eval(['meg.' type '.fiducials.fid.pnt']);
        clear meg type;
    otherwise
        error('MEG input type is not supported!');
end
        
Fgraph  = spm_figure('Create','Graphics','MRI','on');
mri     = spm_vol(mrifile);
meeglbl = {'NAS' 'LPA' 'RPA'};
fids    = zeros(length(meeglbl),3);

[~, Fgraph] = spm('FnUIsetup','MEG/MRI coregistration', 0);

% get points from MRI using spm functions
for pnts = 1:length(meeglbl)
    figure(Fgraph); clf;
    spm_orthviews('Reset');
    spm_orthviews('Image', mri);
    if spm_input(['Select ' meeglbl{pnts} ' position and click'] , 1,'OK|Retry', [1,0], 1)
        fids(pnts,:) = spm_orthviews('Pos')';
        spm_orthviews('Reset');
    end
end

% calculate transform
nas     = fids(1,:);
lpa     = fids(2,:);
rpa     = fids(3,:);
origin  = mean([lpa(:)'; rpa(:)']);
x       = nas(:)' - origin;
x       = x/norm(x);
y       = lpa(:)' - origin;
z       = cross(x,y);
z       = z/norm(z);
y       = cross(z,x);
y       = y/norm(y);

% set fields of transform structure
transform.xfm.origin   = origin;
transform.xfm.rotation = [x; y; z];
transform.mri.nas = nas;
transform.mri.lpa = lpa;
transform.mri.rpa = rpa;
transform.mri.mat = mri.mat; % store original mri transform
transform.meg.nas = megfids(1,:);
transform.meg.lpa = megfids(2,:);
transform.meg.rpa = megfids(3,:);

% create homogeneous 4 x 4 rigid body only transform (no scaling)
mrifids             = [transform.mri.nas;transform.mri.lpa;transform.mri.rpa];
xform               = spm_eeg_inv_rigidreg(megfids',mrifids');
% xform can be used when coordinates to transform have already had mri.mat
% applied (e.g., a cortical mesh made from the mri in question)
transform.xfm.xform = xform;
tomeg               = xform*mri.mat;
coreg               = tomeg*inv(mri.mat);
tomri               = inv(coreg);
transform.tomeg     = tomeg;
transform.tomri     = tomri; % this * tomeg will get you back to mri space

% save transform data
[pth, nam, ~] = fileparts(megfile);
save(fullfile(pth,[nam '.xfm']),'transform');