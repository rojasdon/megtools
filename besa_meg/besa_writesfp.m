function besa_writesfp(MEG,filename)
% function to write BESA sfp file

% scaling
scale = 1e3;
tobesa = true;

% format filename correctly
if isempty(findstr(filename,'.'))
  filename = [filename '.sfp'];
end

% open file
fp = fopen(filename,'w');

% this part switches the 4D coordinates into BESA coordinates
if tobesa
    pnt         = MEG.fiducials.pnt;
    fid         = MEG.fiducials.fid.pnt;
    newpnt      = zeros(size(pnt));
    newpnt(:,1) = -pnt(:,2);
    newpnt(:,2) = pnt(:,1);
    newpnt(:,3) = pnt(:,3);
    newfid(:,1) = -fid(:,2);
    newfid(:,2) = fid(:,1);
    newfid(:,3) = fid(:,3);
    MEG.fiducials.pnt = newpnt;
    MEG.fiducials.fid.pnt = newfid;
end
    

% write fiducials
fprintf(fp,'%s\t%.2f\t%.2f\t%.2f\n','FidNAS',MEG.fiducials.fid.pnt(1,1)*scale,...
    MEG.fiducials.fid.pnt(1,2)*scale, MEG.fiducials.fid.pnt(1,3)*scale);
fprintf(fp,'%s\t%.2f\t%.2f\t%.2f\n','FidLPA',MEG.fiducials.fid.pnt(2,1)*scale,...
    MEG.fiducials.fid.pnt(2,2)*scale, MEG.fiducials.fid.pnt(2,3)*scale);
fprintf(fp,'%s\t%.2f\t%.2f\t%.2f\n','FidRPA',MEG.fiducials.fid.pnt(3,1)*scale,...
    MEG.fiducials.fid.pnt(3,2)*scale, MEG.fiducials.fid.pnt(3,3)*scale);

% headshape
for ii=1:size(MEG.fiducials.pnt,1)
    fprintf(fp,'%s\t%.2f\t%.2f\t%.2f\n',['Sfh' deblank(num2str(ii))],...
        MEG.fiducials.pnt(ii,1)*scale,MEG.fiducials.pnt(ii,2)*scale,MEG.fiducials.pnt(ii,3)*scale);
end

fclose(fp);

return