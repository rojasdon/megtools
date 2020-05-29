function besa_writeevt(MEG,filebase,varargin)
% Writes a BESA compatible event file (*.evt) with events from input file
% History: 08/07/12 - fixed bug with conversion of type codes to numbers
%          10/11/12 - bug fix for empty events structure
%          05/29/20 - expanded options for format spec, adding Tmu/Tms
%          scaling

if isempty(strfind(filebase,'.evt'))
  filename = [filebase '.evt'];
end

if nargin == 3
    tspec = varargin{1};
else
    tspec = 'Tsec';
end

if ~isstruct(MEG.events)
    fprintf('No events structure to convert!\n');
    return;
else
    fp = fopen(filename,'w');
    % get events
    codes       = str2num(char({MEG.events.type}));
    switch tspec
        case 'Tsec'
            latencies   = [MEG.events.latency]*(1/MEG.sr); % convert to sec
        case 'Tmu'
            latencies   = [MEG.events.latency]*(1/MEG.sr)*1e6; % convert to microseconds
        case 'Tms'
            latencies   = [MEG.events.latency]*(1/MEG.sr)*1e3; % convert to milliseconds
    end
    nevents     = length(codes);
    % write them to file
    fprintf(fp,'%s\tCode\tTriNo\n\n',tspec);
    for ii=1:nevents
        fprintf(fp,'%.8f\t%d\t%d\n',latencies(ii),1,codes(ii));
    end
    fclose(fp);
end



