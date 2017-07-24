%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Write Weight Table Header (dftk_weight_table_header)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function write_user_block_wt_header(fid, header)

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

fwrite(fid, header.version, 'int32');
fwrite(fid, header.entry_size, 'int32');
fwrite(fid, header.num_entries, 'int32');
fwrite_str(fid, header.name, 32);
fwrite_str(fid, header.description, 80);
fwrite(fid, header.num_analog, 'int32');
fwrite(fid, header.num_dsp, 'int32');
fwrite(fid, header.reserved, 'uchar');