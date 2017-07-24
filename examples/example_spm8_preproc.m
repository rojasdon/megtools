% example script to do processing on an SPM8 MEEG continuous file,
% including epoching, averaging, filtering and baseline correction

% defaults
spm('defaults','eeg');

% get a continuous meeg file
file = 'spm8_c,rfhp0.mat';
D = spm_eeg_load(file);

% epoch the file if continuous
if strcmp(D.type,'continuous')
    fprintf('\nEpoching...');
    S.D = D;
    S.pretrig = -200;
    S.posttrig = 800;
    S.trialdef.conditionlabel = 'Stim';
    S.trialdef.eventtype = 'TRIGGER_up'; % can be up or down, TRIGGER or RESPONSE
    S.trialdef.eventvalue = 4106; % if file converted using spm8, then add 4096 to trig
                                  % value if you used triggers that set bit 0
                                  % (e.g., a value of 11). This is 4D
                                  % specific. If you didn't set bit 0, then
                                  % do not add 4096
    S.reviewtrials = 0;
    S.save = 0;
    D=spm_eeg_epochs(S);
    fprintf('\ndone!\n');
else
    fprintf('File is not continuous!\n');
end

% average using SPM
fprintf('\nAveraging...');
S.D = D;
S.robust = 0;
S.review = 0;
D = spm_eeg_average(S);
fprintf('\ndone!\n');

% low-pass filter using SPM
fprintf('\nFiltering...');
S.D = D;
S.filter.type = 'butterworth';
S.filter.band = 'low';
S.filter.PHz = 35;
S.filter.parameter = [];
D = spm_eeg_filter(S);
fprintf('\ndone!\n');

% offset correct using SPM
fprintf('\nBaseline correction...');
S.D    = D;
S.time = [-200 0];
D      = spm_eeg_bc(S);
fprintf('\ndone!\n');