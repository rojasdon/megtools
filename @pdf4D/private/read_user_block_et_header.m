%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Read E Table Header (dftk_E_table_header)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function header = read_user_block_et_header(fid)

% struct dftk_E_table_header
% {
%     long			version;				// version of the table
%     long			entry_size;				// size of one entry in the table
%     long			num_entries;				// # of entries
%     char			filter[DFTK_E_TABLE_FILTER_NAME_LEN];	// high-pass filter name
%     long			num_E_values;				// The number of E values per entry
%     char			reserved[DFTK_E_TABLE_RESERVED_LEN];	//
% };

header.version = fread(fid, 1, '*int32');
header.entry_size = fread(fid, 1, '*int32');
header.num_entries = fread(fid, 1, '*int32');
        filter = fread(fid, [1,16], '*uchar');
header.filter = char(filter(filter>0));
header.num_E_values = fread(fid, 1, '*int32');
header.reserved = fread(fid, [1,28], '*uchar');