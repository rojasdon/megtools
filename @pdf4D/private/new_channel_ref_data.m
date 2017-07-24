function channel = new_channel_ref_data( ...
    obj, index, label, n, yaxis_label, min_max)

if nargin < 2 || isempty(index)
    index = 1;
end

if nargin < 3 || isempty(label)
    label = 'Z';
end

cnf = get(obj, 'config');
if nargin < 4 || isempty(n)
    %external channel "X1"
    n = 'X1';
end
if ischar(n)
    for ch=1:cnf.config_data.total_chans
        if strcmp(n, cnf.channel_data{ch}.name)
            %same as cnf.channel_data{ch}.chan_no
            n = ch;
            break
        end
    end
    if ischar(n)
        error('Wrong channel name %s', n);
    end
end

if nargin < 5 || isempty(yaxis_label)
    %get yaxis_label from the config file
    yaxis_label = cnf.channel_data{n}.yaxis_label;
end

if nargin < 6 || isempty(min_max)
    valid_min_max = 0;
    ymin = 0;
    ymax = 0;
else
    valid_min_max = 1;
    ymin = min(min_max);
    ymax = max(min_max);
end

channel = struct( ...
    'chan_label', label, ...
	'chan_no', uint16(n), ...
	'attributes', uint16(0), ...
	'scale', single(1), ...
	'yaxis_label', yaxis_label, ...
	'valid_min_max', uint16(valid_min_max), ...
	'ymin', double(ymin), ...
	'ymax', double(ymax), ...
	'index', uint32(index), ...
	'checksum', int32(0), ...
	'whatisit', 'OFF+', ...
	'reserved', zeros(1, 28, 'uint8'));

channel = fix_checksum(obj, channel);
