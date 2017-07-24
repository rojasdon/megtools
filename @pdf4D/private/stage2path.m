function stage = stage2path(stage)

%Purpose:
% - convert "stage" into msi path

%originally path to BTi stuff was /home/$STAGE
%as of 2008, $STAGE is full path to 4D stuff
if stage(1)~='/' %stage is full path
    stage = fullfile('/home', stage);
end
