function loc = besa_readloc(filename,nchan)
% function to read besa sensor location files into a variable
% FIXME: currently forces only .pos file reading - see line 14

if isempty(findstr(filename,'.'))
  filename = [filename,'.pos'];
end
fp = fopen(filename, 'r');

%determine type from file extension supplied
[path,file,ext,ver] = fileparts(filename);

%but force type to grad for testing
ext = 'pos';
switch ext
    case 'pos'
        nfields = 9;
    case 'pmg'
        nfields = 6;
    case 'elp'
        nfields = 3;
    otherwise
        nfields = 3;
end
loc = zeros(nchan,nfields,'single');
tmp = textread(filename,'%f');

%this may need lots of mods to account for different sensor types!
offset = 1;
for i=1:nchan
    loc(i,1:nfields) = tmp(offset:offset+nfields-1);
    offset = offset + nfields;
end

fclose(fp);