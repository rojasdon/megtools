function varargout = rename(varargin)
% --------------------------------------------------------------------
% gui for renaming imported waveforms
% --------------------------------------------------------------------

global OLDNAME
if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');
    set(fig,'Color',get(0,'DefaultUicontrolBackgroundColor'));
    
	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);
	
    set(fig,'Visible','On');
    
    if nargout > 0
		varargout{1} = fig;
	end
    
    % set figure layout
    set_figure_layout(handles)
        
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback routines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
% pushbutton_Cancel_Callback: close window
% --------------------------------------------------------------------
function varargout = pushbutton_Cancel_Callback(h, eventdata, handles, varargin)
close;


% --------------------------------------------------------------------
% pushbutton_OK_Callback: Rename data set
% --------------------------------------------------------------------
function varargout = pushbutton_OK_Callback(h, eventdata, handles, varargin)
global WAVEFORMS        % imported waveforms
global OLDNAME          % old waveform name
global DATAWINDOW       % handle of the main window

% if the edited new name already exists, display error message
if ~isempty(strmatch(get(handles.edit_Newname,'String'),char(WAVEFORMS.name),'exact'))
    set(handles.edit_Newname,'String',OLDNAME);
    errordlg('This name already exists!','modal');
    return
end

% If no new name has been entered, display error message
if ~isempty(strmatch(get(handles.edit_Newname,'String'),'','exact'))
    set(handles.edit_Newname,'String',OLDNAME);
    errordlg('Please enter a new name!','modal');
    return
end

% Add the waveform with the new name to the global variable WAVEFORMS
NewWaveForm(get(handles.edit_Newname,'String'),WAVEFORMS(strmatch(OLDNAME,char(WAVEFORMS.name),'exact')).Npts,...
        WAVEFORMS(strmatch(OLDNAME,char(WAVEFORMS.name),'exact')).TSB,WAVEFORMS(strmatch(OLDNAME,char(WAVEFORMS.name),'exact')).DI, ... 
        WAVEFORMS(strmatch(OLDNAME,char(WAVEFORMS.name),'exact')).data,WAVEFORMS(strmatch(OLDNAME,char(WAVEFORMS.name),'exact')).type);
    
% Delete the waveform with the old name
WAVEFORMS(strmatch(OLDNAME,char(WAVEFORMS.name),'exact')) = [];

close;

% update listbox in main window
handles = guihandles(DATAWINDOW);
waveforms('update_listbox',handles);

% --------------------------------------------------------------------
% edit_Newname_Callback (empty)
% --------------------------------------------------------------------
function varargout = edit_Newname_Callback(h, eventdata, handles, varargin)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subfunction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
% set figure layout
% --------------------------------------------------------------------
function set_figure_layout(handles)
global OLDNAME
set(handles.text_Oldname,'String',OLDNAME);
set(handles.edit_Newname,'String',OLDNAME);
set(handles.figure_Rename,'Visible','Off','Units','Characters','Position',[10 10 60+length(OLDNAME) 5]);
movegui(handles.figure_Rename,'northwest');
set(handles.text_Oldname,'Units','Characters','Position',[25.8 3 length(OLDNAME)+15 1.2]);
set(handles.edit_Newname,'Units','Characters','Position',[25 1 length(OLDNAME)+15 1.5]);
set(handles.pushbutton_OK,'Units','Characters','Position',[45+length(OLDNAME) 0.9 10 1.6]);
set(handles.pushbutton_Cancel,'Units','Characters','Position',[45+length(OLDNAME) 2.6 10 1.6]);
set(handles.figure_Rename,'Visible','On');      
