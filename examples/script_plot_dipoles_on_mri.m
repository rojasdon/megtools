% script to plot headshape, fiducials, dipoles and MRI

mri='E0073T1ax.nii';
N=nifti(mri);
load('E0073_spm.xfm','-mat');
load('cnt.mat');
[mdip dpl]=meg_clinical_process_dipoles('E-0073-RFS1.txt','Gof',.98,'ymax',0,'zmin',10,'xmin',0);
meg_plot_dipoles(cnt,dpl,1);
hold on;

% transform mri to meg
mrifids = [transform.mri.nas;transform.mri.lpa;transform.mri.rpa];
megfids = [transform.meg.nas;transform.meg.lpa;transform.meg.rpa];
sform   = spm_eeg_inv_rigidreg(megfids',mrifids');

% mri slices
pls = [.05 .5 .95];
d   = size(N.dat);
pls = round(pls.*d(3));
M   = sform*N.mat; % it matters which comes first!
for i=1:numel(pls),
    [x,y,z]=ndgrid(1:d(1),1:d(2),pls(i));
    f1 = N.dat(:,:,pls(i));
    x1 = M(1,1)*x+M(1,2)*y+M(1,3)*z+M(1,4);
    y1 = M(2,1)*x+M(2,2)*y+M(2,3)*z+M(2,4);
    z1 = M(3,1)*x+M(3,2)*y+M(3,3)*z+M(3,4);

    s(i)=surf(x1,y1,z1,f1);
    set(s(i),'EdgeColor','none');
    alpha(s(i),.5);
end
colormap gray;