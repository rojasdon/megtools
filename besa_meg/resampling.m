function varargout = resampling(varargin)
% --------------------------------------------------------------------
% gui for resampling waveform data
% --------------------------------------------------------------------

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');
    set(fig,'Color',get(0,'DefaultUicontrolBackgroundColor'));
    
	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);
	if nargout > 0
		varargout{1} = fig;
	end
    
    % set figure layout
    set_figure_layout(handles);
       
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
			feval(varargin{:}); % FEVAL switchyard
		end
	catch
		disp(lasterr);
	end

end
        

% --------------------------------------------------------------------
% pushbutton_Cancel_Callback: Schließen des Fensters
% --------------------------------------------------------------------
function varargout = pushbutton_Cancel_Callback(h, eventdata, handles, varargin)
close;


% --------------------------------------------------------------------
% pushbutton_OK_Callback: Resampling
% --------------------------------------------------------------------
function varargout = pushbutton_OK_Callback(h, eventdata, handles, varargin)
global SELECTED_DATA_RESAMPLING      % selected data
global DATAWINDOW                    % handle of main window
global WAVEFORMS                     % imported waveforms
try
    for i=1:size(SELECTED_DATA_RESAMPLING,2)
        % resample data using cubic spline interpolation 
        newdata = spline([SELECTED_DATA_RESAMPLING(i).TSB:SELECTED_DATA_RESAMPLING(i).DI:SELECTED_DATA_RESAMPLING(i).TSB+(SELECTED_DATA_RESAMPLING(i).Npts-1)*SELECTED_DATA_RESAMPLING(i).DI],SELECTED_DATA_RESAMPLING(i).data,...
            [SELECTED_DATA_RESAMPLING(i).TSB:1000/str2num(get(handles.edit_Newrate,'String')):SELECTED_DATA_RESAMPLING(i).TSB+(SELECTED_DATA_RESAMPLING(i).Npts-1)*SELECTED_DATA_RESAMPLING(i).DI]);
        
        % check whether a waveform with the name '[basename]_RSP[new Sampling rate]' already exists. If yes, delete it
        if ~isempty(strmatch([SELECTED_DATA_RESAMPLING(i).name,'_RSP',get(handles.edit_Newrate,'String'),'Hz'],char(WAVEFORMS.name),'exact'))
            WAVEFORMS(strmatch([SELECTED_DATA_RESAMPLING(i).name,'_RSP',get(handles.edit_Newrate,'String'),'Hz'],char(WAVEFORMS.name),'exact'))=[];
        end
        
        % add resampled waveform to global variable WAVEFORMS with new name '[basename]_RSP[new Sampling rate]'.
        NewWaveForm([SELECTED_DATA_RESAMPLING(i).name,'_RSP',get(handles.edit_Newrate,'String'),'Hz'],size(newdata,2),SELECTED_DATA_RESAMPLING(i).TSB,...
            1000/str2num(get(handles.edit_Newrate,'String')),newdata,SELECTED_DATA_RESAMPLING(i).type);
    end
catch
    disp(lasterr);
end 
close

% update listbox in main window
datawindowhandles = guihandles(DATAWINDOW);
waveforms('update_listbox',datawindowhandles);


% --------------------------------------------------------------------
% edit_Newrate_Callback: edit new sampling rate
% --------------------------------------------------------------------
function varargout = edit_Newrate_Callback(h, eventdata, handles, varargin)

% check if entered string is a number; if not, clear edit field
if isempty(str2num(get(handles.edit_Newrate,'String')))
    set(handles.edit_Newrate,'String','');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subfunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
% set figure layout
% --------------------------------------------------------------------
function set_figure_layout(handles)
global SELECTED_DATA_RESAMPLING     % selected data to be resampled

% Determine number of selected data sets
len = size(SELECTED_DATA_RESAMPLING,2);

% Set 'wid' to be the length of the longest name of selected data, at least to 25
wid = 25;
for i=1:len
    if length(SELECTED_DATA_RESAMPLING(i).name) > wid
        wid = length(SELECTED_DATA_RESAMPLING(i).name);
    end
end

% Determine distance between time points of the selected waveforms
distances = zeros(1,size(SELECTED_DATA_RESAMPLING,2));
for i=1:size(SELECTED_DATA_RESAMPLING,2)
    distances(i)=SELECTED_DATA_RESAMPLING(i).DI;
end

% move gui to upper left corner and set position and entries of its uicontrols
set(handles.figure_Resampling,'Visible','Off','Units','Characters','Position',[10 10 45+wid 1.08*len+6.5]);
movegui(handles.figure_Resampling,'northwest');
set(handles.text_OldSamplingRate,'Units','Characters','Position',[18+wid 1.08*len+4.35 25 1]);
set(handles.text_datasets,'String',char(SELECTED_DATA_RESAMPLING.name),'Units','Characters','Position',[2 4 wid+18 1.08*len]);
set(handles.text_oldrate,'String',round(100000./distances)./100,'Units','Characters','Position',[23+wid 4 9 1.08*len]);
set(handles.frame,'Units','Characters','Position',[1 3.5 43+wid 1.08*len+2.5]);
set(handles.figure_Resampling,'Visible','On');