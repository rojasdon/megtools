function besa_writeevt(MEG,filebase)
% Writes a BESA compatible event file (*.evt) with events from input file
% History: 08/07/12 - fixed bug with conversion of type codes to numbers
%          10/11/12 - bug fix for empty events structure

if isempty(strfind(filebase,'.evt'))
  filename = [filebase '.evt'];
end

if ~isstruct(MEG.events)
    fprintf('No events structure to convert!\n');
    return;
else
    fp = fopen(filename,'w');
    % get events
    codes       = str2num(char({MEG.events.type}));
    latencies   = [MEG.events.latency]*(1/MEG.sr); % convert to sec
    nevents     = length(codes);
    % write them to file
    fprintf(fp,'Tsec\tCode\tTriNo\n');
    for ii=1:nevents
        fprintf(fp,'%.4f\t%d\t%d\n',latencies(ii),1,codes(ii));
    end
    fclose(fp);
end



