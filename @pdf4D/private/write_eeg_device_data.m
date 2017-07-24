%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Write Eeg Device Data (dftk_eeg_device_data)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function write_eeg_device_data(fid, device_data)

%header and all structures always start at byte sizeof(double)*N,
%where N is integer and sizeof(double) is from C code
%(see <libdftk>/dftk_misc.C: int dftk_align(FILE *fp))
align_file(fid);

write_device_header(fid, device_data.hdr);

fwrite(fid, device_data.impedance, 'float32');
 
fwrite(fid, zeros(1, 4, 'uint8'), 'uint8');%alignment
% fseek(fid, 4, 'cof');%alignment

fwrite(fid, device_data.Xfm, 'double');
fwrite(fid, device_data.reserved, 'uchar');