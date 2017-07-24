function besa_writeloc(filename,locs)
% Writes spherical coordinates to elp file
% Future extensibility to spherical/Cartesian and MEG vs. EEG.

if isempty(findstr(filename,'.'))
  filename = [filename '.elp'];
end
fp = fopen(filename,'w');

nchannels = length(locs);
for i=1:nchannels
    fprintf(fp,'%s\t%s\t%.2f\t%.2f\n',locs(i).type,locs(i).labels, ...
        locs(i).sph_theta, locs(i).sph_phi);
end

fclose(fp);
return;