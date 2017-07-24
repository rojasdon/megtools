function obj = add_channel(obj, varargin)

% add new channel to pdf header

hdr = get(obj, 'header');
index = hdr.header_data.total_chans + 1;
hdr.channel_data{index} = new_channel_ref_data(obj, index, varargin{:});

hdr.header_data.total_chans = uint16(index);
hdr.header_data = fix_checksum(obj, hdr.header_data);

obj = set(obj, 'header', hdr);