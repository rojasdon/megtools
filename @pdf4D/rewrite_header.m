function [stat, msg] = rewrite_header(obj, hdr)

% rewrite pdf header - no checks done !!!

filename = get(obj, 'filename');
if exist(filename, 'file') ~= 2
    error('File %s does not exist', filename)
end
fid = fopen(filename, 'r+', 'b');
if fid==-1
    error('Could no open file %s', filename)
end

%last 8 bytes of the pdf is header offset
fseek(fid, -8, 'eof');
header_offset = fread(fid,1,'uint64');

fseek(fid, header_offset, 'bof');
write_header(fid, hdr);

%get file size - by now should be at the end
fsize = ftell(fid);
fclose(fid);

trunc = sprintf('truncate -s <%d %s', fsize, filename);
[stat, msg] = unix(trunc);