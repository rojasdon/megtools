% test for icp based surface matching of meg hs to scalp surface
% essentially shows what result of surface matching would be without using
% the fiducial points nas, lpa and rpa. This could be reversed, i.e., mri 2
% meg, by reversing orders in calls, or inverting the final transform

% NOTE: this doesn't work well at all when scalp surface is cut off at
% front/back due to poor mri coverage or when there are not many points in 
% the hs_file

% this could be used rather than manual co-registration IF the MRI coverage
% is complete (i.e., contains face and ears, no scalp cut off) AND the MEG
% digitization is thorough (i.e., 3000-5000 points with even coverage).

load testdata.mat; % this has sr struct, which is output of spm_surf
sr=export(gifti(sr),'ft');
scalpvert=sr.pnt;
fiducials=ft_read_headshape('hs_file');
fiducials=ft_convert_units(fiducials,'mm');

% find some max and min points in mri
xmin=min(scalpvert(:,1,:));
xmax=max(scalpvert(:,1,:));
ymin=min(scalpvert(:,2,:));
ymax=max(scalpvert(:,2,:));
zmin=min(scalpvert(:,3,:));
zmax=max(scalpvert(:,3,:));
ind = find((fiducials.pnt(:,2,:) > ymin) & (fiducials.pnt(:,2,:) < ymax));

% some gimbal rotation matrices
deg = 90;
Mx  = [1 0 0; 0 cos(deg) -sin(deg); 0 sin(deg) cos(deg)];
My  = [cos(deg) 0 sin(deg); 0 1 0; -sin(deg) 0 cos(deg)];
Mz  = [cos(deg) -sin(deg) 0; sin(deg) cos(deg) 0; 0 0 1];

% plot original data
figure('name','original data');
Fscalp  = plot3(scalpvert(:,1),scalpvert(:,2),scalpvert(:,3),'b.');
hold on;
Fhshape = ft_plot_headshape(fiducials);
axis image; xlabel('x'); ylabel('y'); zlabel('z');
rotate3d on;

% first do simple gimbal rotation without translation and plot results -
% assuming that the mri data are in SPM convention, x and y are opposite
% MRI and MEG
ztransform = [Mz zeros(3,1); 0 0 0 1]; % 4 x 4 transform
newhs     = ft_transform_headshape(ztransform,fiducials);
figure('name','headshape rotated 90 deg about z-axis');
Fscalp  = plot3(scalpvert(:,1),scalpvert(:,2),scalpvert(:,3),'b.');
hold on;
Fhshape = ft_plot_headshape(newhs);
axis image; xlabel('x'); ylabel('y'); zlabel('z');
rotate3d on;

% next do iterative closest point algorithm and plot
newvert   = newhs.pnt(ind,:);
[R,T]     = icp(scalpvert,newvert); % newpoints = ((R*newvert')')+repmat(T',length(newvert),1);
icptransform = [R T; 0 0 0 1]; % create homogeneous transform
meg2mri   = icptransform*ztransform;
newhs     = ft_transform_headshape(meg2mri,fiducials);
figure('name','headshape rotated 90 deg about z and surface matched');
Fscalp  = plot3(scalpvert(:,1),scalpvert(:,2),scalpvert(:,3),'b.');
hold on;
Fhshape = ft_plot_headshape(newhs);
axis image; xlabel('x'); ylabel('y'); zlabel('z');
rotate3d on;

% This will also work to get the icptransform
M=spm_eeg_inv_icp(scalpvert',newvert',zeros(3,3),zeros(3,3));
meg2mri   = M*ztransform;
newhs     = ft_transform_headshape(meg2mri,fiducials);
figure('name','headshape rotated 90 deg about z and icp with SPM8');
Fscalp  = plot3(scalpvert(:,1),scalpvert(:,2),scalpvert(:,3),'b.');
hold on;
Fhshape = ft_plot_headshape(newhs);
axis image; xlabel('x'); ylabel('y'); zlabel('z');
rotate3d on;

