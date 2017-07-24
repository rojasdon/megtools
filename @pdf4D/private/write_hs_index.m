function write_hs_index(fid, index)

fwrite(fid, index.lpa, 'double');
fwrite(fid, index.rpa, 'double');
fwrite(fid, index.nasion, 'double');
fwrite(fid, index.cz, 'double');
fwrite(fid, index.inion, 'double');