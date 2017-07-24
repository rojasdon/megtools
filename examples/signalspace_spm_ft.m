function [ssp, W] = signalspace_spm_ft(D,source)
% PURPOSE:  To perform signal (source) space projection using SPM structure
%           and Fieldtrip functions
% AUTHOR:   Don Rojas
% NOTES:    1) SPM does not have a wrapper function for
%             compute_leadfields.m, so if this call fails on unknown 
%             function, create one by copying another wrapper to name 
%             of ft_compute_leadfields.m in ../external/fieldtrip/ directory.
%           2) will use only first time point of source model if more than 1
% INPUT:    D = SPM8 meeg structure
%           source = struct from ft source fit - must include
%                   .dip.pos 1 x 3 array for dipole location and
%                   .dip.mom 1 x 3 array for dipole moment
% OUPUT:    ssp = virtual channel in either 1 x nsamp dimension for average
%                input or nepochs x nsamp dimensions for epoched input
%           W   = weight vector for ssp
% ALSO SEE: signal_space_ft.m, for alternative using MEG struct and generic
%           input for source and volume information.

% spm eeg defaults
spm('defaults','eeg');

% check for inverse field
if ~isfield(D, 'inv')
    error('There is no inverse field in the D struct!');
end

val = 1; % this assumption could be problematic - need input to func

% configure ft structure from SPM data
vol             = D.inv{val}.forward(val).vol;
datareg         = D.inv{val}.datareg(val);
sens            = datareg.sensors;
M1              = datareg.toMNI;
[U,L,V]         = svd(M1(1:3, 1:3));
M1(1:3,1:3)     = U*V';
vol             = ft_transform_vol(M1,vol);
sens            = ft_transform_sens(M1,sens);

% compute leadfields (L), pseudoinverse of L (Li) and normalized Q (Qn)
if size(source.time,1) > 1 % force use of first time point if multiple
    moment = source.dip.mom(1:3,1);
else
    moment = source.dip.mom(1:3);
end
if size(source.dip.pos,1) > 1 % force use of first dipole if multidipole
    pos    = source.dip.pos(1,:);
else
    pos    = source.dip.pos;
end
L   = ft_compute_leadfield(pos,sens,vol); % see NOTES
Li  = pinv(L);
Qn  = double(moment)/norm(moment);

% compute weight vector
W = zeros(1,length(L),'single');
for i = 1:length(L)
    W(i) = dot(Li(:,i),Qn(1:3));
end

% do projection onto trials of input data
ssp = zeros(D.ntrials,D.nsamples);
Wt   = repmat(W',1,D.nsamples);
fprintf('Projecting ssp weights to trials...');
for trial = 1:D.ntrials
    fprintf('\nApplying projection to trial: %d',trial);
    data         = squeeze(D(1:length(L),:,trial));
    ssp(trial,:) = dot(data,Wt);
end
fprintf('\ndone!\n');

end