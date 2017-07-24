function fileopen
% --------------------------------------------------------------------
% gui for opening new .swf or .uwf files
% --------------------------------------------------------------------

global INITIALDIRECTORY         % current directory when 'waveforms' was launched
global DATAWINDOW               % handle of the main window
global FILEOPENDIRECTORY        % Directory to be displayed in the 'File open' dialog

% change to current file open directory
cd(FILEOPENDIRECTORY);

% open gui included in MATLAB for opening files and receive name and path of the file to be opened
try     % Version 7.x or higher: Multiple Files can be selected
    [filename,pathname] = uigetfile({'*.swf;*.uwf','Waveform files (*.swf, *.uwf)';'*.uwf', ...
        'User-defined waveforms (*.uwf)';'*.swf','BESA source waveform files (*.swf)'},'Open file','Multiselect','On');
catch   % Version 6.x or lower
        [filename,pathname] = uigetfile({'*.swf;*.uwf','Waveform files (*.swf, *.uwf)';'*.uwf', ...
        'User-defined waveforms (*.uwf)';'*.swf','BESA source waveform files (*.swf)'},'Open file');
end

if iscell(filename)
    for i=1:length(filename)    
        % import waveforms of selected file
        load_wf([pathname,char(filename(i))]);                   
        
        % update listbox in main window
        datawindowhandles = guihandles(DATAWINDOW);
        waveforms('update_listbox',datawindowhandles);
        
        % update FILEOPENDIRECTORY
        FILEOPENDIRECTORY = pathname;
    end
elseif filename~=0
    % import waveforms of selected file
    load_wf([pathname,filename]);                   
       
    % update listbox in main window
    datawindowhandles = guihandles(DATAWINDOW);
    waveforms('update_listbox',datawindowhandles);
        
    % update FILEOPENDIRECTORY
    FILEOPENDIRECTORY = pathname;
    
end
% change back to initial directory
cd(INITIALDIRECTORY);


% --------------------------------------------------------------------
% Funktion load_wf: read .swf or .uwf file
% --------------------------------------------------------------------
function load_wf(filename)
global WAVEFORMS

% get parts of the filename
[path,name,ext,ver] = fileparts(filename);
try
    % Read waveform file
 	[Npts,TSB,DI,waveName,data] = ReadWF(filename);
    
    % Get number of components
    komponenten = [1:length(waveName)];
   
    % check if waveform had been imported already; If not, add it to global variable WAVEFORMS
    if strcmp(char(waveName(1)),'grand_av')                 % for uwf-files containing data with confidence interval
        if strmatch(name,char(WAVEFORMS.name),'exact')
            return
        end
        NewWaveForm(name,Npts,TSB,DI,data,'boot')
    elseif strcmp(char(waveName(1)),'Datapoints')           % for other uwf-files (only one waveform)
        if strmatch(name,char(WAVEFORMS.name),'exact')
            return
        end
        NewWaveForm(name,Npts,TSB,DI,squeeze(data(1,:)),'single')
    else                                                    % for all other files (swf-files)
        for i=1:length(komponenten)
            if ~isempty(WAVEFORMS)
                if  strmatch([name,'_',char(waveName(i))],char(WAVEFORMS.name),'exact')
                    komponenten(i)=0;
                end
            end
        end
        for i=komponenten
            if i>0
                NewWaveForm([name,'_',char(waveName(i))],Npts,TSB,DI,squeeze(data(i,:)),'single')
            end
        end
    end
catch
    errordlg(lasterr,'File Type Error','modal')
end


