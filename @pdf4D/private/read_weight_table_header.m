%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Read Weight Table Header (dftk_weight_table_header)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function weight_table_header = read_weight_table_header(user_block)
%not in use since 01/16/10

% struct dftk_weight_table_header
% {
%     long   version;
%     long   entry_size; /// Not used in variable-length design -
%                         /// must calculate from num_analog and num_dsp
%     long   num_entries;
%     char   name[DFTK_WEIGHT_TABLE_NAME_LEN];
%     char   description[DFTK_WEIGHT_TABLE_DESCRIPTION_LEN];
%     long   num_analog; /// Not used in WH2500 user blocks
%     long   num_dsp; /// Not used in WH2500 user blocks
%     char   reserved[DFTK_WEIGHT_TABLE_RESERVED_LEN];
% };

weight_table_header.version = swapNcast(user_block, 0, 4, 'int32');
weight_table_header.entry_size = swapNcast(user_block, 4, 4, 'int32');
weight_table_header.num_entries = swapNcast(user_block, 8, 4, 'int32');
weight_table_header.name = cutNcut(user_block, 12, 32);
weight_table_header.description = cutNcut(user_block, 44, 80);
weight_table_header.num_analog = swapNcast(user_block, 124, 4, 'int32');
weight_table_header.num_dsp = swapNcast(user_block, 128, 4, 'int32');
% weight_table_header.reserved = user_block(132+(1:72));

function val = swapNcast(val, offset, fsize, type)
val = typecast(val(offset+(fsize:-1:1)), type);

function str = cutNcut(str, offset, fsize)
str = str(offset+(1:fsize));
str = char(str(str>0));