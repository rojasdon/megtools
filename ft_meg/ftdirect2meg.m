function MEG = ftdirect2meg(ft,hs,varargin)
%PURPOSE:   converts Fieldtrip data to MEG struct
%AUTHOR:    Don Rojas, Ph.D.  
%INPUT:     ft   = fieldtrip data structure
%           hs   = headshape (use ft_read_headshape)
%OPTIONAL:  grad = gradiometer structure (can use ft_read_sens)
%OUTPUT:    MEG  = structure conforming to get4D()
%EXAMPLES:  MEG  = ft2meg(ft,hs,grad);
%SEE ALSO:  MEG2FT, MEG2SPM

%HISTORY:   06/15/11 - first version
%           05/23/13 - revised to avoid use of header trick in meg2ft.m.
%                      Will now convert files read originally into
%                      Fieldtrip

% check inputs
if nargin < 3
    if ~isfield(ft,'grad')
        error('gradiometer definition must be supplied to function');
    else
        grad = ft.grad;
    end
end
if nargin < 2
    error('At least 2 inputs must be supplied to function!');
end

% determine type
if isfield(ft,'avg')
    MEG.type = 'avg';
    ntrials  = 1;
else
    ntrials = length(ft.trial);
    if ntrials == 1
        MEG.type = 'cnt';
    else
        MEG.type = 'epochs';
        
    end
end

% basic info
MEG.sr      = ft.fsample;
MEG.time    = ft.time{1};
MEG.fname   = 'unknown';
MEG.pstim   = MEG.time(1);
MEG.epdur   = abs(MEG.time(1))+MEG.time(end);

% fiducials
MEG.fiducials           = hs;
MEG.fiducials.labels{1} = 'nas';
MEG.fiducials.labels{2} = 'lpa';
MEG.fiducials.labels{3} = 'rpa';

% channels - note that grad structure in FieldTrip often includes all
% channels, even if those are not present in data. Convention in MEG is to
% drop all data for channels, so we need to find the ones missing, if any,
% and not include channel data for those in the .chn struct
nchan = length(ft.label);
ngrad = length(find(ft_chantype(ft.label,'meg')));
% type of grad structure
if isfield(grad,'coilpos')
    gradtype = 'new';
else
    gradtype = 'old';
end

% sort channels so that order is reasonable
[Y,I]       = sort(ft.label); % first sort to separate major groups
ft.label    = ft.label(I);

% extract data
switch MEG.type
    case 'cnt'
        tmp      = cell2mat(ft.trial);
        MEG.data = tmp(I,:);
    case 'epochs'
        for trial=1:length(MEG.epoch)
            tmp                 = cell2mat(ft.trial{trial});
            MEG.data(trial,:,:) = tmp(1,I,:);
        end
    case 'avg'
        MEG.data = cell2mat(ft.avg(I,:));
end

% second sort to get MEG signal channels in order
labels      = char(ft.label);
order       = 1:nchan;
firstlet    = labels(:,1);
megind      = find(ismember(firstlet,'A'));
cnums       = zeros(1,ngrad);
for ii=1:ngrad
    cnums(ii) = str2num(strtok(labels(ii,:),'A'));
end
[Y,I] = sort(cnums); % second sort, only MEG signal chans
order(1:ngrad) = I;
ft.label       = ft.label(order);
switch MEG.type
    case {'cnt' 'avg'}
        MEG.data = MEG.data(order,:);
    case 'epochs'
        MEG.data = MEG.data(:,order,:);
end

% create grad structure
jj = 1; kk = 1;
for ii=1:nchan
    cname = ft.label{ii};
    MEG.chn(ii).label = cname;
    switch cname
        case {'TRIGGER' 'RESPONSE' 'UACurrent'}
            MEG.chn(ii).type  = cname;
            MEG.chn(ii).num   = [];
        otherwise
            ind   = find(strcmpi(grad.label, cname));
            cind  = find(grad.tra(ind,:)); % get upper and lower coil indices
            % fprintf('%d: %d %d %d\n',ii,ind,cind);
            switch gradtype
                case 'new'
                    if length(cind) == 2
                        MEG.cloc(jj,:) = [grad.coilpos(cind(1),:) grad.coilpos(cind(2),:)];
                        MEG.cori(jj,:) = [grad.coilori(cind(1),:) grad.coilori(cind(2),:)];
                    else
                        MEG.cloc(jj,:) = [grad.coilpos(cind,:) zeros(1,3)];
                        MEG.cloc(jj,:) = [grad.coilori(cind,:) zeros(1,3)];
                    end
                case 'old'
                    if length(cind) == 2
                        MEG.cloc(jj,:) = [grad.pnt(cind(1),:) grad.pnt(cind(2),:)];
                        MEG.cori(jj,:) = [grad.ori(cind(1),:) grad.ori(cind(2),:)];
                    else
                        MEG.cloc(jj,:) = [grad.pnt(cind,:) zeros(1,3)];
                        MEG.cloc(jj,:) = [grad.ori(cind,:) zeros(1,3)];
                    end
            end
            switch grad.chantype{ind}
                case 'meggrad'
                    MEG.chn(ii).type = 'MEG';
                    MEG.chn(ii).num  = kk;
                    kk = kk + 1;
                case {'refgrad' 'refmag'}
                    MEG.chn(ii).type = 'REFERENCE';
                    MEG.chn(ii).num  = [];
            end
            jj = jj + 1;
    end
end

MEG.events = [];

% find missing channels (assumes 248 channel MEG array)
A = {};
for ii=1:248
    A = [A ['A' num2str(ii)]];
end
MEG.mchan = setdiff(A,{MEG.chn.label});