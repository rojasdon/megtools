function MEG = meg_detect_drifts(MEG,varargin)

% defaults

switch MEG.type
    case 'cnt'
        eps = epocher(MEG,'sequential',1000,1000);
    otherwise
        % do nothing for now
end

end