function MEG = deleter(MEG,bad,varargin)
% PURPOSE: delete bad channels from datasets
% AUTHOR:  Don Rojas, Ph.D.
% INPUT:   MEG struct from get4D.m
%          bad = cell array of bad channel labels
%          group = optional, a channel group such
%          as 'MEG', 'EEG', 'REFERENCE', 'EXT'
% EXAMPLE: deleted = deleter(MEG, {'A1','A122'}); % delete individual MEG
%                    channels
%          deleted = deleter(MEG, {}, 'EEG'); % delete all EEG channels
% OUTPUT:  MEG struct with deleted channels (MEG.mchan will have list of
%          deleted channels)
% SEE ALSO: GET4D

% HISTORY: 10/5/10 - revised to convert input numbers to channel labels rather to
%          avoid potentially serious problems with already reduced datasets
%          and multiple uses of deleter
%          10/6/10 - added code to prevent deleter from trying to delete
%          same channel twice
%          8/21/11 - changed bad input from channel index to channel name
%          for more robust behavior - will work with previously deleted
%          files by updating field to new format
%          8/24/11 - bugfix for listing channels out of order in input -
%          increased speed of deletion by more efficient indexing
%          5/11/12 - added capability for channel group deletion
%          10/31/12 - made group deletion more robust

%  ascertain if group is requested
if nargin > 2
    ind = meg_channel_indices(MEG,'multi',varargin{1});
else
    % finding index of requested channel(s)
    ind   = zeros(1,length(bad));
    for i = 1:length(bad)
        tmp = meg_channel_indices(MEG,'labels',bad(i));
        if isempty(tmp)
            error('Requested channel is already missing from structure: %s',...
               bad{i});
        else
            ind(i)      = tmp;
        end
    end
    [~, orig] = sort(ind);
end

% delete channel data
switch MEG.type
    case 'epochs'
        MEG.data(:,ind,:)   = [];
    otherwise
        MEG.data(ind,:)     = [];
end

% delete location and orientation data, if channel type is MEG
for ii=1:numel(ind)
    if strcmpi(MEG.chn(ind(ii)).type,'MEG')
        MEG.cloc(ind(ii),:)     = [];
        MEG.cori(ind(ii),:)     = [];
    end
end

% redo missing channel info for MEG channels only
if find(strcmpi({MEG.chn(ind).type},'MEG'))
    oldmchanind = [];
    for ii = 1:numel(MEG.mchan);
        oldmchanind = [oldmchanind str2num(strrep(char(MEG.mchan(ii)),'A',''))];
    end
    MEG.mchan = [MEG.mchan bad];
    % sort the mchan field
    [~, orig]     = sort([oldmchanind ind]);
    MEG.mchan     = MEG.mchan(orig);
end

% delete channel info
MEG.chn(ind)        = [];

end
