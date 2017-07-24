% create an instantaneous SAM image - assumes you have erSAM done and named
% as source, although this would also work with other time domain
% beamformer data as long as the filters were saved. In practice,
% beamformer_lcmv and beamformer_sam should produce nearly identical
% results, with the main difference in the choice of fixedori = 'yes' in
% lcmv, which should be the same as fixedori = 'robert' in sam. Fixedori =
% 'spinning' in sam is unique to sam but also should not be too much
% different from other orientation optimization routines.

sample_ind=[191 523];
n_inside = numel(source.inside);
n_samples = numel(source.time);


% rectify pseudo-Z due to orientation spinning - see Cheyne et al. 2006
weights  = cell2mat(source.avg.filter);
n_sensors = numel(weights)/n_inside;
weights  = reshape(weights,n_sensors,n_inside);
leadfields = cell2mat(grid.leadfield);
noise  = svd(ft_avg.cov);
noise  = noise(end);
noise  = noise*eye(size(ft_avg.cov));
if numel(sample_ind) > 1
    b = mean(ft_avg.avg(:,sample_ind(1):sample_ind(2)),2);
else
    b      = ft_avg.avg(:,sample_ind);
end
bt     = b';
pow    = zeros(n_inside,1);

% iterate instantaneous power over the voxels - see Huang et al. 2004, equations 11 and 17
for ii=1:n_inside
    fprintf('Scanning location: %d\n',ii);
    w  = weights(:,ii);
    wt = w';
    pow(ii) = trace(wt*b*bt*w)/trace(wt*noise*w);
end

zmap         = source;
zmap.avg.pow = source.avg.pow;
zmap.avg.pow(source.inside) = pow;

zmapint = ft_sourceinterpolate(cfg_int,zmap,mri);

ft_write_mri('test_sam_sample.nii',...
    zmapint.avg.pow,'dataformat','nifti','transform',...
    mri.transform);

% alternatively, normalize the weights directly - eq. 6 Cheyne et al. 2007
wn = weights*nan;
for ii=1:n_inside
    fprintf('Scanning location: %d\n',ii);
    w  = weights(:,ii);
    wt = w';
    wn(:,ii) = w*(noise*wt*w)^.5;
    pow(ii) = trace(wn(:,ii)'*b*bt*wn(:,ii));
end