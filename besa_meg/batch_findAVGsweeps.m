% uses open source eeg_toolbox available at sourceforge

[files paths]=uigetfile('*.avg','MultiSelect','on');
nfiles = length(files);

% open text file for writing
[filename, filepath] = uiputfile('*.txt', 'Output file');
fpw = fopen(filename,'w');

for i=1:nfiles
    hdr = eeg_load_scan3avg(char(files(i)));
    disp(i);
    if (i == 1)
        fprintf(fpw,'File\t');
        fprintf(fpw,'Sweeps');
        fprintf(fpw,'\n');
    end
    fprintf(fpw,char(files(i)));
    fprintf(fpw,'\t');
    fprintf(fpw, num2str(hdr.nsweeps));
    fprintf(fpw,'\n');
end

fclose('all');