function [timestamp MEG] = meg_clinical_preprocess(pdf,id,sex,bd,timestamp,run,varargin)
% MEG Clinical Processing
% Reads 4D data, does filtering and offset, then exports EEG data to EDF+

% timestamp should be in form e.g., 10-Oct-2012 10:45:20' 
% time is 24 hr clock - i.e., military

% HISTORY: 10/02/12 original version
%          10/22/12 edits for functionality

% defaults
cutoffs = [1 70]; % in Hz for bandpass filter
sr      = 290;
dateaq  = datestr(floor(datenum(timestamp))); % date only
timeaq  = datestr(rem(datenum(timestamp),1)); % time only

% copy original in place
copyfile(pdf,[pdf ',orig']);

% read data
MEG = get4D(pdf);

% filter and offset
MEG = filterer(MEG,'band',cutoffs,'order',4);
MEG = offset(MEG);

% put processed copy in original's place in database
put4D([pdf ',orig'],pdf,MEG);

% if resampling requested, do prior to EEG extraction
if nargin > 7
    if strcmpi(varargin{1},'resample')
        switch varargin{2}
            case 'yes'
                MEG = resample_meg(MEG,sr);
            case 'no'
                % do nothing
        end
    end
end

% convert EEG to EDF+
meg_eeg2edf(MEG,id,sex,bd,dateaq,timeaq,run);
eseconds  = double(round(MEG.epdur));
timestamp = datestr(datenum(timestamp)+(datenum(2012,1,1,0,0,eseconds))-datenum(2012,1,1,0,0,0));

end