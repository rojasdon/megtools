function event = new_event_data(pdf)

event = struct( ...
    'event_name', 'Trigger', ...
	'start_lat', single(0), ...
	'end_lat', single(0), ...
	'step_size', single(0), ...
	'fixed_event', uint16(1), ...
	'checksum', int32(0), ...
	'reserved', zeros(1, 32, 'uint8'));

event = fix_checksum(pdf, event);