%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Write Process Data (dftk_proc_data)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function write_proc_data(fid, proc)

%all structures always start at byte sizeof(double)*N,
%where N is integer and sizeof(double) == 8
%(see <libdftk>/dftk_misc.C: int dftk_align(FILE *fp))
align_file(fid);

%alignment checked
fwrite(fid, proc.hdr.nbytes, 'uint32');
fwrite_str(fid, proc.hdr.type, 20);
fwrite(fid, proc.hdr.checksum, 'int32');
fwrite_str(fid, proc.user, 32);
fwrite(fid, proc.timestamp, 'uint32');
fwrite_str(fid, proc.filename, 256);
fwrite(fid, proc.total_steps, 'uint32');
fwrite(fid, proc.reserved, 'uint8')';

fwrite(fid, zeros(1, 4, 'uint8'), 'uint8');%alignment
% fseek(fid, 4, 'cof');%alignment

%read process steps
for proc_step = 1:proc.total_steps
    write_proc_step(fid, proc.step{proc_step});
end