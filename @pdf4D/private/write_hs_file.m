function write_hs_file(fid, hs)

%write_hs_file(fid, hs)
%
%Writes MSI hs_file
%
%Converts C-style strings into MATLAB string by removing zeros
%Otherwise there is no data conversion

%Revision 1.0  12/04/08  eugene.kronberg@uchsc.edu

% if nargin < 1
%     error('Too few input argumets');
% end
% 
% if ~ishs(filename)
%     error('File %s is not head shape file', filename);
% end
% 
% fid = fopen(filename, 'r', 'b');
% 
% if fid == -1
%     error('Cannot open file %s', filename);
% end

write_hs_header(fid, hs.hdr);
write_hs_index(fid, hs.index);
fwrite(fid, hs.point, 'double');
