function meg_defaults
% function that sets the default pathway and any necessary defaults for megtools 
%if not already set correctly

% get info for toolboxes
A = ver;
if isempty(find(ismember({A.Name},'Signal Processing Toolbox')))
    warning('Signal Processing Toolbox not installed: Filtering function will not work!');
end

% set paths if needed
p = path;
if ~ismember(p,'megtools')
    addpath(p,'megtools');
end
[pth,~,~] = fileparts(which('meg_defaults'));
if ~ismember(p,'megcode')
    addpath(p,fullfile(pth,'megcode'));
end
if ~ismember(p,'eeglab_meg')
    addpath(p,fullfile(pth,'eeglab_meg'));
end
if ~ismember(p,'ft_meg')
    addpath(p,fullfile(pth,'ft_meg'));
end
if ~ismember(p,'spm_meg')
    addpath(p,fullfile(pth,'spm_meg'));
end
if ~ismember(p,'besa_meg')
    addpath(p,fullfile(pth,'besa_meg'));
end
if ~ismember(p,'stats')
    addpath(p,fullfile(pth,'stats'));
end
if ~ismember(p,'templates')
    addpath(p,fullfile(pth,'templates'));
end
if ~ismember(p,'examples')
    addpath(p,fullfile(pth,'examples'));
end

end