% plot the source model for a gridded beamformer from fieldtrip - it's a
% bit busy with everything plotted but it does check for errors in
% registration

% options
plotbrain  = 0;
plotgrid   = 1;
ploths     = 0;
plotslices = 0;
plotsens   = 1;
plotmodel  = 1;
basename   = '1271';

% get screen size and set figure h x w accordingly
screen=get(0,'ScreenSize');
h = round(screen(3)*.75);
w = round(screen(4)*.75);
fig=figure('color','w');
pos=get(fig,'position');
set(fig,'position',[pos(1) pos(2) h w]);
movegui(fig,'center');

% sensors
if plotsens
    ft_plot_sens(sens,'style','go');
end
hold on

% grid (from ft_prepare_leadfield)
if plotgrid
    scatter3(grid.pos(grid.inside,1),grid.pos(grid.inside,2),grid.pos(grid.inside,3),...
        15,'m+');
    %scatter3(grid.pos(:,1),grid.pos(:,2),grid.pos(:,3),...
    %    15,'y+');
end

% source model
if plotmodel
    %iskull = vol.bnd;
    is=patch('vertices',iskull.vertices,'faces',iskull.faces,'facecolor','none','edgecolor','b');
end

% brain (not part of model necessarily, but looks nice)
if plotbrain
    cortex = D.inv{1}.forward.mesh;
    is=patch('vertices',cortex.vert,'faces',cortex.face,'facecolor',[.5,.1,.7],'edgecolor','none');
end


% plot mri fiducials and headshape
if ploths
    hs = D.fiducials;
    ft_plot_headshape(hs);
end

% transform between mri and meg space
mrifids = [transform.mri.nas;transform.mri.lpa;transform.mri.rpa];
megfids = [transform.meg.nas;transform.meg.lpa;transform.meg.rpa];
sform   = spm_eeg_inv_rigidreg(megfids',mrifids');

% mri scan slices
if plotslices
    pls=0.1:0.25:0.95;
    N = nifti([basename '.nii']);
    d=size(N.dat);
    pls = round(pls.*d(3));
    N.mat = sform*N.mat; % it matters which comes first!
    for i=1:numel(pls),
        [x,y,z]=ndgrid(1:d(1),1:d(2),pls(i));
        f1 = N.dat(:,:,pls(i));
        M = N.mat;
        x1 = M(1,1)*x+M(1,2)*y+M(1,3)*z+M(1,4);
        y1 = M(2,1)*x+M(2,2)*y+M(2,3)*z+M(2,4);
        z1 = M(3,1)*x+M(3,2)*y+M(3,3)*z+M(3,4);

        s=surf(x1,y1,z1,f1);
        set(s,'EdgeColor','none');
        %alpha(s,.5);
    end
end

axis image off;
rotate3d on;
view(0,0);