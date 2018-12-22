function locs = besa_readelp(filename)

if isempty(findstr(filename,'.'))
  filename = [filename '.elp'];
end

locs.type   = [];
locs.label  = [];
locs.theta  = [];
locs.phi    = [];

fid = fopen(filename);

%this may need lots of mods to account for different sensor types!
line = fgetl(fid); % first line is junk (usually)
ii = 1;
while ~feof(fid)
    line = fgetl(fid);
    tmp = textscan(line,'%s %s %s %s %d\n','delimiter','\t','MultipleDelimsAsOne',1);
    locs(ii).type    = char(tmp{1});
    locs(ii).label   = char(tmp{2});
    locs(ii).theta   = str2num(char(tmp{3}));
    locs(ii).phi     = str2num(char(tmp{4}));
    ii = ii + 1;
end

return