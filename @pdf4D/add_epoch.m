function obj = add_epoch(obj, pts_in_epoch)

% add new epock to pdf header

if nargin < 2
    pts_in_epoch = 0;
end

hdr = get(obj, 'header');
index = hdr.header_data.total_epochs + 1;
epoch_duration = hdr.header_data.sample_period * pts_in_epoch;
hdr.epoch_data{index} = new_epoch_data(obj, pts_in_epoch, epoch_duration);

hdr.header_data.total_epochs = uint16(index);
hdr.header_data.input_epochs = uint16(index);

hdr.header_data = fix_checksum(obj, hdr.header_data);

obj = set(obj, 'header', hdr);