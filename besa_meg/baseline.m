function varargout = baseline(varargin)
% BASELINE Application M-file for baseline.fig
%    FIG = BASELINE launch baseline GUI.
%    BASELINE('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 23-Feb-2002 19:18:54

global SELECTED_DATA_BASELINE
global BL_TSB
global BL_T_END
if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');
    set(fig,'Color',get(0,'DefaultUicontrolBackgroundColor'));
    
	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
    guidata(fig,handles);
    
    movegui(fig,'northwest');
    set(fig,'Visible','On');
    
    len = size(SELECTED_DATA_BASELINE,2);
    BL_TSB = zeros(1,len);
    BL_T_END = zeros(1,len);
    for i=1:len
        BL_TSB(i)=SELECTED_DATA_BASELINE(i).TSB;
        BL_T_END(i)=SELECTED_DATA_BASELINE(i).TSB+(SELECTED_DATA_BASELINE(i).Npts-1)*SELECTED_DATA_BASELINE(i).DI;
    end
    set(handles.edit_basemin,'String',num2str((round(max(BL_TSB)*100))/100));
    if max(BL_TSB)>0
        set(handles.edit_basemax,'String',num2str((round(max(BL_TSB)*100))/100));
    else
        set(handles.edit_basemax,'String',0);
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
function varargout = edit_basemin_Callback(h, eventdata, handles, varargin)
global BL_TSB
global BL_T_END
if isempty(str2num(get(handles.edit_basemin,'String'))) ...
        | (str2num(get(handles.edit_basemin,'String')) < max(BL_TSB)) ...
        | (str2num(get(handles.edit_basemin,'String')) > min(BL_T_END))
    set(handles.edit_basemin,'String',num2str((round(max(BL_TSB)*100))/100));
end


% --------------------------------------------------------------------
function varargout = edit_basemax_Callback(h, eventdata, handles, varargin)
global SELECTED_DATA_BASELINE
global BL_TSB
global BL_T_END
if isempty(str2num(get(handles.edit_basemax,'String'))) ...
        | (str2num(get(handles.edit_basemax,'String')) > min(BL_T_END)) ...
        | (str2num(get(handles.edit_basemax,'String')) < max(BL_TSB))
    if max(BL_TSB)>0
        set(handles.edit_basemax,'String',num2str((round(max(BL_TSB)*100))/100));
    else
        set(handles.edit_basemax,'String',0);
    end
end


% --------------------------------------------------------------------
function varargout = pushbutton_OK_Callback(h, eventdata, handles, varargin)
global SELECTED_DATA_BASELINE
global WAVEFORMS
global DATAWINDOW
try
    for i=1:size(SELECTED_DATA_BASELINE,2)
        datapoints = SELECTED_DATA_BASELINE(i).data;
        datapoints = datapoints - mean(datapoints(1,round((str2num(get(handles.edit_basemin,'String'))-SELECTED_DATA_BASELINE(i).TSB)/SELECTED_DATA_BASELINE(i).DI)+1: ...
            round((str2num(get(handles.edit_basemax,'String'))-SELECTED_DATA_BASELINE(i).TSB)/SELECTED_DATA_BASELINE(i).DI)+1),2);
        if ~isempty(strmatch([SELECTED_DATA_BASELINE(i).name,'_BSL[',get(handles.edit_basemin,'String'),';',get(handles.edit_basemax,'String'),']'],char(WAVEFORMS.name),'exact'))
            WAVEFORMS(strmatch([SELECTED_DATA_BASELINE(i).name,'_BSL[',get(handles.edit_basemin,'String'),';',get(handles.edit_basemax,'String'),']'],char(WAVEFORMS.name),'exact'))=[];
        end
        NewWaveForm([SELECTED_DATA_BASELINE(i).name,'_BSL[',get(handles.edit_basemin,'String'),';',get(handles.edit_basemax,'String'),']'],...
            SELECTED_DATA_BASELINE(i).Npts,SELECTED_DATA_BASELINE(i).TSB,SELECTED_DATA_BASELINE(i).DI,datapoints,SELECTED_DATA_BASELINE(i).type);
    end
catch
    disp(lasterr);
end
datawindowhandles = guihandles(DATAWINDOW);
waveforms('update_listbox',datawindowhandles);
close;


% --------------------------------------------------------------------
function varargout = pushbutton_Cancel_Callback(h, eventdata, handles, varargin)
close
