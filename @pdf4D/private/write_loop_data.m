%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Write Meg Loop Data (dftk_loop_data)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function write_loop_data(fid, loop_data)

%header and all structures always start at byte sizeof(double)*N,
%where N is integer and sizeof(double) is from C code
%(see <libdftk>/dftk_misc.C: int dftk_align(FILE *fp))
align_file(fid);

fwrite(fid, loop_data.position, 'double');
fwrite(fid, loop_data.direction, 'double');
fwrite(fid, loop_data.radius, 'double');
fwrite(fid, loop_data.wire_radius, 'double');
fwrite(fid, loop_data.turns, 'uint16');

fwrite(fid, zeros(1, 2, 'uint8'), 'uint8');%alignment
% fseek(fid, 2, 'cof');%alignment

fwrite(fid, loop_data.checksum, 'int32');
fwrite(fid, loop_data.reserved, 'uint8')';