%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Read Weight Table Header (dftk_weight_table_header)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function header = read_user_block_wt_header(fid)

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

header.version = fread(fid, 1, '*int32');
header.entry_size = fread(fid, 1, '*int32');
header.num_entries = fread(fid, 1, '*int32');
        name = fread(fid, [1,32], '*uchar');
header.name = char(name(name>0));
%description could be empty string
description = fread(fid, [1,80], '*uchar');
description = description(description>0);
if isempty(description)
    header.description = '';
else
    header.description = char(description);
end
header.num_analog = fread(fid, 1, '*int32');
header.num_dsp = fread(fid, 1, '*int32');
header.reserved = fread(fid, [1,72], '*uchar');