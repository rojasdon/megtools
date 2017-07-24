function xyz = meg_bestfitsphere(pnts)
% function to create a best fitting sphere given a set of 3D coordinates,
% an initial start location and a desired radius

% get initial starting estimate
initloc = mean(pnts);
dist    = pnts-repmat(initloc,1176,1);
geodist = sqrt(dist(1).^2+dist(2).^2+dist(3).^2);

dat = [pnts repmat(initloc,length(pnts),1) repmat(geodist,length(pnts),1)];
xyz = fminsearch(@sphere_err,dat);

end

% error function
function sumdist = sphere_err(inputdat)
    pnts = inputdat(:,1:3);
    xyz  = inputdat(:,4:6);
    r    = inputdat(:,7);
    sumdist = sum(abs(sum((pnts - xyz) - repmat(r,1,3))));
end