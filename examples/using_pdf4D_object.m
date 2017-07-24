% example of using Eugene Kronberg's low level object code access to 4D
% datafile - see pdf4D.m function for further information

% set defaults
meg_defaults;

% directory for data
[pth,~,~] = fileparts(which('meg_defaults'));

% check if data are downloaded
if exist(fullfile(pth,'sample_data','auditory'),'dir')
    cd(fullfile(pth,'sample_data','auditory'));
else
    error('Sample dataset not present!');
end

% create object
pdf = pdf4D('c,rfhp0.1Hz');

% read header
hdr     = pdf.header;

% find MEG channel indices
megind = channel_index(pdf,'MEG','name');

% read some data
sr    = double(get(pdf,'dr'));
nsamp = hdr.epoch_data{1}.pts_in_epoch;
nmeg  = length(megind);
data  = shiftdim(reshape(read_data_block(pdf,[],megind),nmeg,nsamp,[]),2);
time  = (1:size(data,2))*1/sr;

% plot some data scaled to fT
figure('color','w');
plot(time,data(1:247,:)*1e15); % channel 248 is bad in example data
xlabel('Seconds'); ylabel('fT');