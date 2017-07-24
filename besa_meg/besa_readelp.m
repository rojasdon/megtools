function locs = besa_readelp(filename)

if isempty(findstr(filename,'.'))
  filename = [filename '.elp'];
end

locs.type       = [];
locs.label      = [];
locs.sph_theta  = [];
locs.sph_phi    = [];

tmp = textread(filename,'%s');

%this may need lots of mods to account for different sensor types!
offset = 1;
for i=1:length(tmp)/4
    locs(i).type    = char(tmp(offset));
    locs(i).label   = char(tmp(offset+1));
    locs(i).theta   = str2num(char(tmp(offset+2)));
    locs(i).phi     = str2num(char(tmp(offset+3)));
    offset          = offset + 4;
end

return