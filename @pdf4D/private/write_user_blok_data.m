%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Write User Block Data (dftk_user_block_data)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function write_user_blok_data(fid, user_block_data)

%header and all structures always start at byte sizeof(double)*N,
%where N is integer and sizeof(double) is from C code
%(see <libdftk>/dftk_misc.C: int dftk_align(FILE *fp))
align_file(fid);

fwrite(fid, user_block_data.hdr.nbytes, 'uint32');
fwrite_str(fid, user_block_data.hdr.type, 20);
fwrite(fid, user_block_data.hdr.checksum, 'int32');
fwrite_str(fid, user_block_data.user, 32);
fwrite(fid, user_block_data.timestamp, 'uint32');
fwrite(fid, user_block_data.user_space_size, 'uint32');
fwrite(fid, user_block_data.reserved, 'uint8');

fwrite(fid, zeros(1, 4, 'uint8'), 'uint8');%alignment
% fseek(fid, 4, 'cof');%alignment
