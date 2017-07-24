%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Read Config Data (dftk_config_data)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function config_data = read_config_data(fid)

%codes for sys_type (from dftk_config.h):
% // ---------- possible system types for ----------
% #define S700_R_N_D_DAP   (0)   // This definition is used for internal research & development
% #define S700_DAP0   (1)   // This definition is used for all ASP systems
% #define S700_DAP1   (2)   // This definition is used for SCP versions 1.0-1.3
% #define S700_DAP2   (3)   // This definition is used currently in SCP 1.4
% 
% // Whole head system types;  be SURE to update dftk_config::is_whole_head() to include all of these!
% #define SWH_DAS1   (4)   // for 2500WH w/Magnetometer Signal Coils
% #define SWH_DAS2   (5)   // for 2500WH w/Gradiometer Signal Coils
% #define SWH_DAS3   (6)   // for 1300C  w/Magnetometer Signal Coils
% #define SWH_DAS4   (7)   // for 3600WH w/Magnetometers
% #define SWH_DAS5   (8)   // for 3600Wh w/Gradiometers

config_data.version = fread(fid, 1, 'uint16=>uint16');
            site_name = fread(fid, [1, 32], '*char');
config_data.site_name = site_name(site_name>0);
            dap_hostname = fread(fid, [1, 16], '*char');
config_data.dap_hostname = dap_hostname(dap_hostname>0);
config_data.sys_type = fread(fid, 1, 'uint16=>uint16');
config_data.sys_options = fread(fid, 1, 'uint32=>uint32');
config_data.supply_freq = fread(fid, 1, 'uint16=>uint16');
config_data.total_chans = fread(fid, 1, 'uint16=>uint16');
config_data.system_fixed_gain = fread(fid, 1, 'float32=>float32');
config_data.volts_per_bit = fread(fid, 1, 'float32=>float32');
config_data.total_sensors = fread(fid, 1, 'uint16=>uint16');
config_data.total_user_blocks = fread(fid, 1, 'uint16=>uint16');
config_data.next_derived_channel_number = fread(fid, 1, 'uint16=>uint16');
    fseek(fid, 2, 'cof');%alignment
config_data.checksum = fread(fid, 1, 'int32=>int32');
config_data.reserved = fread(fid, 32, 'uchar=>uchar')';

