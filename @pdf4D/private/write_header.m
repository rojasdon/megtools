function write_header(fid, header)

%write_header(fid, header)
%
%Writes MSI pdf header
%
%Converts C-style strings into MATLAB string by removing zeros
%Otherwise there is no data conversion

%Revision 1.0  12/03/08  eugene.kronberg@uchsc.edu

if nargin ~= 2
    error('Wrong number of input arguments');
end

%need alignment
align_file(fid);

%first byte of the header
header_offset = ftell(fid);

%write dftk_header_data
 write_header_data(fid, header.header_data);

%write dftk_epoch_data
for epoch = 1:header.header_data.total_epochs;
     write_epoch_data(fid, header.epoch_data{epoch});
end

%read dftk_channel_ref_data
for channel = 1:header.header_data.total_chans
    write_channel_ref_data(fid, header.channel_data{channel});
end

%read dftk_event_data
for event = 1:header.header_data.total_fixed_events
     write_event_data(fid, header.event_data{event});
end

%it might not work for all processes, so we stop here
% %write dftk_proc_data
% for proc = 1:header.header_data.total_processes
%     write_proc_data(fid, header.proc_data{proc});
% end

%need alignment
align_file(fid);

%write the rest of the header as byte-array
fwrite(fid, header.header_tail, 'uint8');

%last 8 bytes of the pdf is header offset
%write header offset
fwrite(fid, header_offset, 'uint64');