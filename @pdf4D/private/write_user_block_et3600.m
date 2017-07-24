%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Write E Table (dftk_E_table)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function write_user_block_et3600(fid, E_table)

%from dftk_E_table.h:
% /// --------------------- WH2500 Fixed Size User Blocks ----------------------
% ///
% /// For the fixed-size design, the header is immediately followed by an array of
% /// "num_entries" arrays of 6 floating point values. Note that the number of entries
% /// is normally the total number of channels in the system, with non-MEG channel
% /// entries set to zero. No channel name arrays exist in the fixed-size design.
% /// The order of channels in the list must match the CFO order of the config file
% /// with which the weight table is being used. However, there is no way to verify
% /// this.
% ///
% /// ----------------------- Variable Size User Blocks ------------------------
% ///
% /// The array contains entries for only MEG channels. The MEG channel names array
% /// associates he entries in the list with the channel to which they apply. The use of names
% /// instead of CFO numbers permits the use of the tables with any config file,
% /// since channel order in the table is not based on a particular config file.
% /// Applications that need to access the tables must look up the entries by name,
% /// rather than parsing the list sequentially and assuming a particular order.
% ///
% /// Immediately following the header are four arrays:
% ///
% /// 1. Array of Entry Channel Names, "num_entries" entries, each
% ///	DFTK_CHANNEL_STRLEN in length, in the order in which the E values
% ///	associated with each channel are stored in the array (in the
% ///	"num_entries" axis).
% /// 2. Array of E Value Channel Names, "num_E_values" entries, each
% ///	DFTK_CHANNEL_STRLEN in length, in the order in which the corresponding
% ///	entries appear in the E Values array below.
% /// 3. E Values array, "num_E_values" wide by "num_entries" high, in float format.
% ///	Column order must match the order of names in the E Values Channel Names
% ///	array.
% ///
% /// Note that arrays 1 and 2 must be integer multiples of 4 bytes so that
% /// the following values array is aligned properly in memory (floats must be on a
% /// 4 byte boundary). This is assured since DFTK_CHANNEL_STRLEN is 16 bytes.

write_user_block_et_header(fid, E_table.header);

write_channel_name(fid, E_table.channel_name);
write_channel_name(fid, E_table.E_value_channel_name);
fwrite(fid, E_table.E_values, 'single');

function write_channel_name(fid, name)
for ch=1:length(name)
    fwrite_str(fid, name{ch}, 16);
end