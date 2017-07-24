function [MEG ind] = epoch_extractor(MEG,type)
% PURPOSE:   extract epoched MEG data of a particular type from an epoched
%            file with more than a single type
% AUTHOR:    Don Rojas, Ph.D.  
% INPUT:     Required: MEG structure - see get4D.m
%                      type - trigger/response type     
% OUTPUT:    MEG structure with epoched data
% EXAMPLES:  eps = epoch_extractor(MEG,40) to extract all trials
%            corresponding to type 40
% SEE ALSO:  EPOCHER

% HISTORY:   07/07/10 - first version
%            05/08/11 - corrected problem in extracting epochs when epoch
%            had more than one event per trial, as per legal in EEGLAB type
%            epoch structure. Forces extraction on first event
%            09/16/11 - updates for revisions to MEG struct

% check input
if ~strcmp(MEG.type,'epochs'); error('Input must be epochs!'); end;
if nargin ~= 2; error('Wrong number of arguments!'); end;
if ~isfield(MEG,'epoch'); error('No epoch field present!'); end;

% FIXME: make more flexible - allow other than first event per trial to
% define the epoch extracted

% find/extract trials of desired type
tmp  = str2num(char(cellfun(@(v) v(1), {MEG.epoch.eventtype})));
ind  = find(tmp == type);

% return corrected MEG struct
MEG.epoch   = MEG.epoch(ind);
MEG.data    = MEG.data(ind,:,:);

% redo event structure

% [MEG.epoch MEG.events.events] = create_epochs(MEG.aux,MEG.time);
end