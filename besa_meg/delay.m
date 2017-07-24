function varargout = delay(varargin)
% --------------------------------------------------------------------
% gui for shifting the time axis of selected waveforms
% --------------------------------------------------------------------

global DELAYDATA    % selected data
global DL_TSB       % time sweep begins of selected data
global DL_T_END     % time sweep ends of selected data

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');
    set(fig,'Color',get(0,'DefaultUicontrolBackgroundColor'));
    
	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);
    
    % move the gui to upper left corner
    movegui(fig,'northwest');
    set(fig,'Visible','On');
    
    % Determine time sweep begins and time sweep ends of selected data
    len = size(DELAYDATA,2);
    DL_TSB = zeros(1,len);
    DL_T_END = zeros(1,len);
    for i=1:len
        DL_TSB(i)=DELAYDATA(i).TSB;
        DL_T_END(i)=DELAYDATA(i).TSB+(DELAYDATA(i).Npts-1)*DELAYDATA(i).DI;
    end
    
    if nargout > 0
		varargout{1} = fig;
	end

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
% edit_delay_Callback
% --------------------------------------------------------------------
function varargout = edit_delay_Callback(h, eventdata, handles, varargin)
% if no number is entered, set to zero
if isempty(str2num(get(handles.edit_delay,'String'))) 
    set(handles.edit_delay,'String',0);
end


% --------------------------------------------------------------------
% pushbutton_OK_Callback: shift time axis of selected data
% --------------------------------------------------------------------
function varargout = pushbutton_OK_Callback(h, eventdata, handles, varargin)
global DELAYDATA    % selected data
global DATAWINDOW   % handle of main window
global WAVEFORMS    

% if no delay is entered, display error message and close gui
if isempty(get(handles(1).edit_delay,'String'))
    close;
    errordlg('No delay time entered!','Error');
    return;
end

try
    for i=1:size(DELAYDATA,2)
        % shift time axis
        DELAYDATA(i).TSB = DELAYDATA(i).TSB-str2num(get(handles(1).edit_delay,'String'));
        % if the desired name exists already, delete the corresponding data set
        if ~isempty(strmatch([DELAYDATA(i).name,'_DEL',get(handles(1).edit_delay,'String'),'ms'],char(WAVEFORMS.name),'exact'))
            WAVEFORMS(strmatch([DELAYDATA(i).name,'_DEL',get(handles(1).edit_delay,'String'),'ms'],char(WAVEFORMS.name),'exact'))=[];
        end
        % Add shifted waveform to global variable WAVEFORM
        NewWaveForm([DELAYDATA(i).name,'_DEL',get(handles(1).edit_delay,'String'),'ms'],...
            DELAYDATA(i).Npts,DELAYDATA(i).TSB,DELAYDATA(i).DI,DELAYDATA(i).data,DELAYDATA(i).type);
    end
catch
    disp(lasterr);
end    
datawindowhandles = guihandles(DATAWINDOW);
waveforms('update_listbox',datawindowhandles);
close;


% --------------------------------------------------------------------
% pushbutton_Cancel_Callback
% --------------------------------------------------------------------
function varargout = pushbutton_Cancel_Callback(h, eventdata, handles, varargin)
close
