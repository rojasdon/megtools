%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Write Trigger Device Data (dftk_trigger_device_data)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function write_trigger_device_data(fid, device_data)

%header and all structures always start at byte sizeof(double)*N,
%where N is integer and sizeof(double) is from C code
%(see <libdftk>/dftk_misc.C: int dftk_align(FILE *fp))
align_file(fid);

write_device_header(fid, device_data.hdr);

fwrite(fid, device_data.user_space_size, 'uint32');
fwrite(fid, device_data.reserved, 'uint8');

fwrite(fid, zeros(1, 4, 'uint8'), 'uint8');%alignment
% fseek(fid, 4, 'cof');%alignment