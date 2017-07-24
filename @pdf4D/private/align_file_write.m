function align_file_write(fid)

%all structures always start at byte sizeof(double)*N,
%where N is integer and sizeof(double) == 8
%(see <libdftk>/dftk_misc.C: int dftk_align(FILE *fp))
%while writing file add zeros

current_position = ftell(fid);
if mod(current_position, 8) ~= 0
    offset = 8 - mod(current_position,8);
    fwrite(fid, zeros(1,offset,'uint8'), 'uint8');%white zeros
end