%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Write Epoch Data (dftk_epoch_data)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function write_epoch_data(fid, epoch)

%all structures always start at byte sizeof(double)*N,
%where N is integer and sizeof(double) == 8
%(see <libdftk>/dftk_misc.C: int dftk_align(FILE *fp))
align_file(fid);

%alignment checked
fwrite(fid, epoch.pts_in_epoch, 'uint32');
fwrite(fid, epoch.epoch_duration, 'float32');
fwrite(fid, epoch.expected_iti, 'float32');
fwrite(fid, epoch.actual_iti, 'float32');
fwrite(fid, epoch.total_var_events, 'uint32');
fwrite(fid, epoch.checksum, 'int32');
fwrite(fid, epoch.epoch_timestamp, 'int32');
fwrite(fid, epoch.reserved, 'uchar');

%read dftk_event_data (var_events)
for event = 1:epoch.total_var_events
     write_event_data(fid, epoch.var_event{event});
end