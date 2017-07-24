%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Write E Table Header (dftk_E_table_header)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function write_user_block_et_header(fid, header)

% struct dftk_E_table_header
% {
%     long			version;				// version of the table
%     long			entry_size;				// size of one entry in the table
%     long			num_entries;				// # of entries
%     char			filter[DFTK_E_TABLE_FILTER_NAME_LEN];	// high-pass filter name
%     long			num_E_values;				// The number of E values per entry
%     char			reserved[DFTK_E_TABLE_RESERVED_LEN];	//
% };

fwrite(fid, header.version, 'int32');
fwrite(fid, header.entry_size, 'int32');
fwrite(fid, header.num_entries, 'int32');
fwrite_str(fid, header.filter, 16);
fwrite(fid, header.num_E_values, 'int32');
fwrite(fid, header.reserved, 'uchar');