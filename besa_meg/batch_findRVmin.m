% program to find the minimum residual variance/latency in an exported .dat file
% RV/GPF export from BESA source analysis (accessed in batch mode). Minor
% modifications would find GFP max/min, latencies, etc.

[files paths]=uigetfile('*.dat','MultiSelect','on');
nfiles = length(files);

% open text file for writing
[filename, filepath] = uiputfile('*.txt', 'Output file');
fpw = fopen(filename,'w');

for i=1:nfiles
    fpi = fopen(char(files(i)),'r');
    npts=fscanf(fpi, 'Npts= %d');
    ignore = fgetl(fpi); % ignore header line
    if (i == 1)
        fprintf(fpw,'File\t');
        fprintf(fpw,'MinRV');
        fprintf(fpw,'\n');
    end
    junk = fscanf(fpi, 'RV: ');
    RV = fscanf(fpi, '%f',[1, npts]);
    RV = RV(2:npts);
    minRV = num2str(min(RV));
    fprintf(fpw,char(files(i)));
    fprintf(fpw,'\t');
    fprintf(fpw, minRV);
    fprintf(fpw,'\n');
    fclose(fpi);
end

fclose('all');