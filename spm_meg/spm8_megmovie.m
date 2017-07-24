% crude movie script for MEG spm8 - assumes the file you pick has a
% completed inversion from SPM8

%NOTE: add ability to pick time window to render to nearest sample point
%NOTE: times may not correspond correctly if time range for inverse was
%restricted in solution. Figure this out in SPM D struct and add to script!

% get file
file=uigetfile('*.mat');
load(file);

% prompt for rendering viewpoint
orient = menu('View?','Left','Right','Top','Bottom');

% prompt to save jpegs to make movie
out = menu('Save output?','Yes','No');

% time window in ms
t = zeros(1,D.Nsamples);
for j = 1:D.Nsamples
    t(j) = D.timeOnset + (j - 1) * 1/D.Fsample;
end
t=t*1000;


%get the meshes and inverse model
m.vertices  = D.other.inv{1}.mesh.tess_mni.vert;
m.faces     = D.other.inv{1}.mesh.tess_mni.face;
mscalp      = D.other.inv{1}.datareg.fid_mri;
model       = D.other.inv{1}.inverse;
J           = zeros(model.Nd,size(model.T,1));

J(model.Is,:)=model.J{1,1}*model.T'; %set condition J(1,i) here

%create plot
fig = figure;
set(fig,'renderer','zbuffer'); %open gl faster, but can't use phong interp
hnd = patch('vertices',m.vertices,'faces',...
      m.faces,'facecolor','b', 'edgecolor','none',...
      'FaceLighting','gouraud');
axis image off;
shading interp;
lighting phong; %also gouraud, which is faster
set(hnd,'SpecularColorReflectance',0,'SpecularExponent',50);
daspect([1 1 1]);
camva('auto');
%cmap = [gray(256);jet(256)];
%colormap(cmap); 
colormap(jet(512));
cameratoolbar('setmode','orbit');

switch orient
    case 1 % left
        lightangle(-45,0);
        view(-90,0);
    case 2 % right
        lightangle(45,0);
        view(90,0);
    case 3 % top
        lightangle(90,90);
        view(0,90);
    case 4 % bottom
        lightangle(-90,-90);
        view(-180,-90);
end

ax = gca;
[minJ minI] = min(min(J));
[maxJ maxI] = max(max(J));
set(ax,'Clim', [minJ maxJ]);

drawnow;

[pth name ext] = fileparts(file);

%loop through time-series
for i = 1:size(model.T,1)
    title(sprintf('%.0f ms',t(i)));
    tex = J(:,i); % face vertex data at single time point
    % a single vertex over time would be J(vert,:)
    set(hnd,'facevertexcdata',tex);
    if out == 1
        saveas(fig,[name '_' sprintf('%d',i)],'tiff');
    end
    pause(.001);
end
    