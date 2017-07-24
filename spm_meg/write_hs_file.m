function write_hs_file(filename, fids, coords)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Write Head Shape File - from E. Kronberg's MRO program
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%1st "dipole" in dpl_list must be lpa
%2nd "dipole" in dpl_list must be rpa
%3rd "dipole" in dpl_list must be nasion
%4th "dipole" in dpl_list must be cz
%5th "dipole" in dpl_list must be inion

version = 1;%current version (as of 04/21/05)
timestamp = 1234567890;%do we need real one?
checksum = 0;%for now, then we'll fix it

ndpl = numel(coords);
if ndpl < 5
    return
end

% prepend fids to coords
coords = [fids;coords];

npoints = ndpl - 5 % first 5 coords are fiducials

fid = fopen(filename, 'w', 'b');

fwrite(fid,version,'uint32');
fwrite(fid,timestamp,'int32');
fwrite(fid,checksum,'int32');
fwrite(fid,npoints,'int32');

for dpl = 1:ndpl
    for xyz=1:3
        fwrite(fid,coords(dpl,xyz)/1000,'double');%convert from [mm] to [m]
    end
end

fclose(fid);

%now fix checksum
fid = fopen(filename, 'r+', 'b');

%header includes version/timestamp/checksum/npoints
%plus all 5 index points (4*4 + 5*3*8 = 136 bytes)
hdr = fread(fid,136,'uchar');

%checksum must be such that sum of all bytes of the header equals -1
checksum = -(1 + sum(hdr));

%checksum is 3rd field of the header (offset 8 bytes)
fseek(fid, 8, 'bof');

fwrite(fid,checksum,'int32');

fclose(fid);