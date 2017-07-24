%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Get Weight/E Table (dftk_weight_table)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [user_block, index] = get_table(pdf, config, type, hpf, name) %#ok<INUSL>
%config - configuration read by sysconf
%type - table type 'w' or 'e'
%hpf - filter 'DC', '0.1', or '1.0'
%name - 'Zero', 'Supine', or 'Seated'

user_block = [];
index = [];

switch config.config_data.sys_type
    case {7,8} %WH3600
        switch lower(type)
            case 'e' %E table
                for ub=1:length(config.user_block_data)
                    if strcmp(config.user_block_data{ub}.hdr.type, 'B_E_TABLE')
                        if strcmpi(config.user_block_data{ub}.E_table.header.filter, hpf)
                            user_block = config.user_block_data{ub};
                            index = ub;
                        end
                    end
                end
            case 'w' %weight table
                for ub=1:length(config.user_block_data)
                    if strcmpi(config.user_block_data{ub}.hdr.type, ...
                            sprintf('BWT_%s', hpf))
                        if strcmpi(config.user_block_data{ub}.weight_table.header.name, name)
                            user_block = config.user_block_data{ub};
                            index = ub;
                        end
                    end
                end
            otherwise
                error('Wrong table type: %s', type)
        end
    otherwise
        error('Get Table works only for WH3600 system :(')
end