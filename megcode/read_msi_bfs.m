function bfs = read_msi_bfs(filename)
% find best fit sphere from msi dipole text file

% open the file and start at beginning
fp = fopen(filename);
fseek(fp,0,'eof');
fsize = ftell(fp);
fseek(fp,0,'bof');
bfs_line = 9;

% skip to line with sphere coords
for ii = 1:bfs_line
   line = fgetl(fp);
end

% process text to extract coords - assumes in form of, eg., (-.2,4,6)
start           = strfind(line,'(');
stop            = strfind(line,')');
tmp             = line(start+1:end-1);
bfs             = zeros(1,3);
[coord rem]     = strtok(tmp,',');
bfs(1)          = str2num(coord);
[coord rem]     = strtok(rem,',');
bfs(2)          = str2num(coord);
[coord rem]     = strtok(rem,',');
bfs(3)          = str2num(coord);

fclose(fp);

end