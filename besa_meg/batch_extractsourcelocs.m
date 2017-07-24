% batch script to read in BESA dipole files (*.bsa) and output a single
% line per file into another file (i.e., 1 file per subject into 1 file per
% group of subjects). User can choose to read first or second dipole if it
% is a 2-dipole solution (i.e., left or right).

filefilt = '*EarRight_av_L4000.bsa';

% setappdata(0,'UseNativeSystemDialogs',false);
[files paths]=uigetfile(filefilt,'MultiSelect','on');

if ischar(files)
    nfiles = 1;
else
    nfiles = size(files,2);
end

% open text file for writing
[filename, filepath] = uiputfile('*.txt', 'Output file');

% prompt for number of dipole to read in each file - logic could be
% extended here and in loop to have more dipole choices than 2
[selection,dialog]=uigetpref('mygraphics',... % Group
       'dipnumber','Choose dipole',...                  
       {'Number of Dipole in File To Read?'},...
       {'1','2';'1','2'},...       % Values and button strings
       'DefaultButton','1');        % Callback for Help button
   
fpw = fopen(filename,'w');

for ii=1:nfiles
    if ischar(files)
        fpi = fopen(files,'r');
    else
        fpi = fopen(char(files(ii)),'r');
    end
    ignore = fgetl(fpi);
    ignore = fgetl(fpi);
    if (ii == 1)
        fprintf(fpw,'File\t');
        fprintf(fpw,ignore);
        fprintf(fpw,'\n');
    end
    ignore = fgetl(fpi);
    source = fgetl(fpi); % read 1st dipole line
    if (str2num(selection) == 2)
        source = fgetl(fpi); % read another line if 2nd dipole chosen
    end
    if nfiles == 1
        fprintf(fpw,files);
    else
        fprintf(fpw,char(files{ii}(1:4)));
    end
    fprintf(fpw,'\t');
    fprintf(fpw, source);
    fprintf(fpw,'\n');
    fclose(fpi);
end

fclose('all');