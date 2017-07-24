function cinds = meg_channel_indices(MEG,type,chans)
% find channel indices in structure given channel numbers, without
% preceding 'A'
% input can vary as follows:
% 'type','multi','labels','bynum'
% multi: 'MEG'|'REFERENCE'|'TRIGGER'|'MAGREF'|'GRADREF',etc.
% labels: {'A141' 'GxxA'}, etc.
% bynum, 114, etc.

% check input
if nargin ~= 3
    error('There have to be exactly 3 input arguments to this function!');
end

switch lower(type)
    case 'multi'
        switch chans
            case 'MAGREF'
                cinds=find(strncmp({MEG.chn.label},'M',1));
            case 'GRADREF'
                cinds=find(strncmp({MEG.chn.label},'G',1));
            otherwise
                cinds=find(strcmpi({MEG.chn.type},chans));
        end
    case 'labels'
        cinds = zeros(1,length(chans));
        for i=1:length(chans)
            tmp      = find(ismember({MEG.chn.label},chans{i}));
            if ~isempty(tmp)
                cinds(i) = tmp;
            else
                fprintf('Channel %s not present!\n',chans{i});
            end
        end
        if sum(cinds) == 0; cinds = []; end;
    case 'bynum'
        cinds = zeros(1,length(chans));
        for i=1:length(chans)
            [junk, cinds(i)] = find([MEG.chn.num] == chans(i)); 
        end
    case 'non'
        % return all other types but type given
        types = {MEG.chn.type};
        cinds  = find(~strcmpi(types,chans));
    otherwise
        error('Input is not correct!');
end