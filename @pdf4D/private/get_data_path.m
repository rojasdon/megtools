function data_path = get_data_path

%get STAGE
[stat, stage] = unix('echo -n $STAGE');

%no STAGE -> return
if stat~=0
    data_path = '';
    return
end

%originally path to BTi stuff was /home/$STAGE
%as of 2008, $STAGE is full path to 4D stuff
stage = stage2path(stage);
data_path = fullfile(stage, 'data');
