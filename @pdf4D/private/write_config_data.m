%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Write Config Data (dftk_config_data)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function write_config_data(fid, config_data)

fwrite(fid, config_data.version, 'uint16');
fwrite_str(fid, config_data.site_name, 32);
fwrite_str(fid, config_data.dap_hostname, 16);
fwrite(fid, config_data.sys_type, 'uint16');
fwrite(fid, config_data.sys_options, 'uint32');
fwrite(fid, config_data.supply_freq, 'uint16');
fwrite(fid, config_data.total_chans, 'uint16');
fwrite(fid, config_data.system_fixed_gain, 'float32');
fwrite(fid, config_data.volts_per_bit, 'float32');
fwrite(fid, config_data.total_sensors, 'uint16');
fwrite(fid, config_data.total_user_blocks, 'uint16');
fwrite(fid, config_data.next_derived_channel_number, 'uint16');
 
fwrite(fid, zeros(1, 2, 'uint8'), 'uint8');%alignment
% fseek(fid, 2, 'cof');%alignment
    
fwrite(fid, config_data.checksum, 'int32');
fwrite(fid, config_data.reserved, 'uint8');