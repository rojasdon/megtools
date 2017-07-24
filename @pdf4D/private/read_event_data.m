%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Read Event (dftk_event_data)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function event = read_event_data(fid)

%header and all structures always start at byte sizeof(double)*N,
%where N is integer and sizeof(double) is from C code
%(see <libdftk>/dftk_misc.C: int dftk_align(FILE *fp))
align_file(fid);

%alignment checked
      event_name = char(fread(fid, 16, 'uchar'))';
event.event_name = event_name(event_name>0);
event.start_lat = fread(fid, 1, 'float32=>float32');
% fprintf('end_lat pos: %d\n', ftell(fid)); %end_lat position
event.end_lat = fread(fid, 1, 'float32=>float32');
event.step_size = fread(fid, 1, 'float32=>float32');
event.fixed_event = fread(fid, 1, 'uint16=>uint16');
fseek(fid, 2, 'cof');%alignment
% fprintf('checksum pos: %d\n', ftell(fid)) %checksum position
event.checksum = fread(fid, 1, 'int32=>int32');
event.reserved = fread(fid, 32, 'uchar')';
fseek(fid, 4, 'cof');%alignment
