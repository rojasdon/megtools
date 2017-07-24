function [chan_lbl, chan_ind] = channel_group(obj, group_name) 

% CHANNEL_GROUP chan_index = channel_group(obj, group_name)
% returns channel indecies for all channel in a group
% group_name - name of the group, one of the following:
%       'Sys : <group name>'
%       'User : <group name>'
%       '<user name> : <group name>'
% chanindx - indecies of the channels

%find separator
sep = find(group_name==':');
if isempty(sep) || length(sep)>1
    error('Group name should have one and only one ":"')
end

%prefix is 'Sys', 'User' or <username>
prefix = strtrim(group_name(1:sep-1));
group = strtrim(group_name(sep+1:end));

%get username
user = getenv('USER');

%get home directory
home = getenv('HOME');

%get stage
stage = stage2path(getenv('STAGE'));

switch prefix
    case 'Sys'
        %read sys channel group file
        group_file = fullfile(stage, 'map', 'lib', 'Sys_Channel_Groups');
    case {'User' user}
        %read uesr group file
        group_file = fullfile(home, sprintf('.%s_Channel_Groups', user));
    otherwise
        error('Wrong group name prefix: %s', prefix)
end

fid = fopen(group_file, 'r');

%group names in the file
str = fgetl(fid);
[tok, str] = strtok(str, '=');
%first token in the file should be 'Channel_Groups'
if ~strcmp('Channel_Groups', strtrim(tok))
    error('Bad Channel Group file "%s"', group_file)
end

%find channel group index
index = 0;
while true
    index = index + 1;
    str(1) = [];%remove separator
    [tok, str] = strtok(str(2:end), ':;');
    if isempty(tok)
        error('There is no "%s" Cannel Group in "%s"', group, group_file)
    end
    if strcmp(group, strtrim(tok))
        break
    end
end

%skip other group
for ii=1:index-1
    str = fgetl(fid);
    if ~ischar(str) && str==-1
        %there should be one line per channel group in the file
        error('Bad Channel Group File "%s"', grpou_file)
    end
end
str = fgetl(fid);
[tok, str] = strtok(str, '=');
%first token on the line should be <grpou name>
if ~strcmp(group, strtrim(tok))
    error('Bad Channel Group file "%s"', group_file)
end
%number channels in the group
%(there is ":" after each channel, but there is ";" after last channel) 
nch = length(find(str==':')) + 1;
chan_lbl = cell(1,nch);%pre-allocation
for ii=1:nch
    str(1) = [];%remove separator
    [tok, str] = strtok(str(2:end), ':;');
    if isempty(tok) || strcmp('S', strtrim(tok))
        error('Bad Channel group "%s" in "%s"', group, group_file)
    end
    chan_lbl{ii} = strtrim(tok);
end    
fclose(fid);

if nargout > 1 && ispdf(get(obj, 'filename'))    
    chan_ind = channel_index(obj, chan_lbl);
else
    chan_ind = [];
end