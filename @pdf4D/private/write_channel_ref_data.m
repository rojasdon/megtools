%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Write Channel Reference (dftk_channel_ref_data)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function write_channel_ref_data(fid, channel)

%all structures always start at byte sizeof(double)*N,
%where N is integer and sizeof(double) == 8
%(see <libdftk>/dftk_misc.C: int dftk_align(FILE *fp))
align_file(fid);

%alignment checked
fwrite_str(fid, channel.chan_label, 16);
fwrite(fid, channel.chan_no, 'uint16');
fwrite(fid, channel.attributes, 'uint16');
fwrite(fid, channel.scale, 'float32');
fwrite_str(fid, channel.yaxis_label, 16);
fwrite(fid, channel.valid_min_max, 'uint16');
 
fwrite(fid, zeros(1, 6, 'uint8'), 'uint8');%alignment

fwrite(fid, channel.ymin, 'float64');
fwrite(fid, channel.ymax, 'float64');
fwrite(fid, channel.index, 'uint32');
fwrite(fid, channel.checksum, 'int32');

%something new?
fwrite_str(fid, channel.whatisit, 4);
fwrite(fid, channel.reserved, 'uint8');
