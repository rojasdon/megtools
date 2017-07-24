function D = spm_correct_besa_avr_meg(file) 

% function to import BESA avr MEG exports and correct fields for SPM8
% assumes there are also available auxillary files from BESA raw export,
% since there are no sensor and scalp data exported in the avr export.

% FIXME: onset of prestim in ms from avr file, set for ERN experiment
onset = -600.145; 

% convert the avr to spm
D = spm_eeg_convert(file);
clear D;

% load the spm file
[pth nam ext] = fileparts(file);
spmfile = fullfile(pth,['spm8_' nam '.mat']);
load(spmfile);

% correct time field
D.timeOnset = onset/1e3;

% find bad channels
tmp = strtok(nam,'av'); % FIXME: this is specific to ERN experiment
tmp = tmp(1:end-1); % strip off trailing underscore
badnam = [tmp '-export.bad'];
if ~exist(badnam,'file')
    missing = 0;
else
    fp  = fopen(badnam);
    bad = textscan(fp,'%s');
    [nref junk] = find(~strncmp(bad{:},'R',1)); % exclude reference channels
    [megind junk] = find(strncmp(bad{:}(nref),'A',1)); % find MEG channels
    badmeglabels  = bad{:}(megind);
    missing = 1;
end

% confirm missing channels in avr file
fp   = fopen(file);
junk = fgetl(fp);
chn  = fgetl(fp);
chnlabels = textscan(chn,'%s');
if missing
    chanlabels = cell(length(badmeglabels));
    for i = 1:length(badmeglabels)
        if isempty(find(strcmp(badmeglabels{i},chnlabels{1})))
            % remove the 0 padding from BESA channel names
            ind = findstr(badmeglabels{i},'0');
            chanlabels{i} = badmeglabels{i};
            chanlabels{i}(ind) = [];
        end
    end
end 

% correct channel labeling
for i=248:-1:1
   chn = ['A' num2str(i)];
   if find(strcmp(chanlabels{:},chn))
       D.channels(i) = [];
   else
       D.channels(i).label = chn;
       D.channels(i).type  = 'MEG';
   end
end

% read positions from .pos file
basenam = [tmp '-export'];
tmp = besa_readloc([basenam '.pos'],248);
tmp = tmp*1e3; % scale to mm

% delete missing channel locations
for i=length(chanlabels):-1:1
    channum = str2num(chanlabels{:}(i,2:end));
    tmp(channum,:) = [];
end   
D.sensors(1).meg.unit = 'mm';

% pre allocate orientation, location and grad association (tra) fields
D.sensors.meg.ori = zeros(length(tmp)*2,3);
D.sensors.meg.pnt = zeros(length(tmp)*2,3);
D.sensors.meg.tra = zeros(length(tmp),length(tmp)*2,'double');
% distribute data to fields
ori(:,1) = tmp(:,8)*-1;
ori(:,2) = tmp(:,7)*-1;
ori(:,3) = tmp(:,9)*-1;
D.sensors.meg.ori(1:length(tmp),:) = ori;
D.sensors.meg.ori(length(tmp)+1:end,:) = ori*-1;
pnt1(:,1) = tmp(:,2);
pnt1(:,2) = -tmp(:,1);
pnt1(:,3) = tmp(:,3);
D.sensors.meg.pnt(1:length(tmp),:) = pnt1;
pnt2(:,1) = tmp(:,5);
pnt2(:,2) = -tmp(:,4);
pnt2(:,3) = tmp(:,6);
D.sensors.meg.pnt(length(tmp)+1:end,:) = pnt2;
D.sensors.meg.label         = cell(length(tmp),1);
for i=1:length(tmp)
    D.sensors.meg.tra(i,i)                = 1;
    D.sensors.meg.tra(i,i+length(tmp))    = 1;
    D.sensors.meg.label(i,1) = {D.channels(i).label};
end

% read in fiducials from *.sfp file
D.fiducials = besa_readsfp([basenam '.sfp']);

% save corrected file
save(spmfile, 'D');