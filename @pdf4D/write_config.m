function write_config(pdf, filename, config)

%read_config(pdf, filename, config)
%
%Writes MSI (system or run) config file
%
%Converts MATLAB string into C-style strings by adding zeros
%Otherwise reads data "as is"

%Revision 1.0  01/14/10  eugene.kronberg@ucdenver.edu

if nargin < 3
    error('Too few input argumets');
end

if isempty(filename) || (ischar(filename) && strcmp(filename, 'config'))
    %write run config
    filename = get(pdf, 'ConfigName');
elseif ischar(filename)
    %write system config
    [dum, filename] = fileparts(filename);%remove path and extesion
    filename = fullfile(stage2path(getenv('STAGE')), 'config', ...
        sprintf('%s.config', filename));
end

%open file as big-endian (from sparc times)
fid = fopen(filename, 'w', 'b');

if fid == -1
    error('Cannot open file %s', filename);
end

%"header" for the config file
write_config_data(fid, config.config_data);

%alignment should be fine, but just in case
align_file(fid);
for si = 1:config.config_data.total_sensors
    fwrite(fid, config.Xfm{si}, 'double');
end

%user blocks (include weight tables)
for ub = 1:config.config_data.total_user_blocks
    write_user_blok_data(fid, config.user_block_data{ub});

    %write some user blocks as structure and some as byte-vector
    switch config.user_block_data{ub}.hdr.type
        case {
                'BWT_DC'
                'BWT_1.0'
                'BWT_0.1'
                }
            switch config.config_data.sys_type
        %         case {4,5} %WH2500
    %                 %write weight table for WH2500 system
    %                 write_user_block_wt2500(fid, config.user_block_data{ub}.weight_table);
                case {7,8} %WH3600
                    %write weight table for WH3600 system
                     write_user_block_wt3600(fid, config.user_block_data{ub}.weight_table);
                otherwise %other systems
                    %write weight table as a byte-vector
                    fwrite(fid, config.user_block_data{ub}.user_block, 'uchar');
            end
        case 'B_E_TABLE'
            switch config.config_data.sys_type
        %         case {4,5} %WH2500
    %                 %write E table for WH2500 system
    %                 write_user_block_et2500(fid, config.user_block_data{ub}.E_table);
                case {7,8} %WH3600
                    %write E table for WH3600 system
                    write_user_block_et3600(fid, config.user_block_data{ub}.E_table);
                otherwise %other systems
                    %read E table as a byte-vector
                    fwrite(fid, config.user_block_data{ub}.user_block, 'uchar');
            end
            
        otherwise
            %write user block as a byte-vector
            fwrite(fid, config.user_block_data{ub}.user_block, 'uchar');
    end
end

%channels
for ch = 1:config.config_data.total_chans
    write_channel_data(fid, config.channel_data{ch});
end

fclose(fid);