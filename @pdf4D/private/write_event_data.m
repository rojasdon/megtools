%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Write Event Data (dftk_event_data)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function write_event_data(fid, event)

%header and all structures always start at byte sizeof(double)*N,
%where N is integer and sizeof(double) is from C code
%(see <libdftk>/dftk_misc.C: int dftk_align(FILE *fp))
align_file(fid);

%alignment checked
fwrite_str(fid, event.event_name, 16);
fwrite(fid, event.start_lat, 'float32');
fwrite(fid, event.end_lat, 'float32');
fwrite(fid, event.step_size, 'float32');
fwrite(fid, event.fixed_event, 'uint16');

fwrite(fid, zeros(1, 2, 'uint8'), 'uint8');%alignment

fwrite(fid, event.checksum, 'int32');
fwrite(fid, event.reserved, 'uint8')';

fwrite(fid, zeros(1, 4, 'uint8'), 'uint8');%alignment