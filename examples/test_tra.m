function grad = meg_sensors2grad(MEG)

% get some channel indices and numbers
megi  = find(strcmp({MEG.chn.type},'MEG'));
refi  = find(strcmp({MEG.chn.type},'REFERENCE'));
nchan = length(megi) + length(refi);
nmeg  = length(megi);
cind  = [megi refi];
locl                   = MEG.cloc(:,1:3);
locu                   = MEG.cloc(:,4:6);
oril                   = MEG.cori(:,1:3);
oriu                   = MEG.cori(:,4:6);
clabels                = char(MEG.chn(cind).label);
clabels                = clabels(:,1)';
magi                   = findstr(clabels,'M');
nmref                  = length(magi);
gradi                  = findstr(clabels,'G');
ngref                  = length(gradi);
ngrad                  = nmeg + ngref;

% location and orientation info to grad
j=1;
for i=1:2:ngrad*2
    grad.pnt(i,:)       = double(locl(j,1:3))/1e3;
    grad.ori(i,:)       = double(oril(j,1:3))/1e3;
    grad.pnt(i+1,:)     = double(locu(j,1:3))/1e3;
    grad.ori(i+1,:)     = double(oriu(j,1:3))/1e3;
    grad.label(j,1)     = {MEG.chn(cind(j)).label};
    j=j+1;
end

% magnetometer references separately
for i=1:nmref
    mag.pnt(i,:)       = double(locl(i,1:3))/1e3;
    mag.ori(i,:)       = double(oril(i,1:3))/1e3;
    mag.label(i,1)     = {MEG.chn(cind(magi(i))).label};
end

% add gradiometer and magnetometer location data
grad.pnt    = [grad.pnt;mag.pnt];
grad.ori    = [grad.ori;mag.ori];
grad.label  = [grad.label;mag.label];

% .tra field associates n grad coils with each other as single channel
grad.tra               = zeros(nchan,(nchan*2)-nmref,'double');
odds                   = 1:2:ngrad*2;
evens                  = 2:2:ngrad*2;
for i=1:ngrad
    grad.tra(i,odds(i))     = 1;
    grad.tra(i,evens(i))    = 1;
end

% add magnetometers to .tra field
grad.tra(ngrad+1:end,ngrad+1:end) = [zeros(nmref,ngrad) eye(nmref)];

end