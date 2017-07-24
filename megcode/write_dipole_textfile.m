function write_dipole_textfile(dat,filename,varargin)

% writes a text file with dipole parameters for MRO to use for overlay

fp      = fopen(filename,'w');
ndip    = length(dat);
fields  = fieldnames(dat);
nfields = length(fields);
smin    = 1;
smax    = 100;


if nargin > 2
    weight = 1;
else
    weight = 0;
end

% weighting scheme
if weight
    if isfield(dat,'Gof')
        Gof  = [dat.Gof];
        minG = min(Gof);
        maxG = max(Gof);
        scale = ((smax - smin).*(Gof-minG))/(maxG-minG);
    end
end

for ii=1:ndip
    fprintf(fp,'%.1f : ',dat(ii).(fields{2}));
    fprintf(fp,'%.1f : ',dat(ii).(fields{3}));
    fprintf(fp,'%.1f ',dat(ii).(fields{4}));
    fprintf(fp,'[%.2e] no label\n',scale(ii));
end

fclose(fp);