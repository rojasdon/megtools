function config = sysconf(obj, filename) %#ok<INUSL>

%Purpose:
% - read system config file

if nargin < 2
    error('Too few input parameters')
end

if isunix || ismac
    if exist(filename, 'file') == 2
        %try to read file as system config
        config = read_config(filename);
    elseif msi_installed
        %msi should be installed
        [p,f,ext] = fileparts(filename);
        if ~isempty(p)
            %filename should be just name for system config file
            error('There is no "%s" file', filename)
        end
        if isempty(ext) || ~strcmp(ext, '.config')
            %append standard config file extension
            filename = sprintf('%s.config', filename);
        end
        %get STAGE - may be getenv is better?
        [stat, stage] = unix('echo -n $STAGE');

        %no STAGE -> return (if msi was installed this should not happen)
        if stat~=0
            config = [];
            return
        end
        %originally path to BTi stuff was /home/$STAGE
        %as of 2008, $STAGE is full path to 4D stuff
        stage = stage2path(stage);
        %full path to system config file
        filename = fullfile(stage, 'config', filename);
        if exist(filename, 'file') == 2
            config = read_config(filename);
        else
            error('There is no "%s" file', filename)
        end
    else
        error('There is no "%s" file', filename)
    end
else
    if exist(filename, 'file') == 2
        %try to read file as system config
        config = read_config(filename);
    else
        error('There is no "%s" file', filename)
    end
end