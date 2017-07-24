function config = read_config(filename)

%config = read_config(filename)
%
%Reads MSI (system or run) config file
%
%Converts C-style strings into MATLAB string by removing zeros
%Otherwise reads data "as is"

%Revision 1.0  09/11/06  eugene.kronberg@uchsc.edu

if nargin < 1
    error('Too few input argumets');
end

if ~isconfig(filename)
    error('File %s is not valid config file', filename);
end

%open file as big-endian (from sparc times)
fid = fopen(filename, 'r', 'b');

if fid == -1
    error('Cannot open file %s', filename);
end

%"header" for the config file
config.config_data = read_config_data(fid);

%alignment should be fine, but just in case
align_file(fid);
for si = 1:config.config_data.total_sensors
    config.Xfm{si} = fread(fid, [4 4], 'double');
end

%user blocks (include weight tables)
for ub = 1:config.config_data.total_user_blocks
    config.user_block_data{ub} = read_user_blok_data(fid);
    user_space_size = double(config.user_block_data{ub}.user_space_size);
    %read some user blocks as structure and some as byte-vector
    switch config.user_block_data{ub}.hdr.type
        case {
                'B_weights_used'
                'BWT_DC'
                'BWT_1.0'
                'BWT_0.1'
                }
            %reading B_weights_used from run-config or standard weights
            %from system config file
            switch config.config_data.sys_type
        %         case {4,5} %WH2500
    %                 %read weight table for WH2500 system
    %                 config.user_block_data{ub}.weight_table = ...
    %                     read_user_block_wt2500(fid, user_space_size);
                case {7,8} %WH3600
                    %read weight table for WH3600 system
                    config.user_block_data{ub}.weight_table = ...
                        read_user_block_wt3600(fid);
                otherwise %other systems
                    %read weight table as a byte-vector
                    config.user_block_data{ub}.user_block = ...
                        read_user_block_vector(fid, user_space_size);
            end
        case {
                'B_E_table_used'
                'B_E_TABLE'
                }
            %reading B_E_table_used from run-config or standard weights
            %from system config file
            switch config.config_data.sys_type
        %         case {4,5} %WH2500
    %                 %read E table for WH2500 system
    %                 config.user_block_data{ub}.weight_table = ...
    %                     read_user_block_et2500(fid, user_space_size);
                case {7,8} %WH3600
                    %read E table for WH3600 system
                    config.user_block_data{ub}.E_table = ...
                        read_user_block_et3600(fid);
                otherwise %other systems
                    %read E table as a byte-vector
                    config.user_block_data{ub}.user_block = ...
                        read_user_block_vector(fid, user_space_size);
            end
        case 'B_COH_Points'
            switch config.config_data.sys_type
        %         case {4,5} %WH2500
    %                 %read COH Points for WH2500 system
    %                 config.user_block_data{ub}.weight_table = ...
    %                     read_user_block_et2500(fid, user_space_size);
                case {7,8} %WH3600
                    %read COH Points for WH3600 system
                    config.user_block_data{ub}.COH_Points = ...
                        read_user_block_coh3600(fid);
                otherwise %other systems
                    %read COH Points as a byte-vector
                    config.user_block_data{ub}.user_block = ...
                        read_user_block_vector(fid, user_space_size);
            end
        case 'b_eeg_elec_locs'
            switch config.config_data.sys_type
        %         case {4,5} %WH2500
    %                 %read electrode location for WH2500 system
    %                 config.user_block_data{ub}.weight_table = ...
    %                     read_user_block_et2500(fid, user_space_size);
                case {7,8} %WH3600
                    %read electrode location for WH3600 system
                    config.user_block_data{ub}.eeg_elec_loc = ...
                        read_user_block_el3600(fid, user_space_size);
                otherwise %other systems
                    %read electrode location as a byte-vector
                    config.user_block_data{ub}.user_block = ...
                        read_user_block_vector(fid, user_space_size);
            end
%         case 'b_ccp_xfm_block'
%             switch config.config_data.sys_type
%         %         case {4,5} %WH2500
%     %                 %read calc_coil_pos xfm for WH2500 system
%     %                 config.user_block_data{ub}.weight_table = ...
%     %                     read_user_block_et2500(fid, user_space_size);
%                 case {7,8} %WH3600
%                     %read calc_coil_pos xfm for WH3600 system
%                     config.user_block_data{ub}.ccp_xfm = ...
%                         read_user_block_ccpxfm3600(fid);
%                 otherwise %other systems
%                     %read calc_coil_pos xfm as a byte-vector
%                     config.user_block_data{ub}.user_block = ...
%                         read_user_block_vector(fid, user_space_size);
%             end
        otherwise
            %read user block as a byte-vector
            config.user_block_data{ub}.user_block = ...
                read_user_block_vector(fid, user_space_size);
    end
end

%channels
for ch = 1:config.config_data.total_chans
    config.channel_data{ch} = read_channel_data(fid);
end

fclose(fid);

function user_block = read_user_block_vector(fid, user_space_size)
%read user block as a byte-vector
user_block = fread(fid, [1,user_space_size], '*uchar');