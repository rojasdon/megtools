%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Write PDF Header Data (dftk_header_data)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  write_header_data(fid, header)

%header and all structures always start at byte sizeof(double)*N,
%where N is integer and sizeof(double) is 8
%(see <libdftk>/dftk_misc.C: int dftk_align(FILE *fp))
align_file(fid);

fwrite(fid, header.version, 'uint16');
fwrite_str(fid, header.file_type, 5);

fwrite(fid, zeros(1, 'uint8'), 'uint8');%alignment

fwrite(fid, header.data_format, 'int16');
fwrite(fid, header.acq_mode, 'uint16');
fwrite(fid, header.total_epochs, 'uint32');
fwrite(fid, header.input_epochs, 'uint32');
fwrite(fid, header.total_events, 'uint32');
fwrite(fid, header.total_fixed_events, 'uint32');
fwrite(fid, header.sample_period, 'float32');
fwrite_str(fid, header.xaxis_label, 16);
fwrite(fid, header.total_processes, 'uint32');
fwrite(fid, header.total_chans, 'uint16');

fwrite(fid, zeros(1, 2, 'uint8'), 'uint8');%alignment

fwrite(fid, header.checksum, 'int32');
fwrite(fid, header.total_ed_classes, 'uint32');
fwrite(fid, header.total_associated_files, 'uint16');
fwrite(fid, header.last_file_index, 'uint16');
fwrite(fid, header.timestamp, 'uint32');
fwrite(fid, header.reserved, 'uint8');

fwrite(fid, zeros(1, 4, 'uint8'), 'uint8');%alignment
