%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Write Weight Table (dftk_weight_table)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function weight_table = write_user_block_wt3600(fid, weight_table)

%from dftk_weight_table.h (see dftk_E_table.h for E table)
% /// --------------------- WH2500 Fixed Size User Blocks ----------------------
% ///
% /// For the fixed-size design, the header is immediately followed by an array of
% /// "num_entries" dftk_weight_WH2500 structures. Note that the number of entries
% /// is normally the total number of channels in the system, with non-MEG channel
% /// entries set to zero. No channel name arrays exist in the fixed-size design.
% /// The order of channels in the list must match the CFO order of the config file
% /// with which the weight table is being used. However, there is no way to verify
% /// this.
% struct dftk_weight_WH2500
% {
%     short  analog[DFTK_WH2500_NUM_ANALOG_WEIGHTS]; /// Analog / MDAC weights
%     short  unused;     /// unused but needed for structure padding
%     float  dsp[DFTK_WH2500_NUM_DSP_WEIGHTS]; /// DSP weights
% 
% ///
% /// ----------------------- Variable Size User Blocks ------------------------
% ///
% /// For the variable-length design, the short value and the float values for each
% /// channel are separated into two separate arrays. This allows for correct data
% /// alignment regardless of the number of items in the array. Also, the arrays
% /// contain entries for only MEG channels. The entry channel names array associates
% /// the entries in the list with the channel to which they apply. The use of names
% /// instead of CFO numbers permits the use of the tables with any config file,
% /// since channel order in the table is not based on a particular config file.
% /// Applications that need to access the tables must look up the entries by name,
% /// rather than parsing the list sequentially and assuming a particular order.
% ///
% /// Immediately following the header are four arrays:
% ///
% /// 1. Array of Entry Channel Names, "num_entries" entries, each
% /// DFTK_CHANNEL_STRLEN in length, in the order in which the weights
% /// associated with each channel are stored in the array (in the
% /// "num_entries" axis).
% /// 2. Array of Analog Channel Names, "num_analog" entries, each
% /// DFTK_CHANNEL_STRLEN in length, in the order in which the corresponding
% /// entries appear in the Analog Weights array below.
% /// 3. Array of DSP Channel Names, "num_dsp" entries, each
% /// DFTK_CHANNEL_STRLEN in length, in the order in which the corresponding
% /// entries appear in the DSP Weights array below.
% /// 4. DSP Weights array, "num_dsp" wide by "num_entries" high, in float format.
% /// Column order must match the order of names in the DSP Channel Names
% /// array.
% /// 5. Analog Weights array, "num_analog" wide by "num_entries" high, in
% /// short format. Column order must match the order of names in the
% /// Analog Channel Names array.
% ///
% /// Note that arrays 1, 2,  and 3 must be integer multiples of 4 bytes so that
% /// the following DSP array is aligned properly in memory (floats must be on a
% /// 4 byte boundary). This is assured since DFTK_CHANNEL_STRLEN is 16 bytes.
% /// Likewise, this is why the Analog Weights appear after the DSP weights, so
% /// that the DSP weights are always aligned, regardless
% /// of the number of shorts in the Analog array (which may be 0!).

write_user_block_wt_header(fid, weight_table.header);
write_channel_name(fid, weight_table.channel_name);
write_channel_name(fid, weight_table.analog_channel_name);
write_channel_name(fid, weight_table.dsp_channel_name);
fwrite(fid, weight_table.dsp_weights, 'single');
fwrite(fid, weight_table.analog_weights, 'int16');

function write_channel_name(fid, name)
for ch=1:length(name)
    fwrite_str(fid, name{ch}, 16);
end