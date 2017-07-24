function s = fix_checksum(obj, s) %#ok<INUSL>

if isfield(s, 'checksum')
    %zero out 'checksum' field
    s.checksum = int32(0);
    s.checksum = checksum(s);
elseif isfield(s, 'hdr')
    %this is device_data or user_block_data (config file)
    %zero out 'checksum' field
    s.hdr.checksum = int32(0);
    hdr_checksum = checksum(s.hdr);
    s.hdr.checksum = hdr_checksum + checksum(s) + 1;
else    
    fprintf('There is no checksum field in structure "%s"\n', inputname(2))
end