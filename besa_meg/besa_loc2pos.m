%get list of files to convert
loclist=dir('*.loc');
nfiles=length(loclist);

%convert files
for i=1:nfiles
    [path,file,ext,ver] = fileparts(loclist(i).name);
    loc2pos(loclist(i).name,file);
end