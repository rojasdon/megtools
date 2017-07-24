%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Write Channel Data (dftk_channel_data)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function write_channel_data(fid, channel_data)

%header and all structures always start at byte sizeof(double)*N,
%where N is integer and sizeof(double) is from C code
%(see <libdftk>/dftk_misc.C: int dftk_align(FILE *fp))
align_file(fid);

fwrite_str(fid, channel_data.name, 16);
fwrite(fid, channel_data.chan_no, 'uint16');
fwrite(fid, channel_data.type, 'uint16');
fwrite(fid, channel_data.sensor_no, 'int16');
 
fwrite(fid, zeros(1, 2, 'uint8'), 'uint8');%alignment
% fseek(fid, 2, 'cof');%alignment

fwrite(fid, channel_data.gain, 'float32');
fwrite(fid, channel_data.units_per_bit, 'float32');
fwrite_str(fid, channel_data.yaxis_label, 16);
fwrite(fid, channel_data.aar_val, 'double');
fwrite(fid, channel_data.checksum, 'int32');
fwrite(fid, channel_data.reserved, 'uint8');
 
fwrite(fid, zeros(1, 4, 'uint8'), 'uint8');%alignment
% fseek(fid, 4, 'cof');%alignment

switch channel_data.type
    case {1, 3}%meg/ref
        write_meg_device_data(fid, channel_data.device_data);
    case 2%eeg
        write_eeg_device_data(fid, channel_data.device_data);
    case 4%external
        write_external_device_data(fid, channel_data.device_data);
    case 5%TRIGGER
        write_trigger_device_data(fid, channel_data.device_data);
    case 6%utility
        write_utility_device_data(fid, channel_data.device_data);
    case 7%derived
        write_derived_device_data(fid, channel_data.device_data);
    case 8%shorted
        write_shorted_device_data(fid, channel_data.device_data);
    otherwise
        error('Unknown device type: %d\n', channel_data.type);
end