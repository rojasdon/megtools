% spm co-registration procedure

Fgraph = spm_figure('Create','Graphics','MRI','on');
mri=spm_vol('1258.nii');
meeglbl = {'NAS' 'LPA' 'RPA'};
fids    = zeros(length(meeglbl),3);

[Finter, Fgraph] = spm('FnUIsetup','MEEG/MRI coregistration', 0);

for pnts = 1:length(meeglbl)
    figure(Fgraph); clf;
    spm_orthviews('Reset');
    spm_orthviews('Image', mri);
    if spm_input(['Select ' meeglbl{pnts} ' position and click'] , 1,'OK|Retry', [1,0], 1)
        fids(pnts,:) = spm_orthviews('Pos')';
        spm_orthviews('Reset');
    end
end

origin = mean([lpa(:)'; rpa(:)']);
x = nas(:)' - origin;
x = x/norm(x);
y = lpa(:)' - origin;
z = cross(x,y);
z = z/norm(z);
y = cross(z,x);
y = y/norm(y);
transform.vector = origin;
transform.matrix = [x; y; z];

%now time to get xyz

%mri to meg transform
%(from mri_to_meg)
xyz = transform.matrix * (xyz(:) - transform.vector(:));

%meg to mri transform
%(from meg_to_mri)
xyz = transform.matrix' * xyz(:) + transform.vector(:);