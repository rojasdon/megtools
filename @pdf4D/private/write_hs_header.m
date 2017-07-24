function write_hs_header(fid, hdr)

fwrite(fid, hdr.version, 'uint32');
fwrite(fid, hdr.timestamp, 'int32');
fwrite(fid, hdr.checksum, 'int32');
fwrite(fid, hdr.npoints, 'int32');