function chan_pos = channel_position(obj, chanindx, config)

% CHANNEL_POSITION chan_pos = channel_position(obj, chanindx, config)
% returns array of structures with fields "position" and "direction"
%    for meg channels both fields are 3 by N, where N is number of coils
%    for non-meg channels both fields are empty
%    to get channel positions in probe-coordinates supply system config
%    struct (result of sysconf(obj, file)) as a third parameter
% chanindx - indecies of the channels
% config - structure returned by get(obj, 'config') or sysconf(obj, file).
%          (optional: default - use run config)

header = get(obj, 'header');

if nargin < 3 || isempty(config)
    config = get(obj, 'config');
end

chan_pos(length(chanindx)) = struct('position', 0, 'direction', 0); 
for ch = 1:length(chanindx)
    chan_no = header.channel_data{chanindx(ch)}.chan_no;
    switch config.channel_data{chan_no}.type
        case {1 3} %meg or ref
            nl = config.channel_data{chan_no}.device_data.total_loops;
            position = zeros(3,nl);
            direction = zeros(3,nl);
            for l = 1:nl
                position(:,l) = ...
                    config.channel_data{chan_no} ...
                    .device_data.loop_data{l}.position;
                direction(:,l) = ...
                    config.channel_data{chan_no} ...
                    .device_data.loop_data{l}.direction;
            end
            chan_pos(ch) = struct( ...
                'position', position, ...
                'direction', direction );
        otherwise
            chan_pos(ch) = struct( ...
                'position', [], ...
                'direction', [] );
    end
end