function varargout = options(varargin)
% --------------------------------------------------------------------
% gui for setting plot options
% --------------------------------------------------------------------

global SHADED_AREA      % Value 1: confidence interval displayed as shaded area; Value 2: confidence interval displayed as lines
global COLORORDER       % [20 x 3]-matrix. Current color order if several curves are plotted within one graph
global CURRENTCOLOR     % the color of the currently edited color number
global CURRENTNUMBER    % number between 1 and 20. Determines which entry in the vector color order is currently edited

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');
    set(fig,'Color',get(0,'DefaultUicontrolBackgroundColor'));
    
	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);
    
    % position options figure in upper left corner
    movegui(handles.figure_options,'northwest');
    set(handles.figure_options,'Visible','On');
    
    % initialize the radiobuttons for selecting the appearance of confidence intervals
    if exist('SHADED_AREA') & SHADED_AREA == 0
        set(handles.radiobutton_shadedarea,'Value',0);
        set(handles.radiobutton_lines,'Value',1);
    end
    
    % initialize backgroundcolors of the togglebuttons to the current color selection
    for i=1:20
        set(eval(['handles.togglebutton',num2str(i)]),'BackgroundColor',COLORORDER(1+mod(i-1,max(size(COLORORDER))),:));
    end
    
    % set color button 1 
    set(handles.togglebutton1,'Value',1);
    
    % set CURRENTCOLOR to be the current color number 1
    CURRENTCOLOR = get(handles.togglebutton1,'BackgroundColor');
    CURRENTNUMBER = 1;
    
    % set slider and edit values to red/green/blue values of the current color
    set(handles.slider_red,'Value',CURRENTCOLOR(1)*100);
    set(handles.slider_green,'Value',CURRENTCOLOR(2)*100);
    set(handles.slider_blue,'Value',CURRENTCOLOR(3)*100);
    set(handles.edit_red,'String',num2str(CURRENTCOLOR(1)*100));
    set(handles.edit_green,'String',num2str(CURRENTCOLOR(2)*100));
    set(handles.edit_blue,'String',num2str(CURRENTCOLOR(3)*100));
    
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
% radiobutton_shadedarea_Callback: choose that confidence intervals are to be drawn as shaded area
% --------------------------------------------------------------------
function varargout = radiobutton_shadedarea_Callback(h, eventdata, handles, varargin)
if get(handles.radiobutton_shadedarea,'Value')==0       % if the radiobutton was on before, don't turn it off
    set(handles.radiobutton_shadedarea,'Value',1);
else                                                    
    off = handles.radiobutton_lines;                    % turn the other radiobutton off
    mutual_exclude(off);
end


% --------------------------------------------------------------------
% radiobutton_lines_Callback: choose that confidence intervals are to be drawn as lines
% --------------------------------------------------------------------
function varargout = radiobutton_lines_Callback(h, eventdata, handles, varargin)
if get(handles.radiobutton_lines,'Value')==0            % if the radiobutton was on before, don't turn it off
    set(handles.radiobutton_lines,'Value',1);
else
    off = handles.radiobutton_shadedarea;               % turn the other radiobutton off
    mutual_exclude(off);
end


% --------------------------------------------------------------------
% pushbutton_Cancel_Callback
% --------------------------------------------------------------------
function varargout = pushbutton_Cancel_Callback(h, eventdata, handles, varargin)
close;


% --------------------------------------------------------------------
% slider_red_Callback: Edit red value of the current color
% --------------------------------------------------------------------
function varargout = slider_red_Callback(h, eventdata, handles, varargin)
global CURRENTCOLOR         % current color
global CURRENTNUMBER        % number of the current color
NewVal = get(h,'Value');
set(handles.edit_red,'String',NewVal)
set(eval(['handles.togglebutton',num2str(CURRENTNUMBER)]),...
    'BackgroundColor',[NewVal str2num(get(handles.edit_green,'String')) str2num(get(handles.edit_blue,'String'))]/100);

% --------------------------------------------------------------------
% slider_green_Callback: Edit green value of the current color
% --------------------------------------------------------------------
function varargout = slider_green_Callback(h, eventdata, handles, varargin)
global CURRENTCOLOR         % current color
global CURRENTNUMBER        % number of the current color
NewVal = get(h,'Value');
set(handles.edit_green,'String',NewVal)
set(eval(['handles.togglebutton',num2str(CURRENTNUMBER)]),...
    'BackgroundColor',[str2num(get(handles.edit_red,'String')) NewVal str2num(get(handles.edit_blue,'String'))]/100);

% --------------------------------------------------------------------
% slider_blue_Callback: Edit blue value of the current color
% --------------------------------------------------------------------
function varargout = slider_blue_Callback(h, eventdata, handles, varargin)
global CURRENTCOLOR         % current color
global CURRENTNUMBER        % number of the current color
NewVal = get(h,'Value');
set(handles.edit_blue,'String',NewVal)
set(eval(['handles.togglebutton',num2str(CURRENTNUMBER)]),...
    'BackgroundColor',[str2num(get(handles.edit_red,'String')) str2num(get(handles.edit_green,'String')) NewVal]/100);

% --------------------------------------------------------------------
% edit_red_Callback: Edit red value of the current color
% --------------------------------------------------------------------
function varargout = edit_red_Callback(h, eventdata, handles, varargin)
global CURRENTCOLOR         % current color
global CURRENTNUMBER        % number of the current color
NewStrVal = get(h,'String');
NewVal = str2num(NewStrVal);
if  isempty(NewVal) | (NewVal<0) | (NewVal>100),
    OldVal = get(handles.slider_red,'Value');
    set(h,'String',OldVal)
else
    set(handles.slider_red,'Value',NewVal)
    set(eval(['handles.togglebutton',num2str(CURRENTNUMBER)]),...
        'BackgroundColor',[NewVal str2num(get(handles.edit_green,'String')) str2num(get(handles.edit_blue,'String'))]/100);
end

% --------------------------------------------------------------------
% edit_green_Callback: Edit green value of the current color
% --------------------------------------------------------------------
function varargout = edit_green_Callback(h, eventdata, handles, varargin)
global CURRENTCOLOR         % current color
global CURRENTNUMBER        % number of the current color
NewStrVal = get(h,'String');
NewVal = str2num(NewStrVal);
if  isempty(NewVal) | (NewVal<0) | (NewVal>100),
    OldVal = get(handles.slider_green,'Value');
    set(h,'String',OldVal)
else
    set(handles.slider_green,'Value',NewVal)
    set(eval(['handles.togglebutton',num2str(CURRENTNUMBER)]),...
        'BackgroundColor',[str2num(get(handles.edit_red,'String')) NewVal str2num(get(handles.edit_blue,'String'))]/100);
end

% --------------------------------------------------------------------
% edit_blue_Callback: Edit blue value of the current color
% --------------------------------------------------------------------
function varargout = edit_blue_Callback(h, eventdata, handles, varargin)
global CURRENTCOLOR         % current color
global CURRENTNUMBER        % number of the current color
NewStrVal = get(h,'String');
NewVal = str2num(NewStrVal);
if  isempty(NewVal) | (NewVal<0) | (NewVal>100),
    OldVal = get(handles.slider_blue,'Value');
    set(h,'String',OldVal)
else
    set(handles.slider_blue,'Value',NewVal)
    set(eval(['handles.togglebutton',num2str(CURRENTNUMBER)]),...
        'BackgroundColor',[str2num(get(handles.edit_red,'String')) str2num(get(handles.edit_green,'String')) NewVal]/100);
end


% --------------------------------------------------------------------
% pushbutton_OK_Callback: Save new plot options
% --------------------------------------------------------------------
function varargout = pushbutton_OK_Callback(h, eventdata, handles, varargin)
global SHADED_AREA
global COLORORDER
if get(handles.radiobutton_shadedarea,'Value') == 0
    SHADED_AREA = 0;
else
    SHADED_AREA = 1;
end
COLORORDER=zeros(20,3);
for i=1:20
    COLORORDER(i,:) = get(eval(['handles.togglebutton',num2str(i)]),'BackgroundColor');
end
close;

% --------------------------------------------------------------------
% pushbutton_default_Callback: set color values back to default
% --------------------------------------------------------------------
function varargout = pushbutton_default_Callback(h, eventdata, handles, varargin)
global DEFAULTCOLORORDER        % Default color order, defined in 'waveforms.m'
global COLORORDER
global CURRENTCOLOR
global CURRENTNUMBER

% set colors of togglebuttons to default values
for i=1:20
    set(eval(['handles.togglebutton',num2str(i)]),'BackgroundColor',DEFAULTCOLORORDER(1+mod(i-1,max(size(DEFAULTCOLORORDER))),:));
end
CURRENTCOLOR = get(eval(['handles.togglebutton',num2str(CURRENTNUMBER)]),'BackgroundColor');


% set slider and edit values to default values
set(handles.slider_red,'Value',CURRENTCOLOR(1)*100);
set(handles.slider_green,'Value',CURRENTCOLOR(2)*100);
set(handles.slider_blue,'Value',CURRENTCOLOR(3)*100);
set(handles.edit_red,'String',num2str(CURRENTCOLOR(1)*100));
set(handles.edit_green,'String',num2str(CURRENTCOLOR(2)*100));
set(handles.edit_blue,'String',num2str(CURRENTCOLOR(3)*100));


% --------------------------------------------------------------------
% pushbutton_Save_Callback
% --------------------------------------------------------------------
function varargout = pushbutton_Save_Callback(h, eventdata, handles, varargin)

colororder_current=zeros(20,3);
for i=1:20
    colororder_current(i,:) = get(eval(['handles.togglebutton',num2str(i)]),'BackgroundColor');
end

% open gui for selecting a name of the file to save the data in
[filename,pathname] = uiputfile('colororder.clr','Save color order');
if filename == 0
    return;
end
[pathstr,basename,ext,versn] = fileparts(filename);

% append extension '.clr' if not already existent
if isempty(strmatch(ext,'.clr','exact'))
    filename = [filename,'.clr'];
end

% Save data
fid = fopen([pathname,filename],'w');
for i=1:20
    fprintf(fid,'%f %f %f \n',colororder_current(i,:));
end
fclose(fid);


% --------------------------------------------------------------------
% pushbutton_Load_Callback
% --------------------------------------------------------------------
function varargout = pushbutton_Load_Callback(h, eventdata, handles, varargin)
global COLORORDER
global CURRENTCOLOR
global CURRENTNUMBER

% open gui for selecting a name of the file to save the data in
[filename,pathname] = uigetfile('colororder.clr','Save color order');
if filename == 0
    return;
end
[pathstr,basename,ext,versn] = fileparts(filename);

% append extension '.clr' if not already existent
if isempty(strmatch(ext,'.clr','exact'))
    filename = [filename,'.clr'];
end

% Read data
fid = fopen([pathname,filename],'r');
a = fscanf(fid,'%f  %f  %f \n');
fclose(fid);

colororder_new = zeros(20,3);
for i=1:20
    colororder_new(i,1) = a(3*i-2);
    colororder_new(i,2) = a(3*i-1);
    colororder_new(i,3) = a(3*i);
end

% set backgroundcolors of the togglebuttons to the loaded color selection
for i=1:20
    set(eval(['handles.togglebutton',num2str(i)]),'BackgroundColor',colororder_new(1+mod(i-1,max(size(COLORORDER))),:));
end

% set slider and edit values to red/green/blue values of the current color
CURRENTCOLOR = colororder_new(CURRENTNUMBER,:);
set(handles.slider_red,'Value',CURRENTCOLOR(1)*100);
set(handles.slider_green,'Value',CURRENTCOLOR(2)*100);
set(handles.slider_blue,'Value',CURRENTCOLOR(3)*100);
set(handles.edit_red,'String',num2str(CURRENTCOLOR(1)*100));
set(handles.edit_green,'String',num2str(CURRENTCOLOR(2)*100));
set(handles.edit_blue,'String',num2str(CURRENTCOLOR(3)*100));    

% --------------------------------------------------------------------
% Subfunction mutal_exclude: Set values of all selected ui's to zero
% --------------------------------------------------------------------
function mutual_exclude(off)
set(off,'Value',0)


% ---------------------------------------------------------------------------------------------------
% Togglebutton Callbacks: choose number of the color to be edited
% ---------------------------------------------------------------------------------------------------

% --------------------------------------------------------------------
function varargout = togglebutton1_Callback(h, eventdata, handles, varargin)
global CURRENTCOLOR         % current color
global CURRENTNUMBER        % number of the current color

if get(h,'Value')==0        % if the button was pressed before, don't release it but leave it pressed
    set(h,'Value',1);
else
    % release the toggle button that was pressed so far
    set(eval(['handles.togglebutton',num2str(CURRENTNUMBER)]),'Value',0);
    
    % set the number of the current color to 1 and the current color to the background color of the togglebutton
    CURRENTNUMBER = 1;
    CURRENTCOLOR = get(h,'BackgroundColor');
    
    % set sliders and corresponding edit fields to the values of the current color
    set(handles.slider_red,'Value',CURRENTCOLOR(1)*100);
    set(handles.slider_green,'Value',CURRENTCOLOR(2)*100);
    set(handles.slider_blue,'Value',CURRENTCOLOR(3)*100);
    set(handles.edit_red,'String',num2str(CURRENTCOLOR(1)*100));
    set(handles.edit_green,'String',num2str(CURRENTCOLOR(2)*100));
    set(handles.edit_blue,'String',num2str(CURRENTCOLOR(3)*100));
end

% --------------------------------------------------------------------
function varargout = togglebutton2_Callback(h, eventdata, handles, varargin)
global CURRENTCOLOR
global CURRENTNUMBER
if get(h,'Value')==0
    set(h,'Value',1);
else
    set(eval(['handles.togglebutton',num2str(CURRENTNUMBER)]),'Value',0);
    CURRENTNUMBER = 2;
    CURRENTCOLOR = get(h,'BackgroundColor');
    set(handles.slider_red,'Value',CURRENTCOLOR(1)*100);
    set(handles.slider_green,'Value',CURRENTCOLOR(2)*100);
    set(handles.slider_blue,'Value',CURRENTCOLOR(3)*100);
    set(handles.edit_red,'String',num2str(CURRENTCOLOR(1)*100));
    set(handles.edit_green,'String',num2str(CURRENTCOLOR(2)*100));
    set(handles.edit_blue,'String',num2str(CURRENTCOLOR(3)*100));
end

% --------------------------------------------------------------------
function varargout = togglebutton3_Callback(h, eventdata, handles, varargin)
global CURRENTCOLOR
global CURRENTNUMBER
if get(h,'Value')==0
    set(h,'Value',1);
else
    set(eval(['handles.togglebutton',num2str(CURRENTNUMBER)]),'Value',0);
    CURRENTNUMBER = 3;
    CURRENTCOLOR = get(h,'BackgroundColor');
    set(handles.slider_red,'Value',CURRENTCOLOR(1)*100);
    set(handles.slider_green,'Value',CURRENTCOLOR(2)*100);
    set(handles.slider_blue,'Value',CURRENTCOLOR(3)*100);
    set(handles.edit_red,'String',num2str(CURRENTCOLOR(1)*100));
    set(handles.edit_green,'String',num2str(CURRENTCOLOR(2)*100));
    set(handles.edit_blue,'String',num2str(CURRENTCOLOR(3)*100));
end

% --------------------------------------------------------------------
function varargout = togglebutton4_Callback(h, eventdata, handles, varargin)
global CURRENTCOLOR
global CURRENTNUMBER
if get(h,'Value')==0
    set(h,'Value',1);
else
    set(eval(['handles.togglebutton',num2str(CURRENTNUMBER)]),'Value',0);
    CURRENTNUMBER = 4;
    CURRENTCOLOR = get(h,'BackgroundColor');
    set(handles.slider_red,'Value',CURRENTCOLOR(1)*100);
    set(handles.slider_green,'Value',CURRENTCOLOR(2)*100);
    set(handles.slider_blue,'Value',CURRENTCOLOR(3)*100);
    set(handles.edit_red,'String',num2str(CURRENTCOLOR(1)*100));
    set(handles.edit_green,'String',num2str(CURRENTCOLOR(2)*100));
    set(handles.edit_blue,'String',num2str(CURRENTCOLOR(3)*100));
end

% --------------------------------------------------------------------
function varargout = togglebutton5_Callback(h, eventdata, handles, varargin)
global CURRENTCOLOR
global CURRENTNUMBER
if get(h,'Value')==0
    set(h,'Value',1);
else
    set(eval(['handles.togglebutton',num2str(CURRENTNUMBER)]),'Value',0);
    CURRENTNUMBER = 5;
    CURRENTCOLOR = get(h,'BackgroundColor');
    set(handles.slider_red,'Value',CURRENTCOLOR(1)*100);
    set(handles.slider_green,'Value',CURRENTCOLOR(2)*100);
    set(handles.slider_blue,'Value',CURRENTCOLOR(3)*100);
    set(handles.edit_red,'String',num2str(CURRENTCOLOR(1)*100));
    set(handles.edit_green,'String',num2str(CURRENTCOLOR(2)*100));
    set(handles.edit_blue,'String',num2str(CURRENTCOLOR(3)*100));
end

% --------------------------------------------------------------------
function varargout = togglebutton6_Callback(h, eventdata, handles, varargin)
global CURRENTCOLOR
global CURRENTNUMBER
if get(h,'Value')==0
    set(h,'Value',1);
else
    set(eval(['handles.togglebutton',num2str(CURRENTNUMBER)]),'Value',0);
    CURRENTNUMBER = 6;
    CURRENTCOLOR = get(h,'BackgroundColor');
    set(handles.slider_red,'Value',CURRENTCOLOR(1)*100);
    set(handles.slider_green,'Value',CURRENTCOLOR(2)*100);
    set(handles.slider_blue,'Value',CURRENTCOLOR(3)*100);
    set(handles.edit_red,'String',num2str(CURRENTCOLOR(1)*100));
    set(handles.edit_green,'String',num2str(CURRENTCOLOR(2)*100));
    set(handles.edit_blue,'String',num2str(CURRENTCOLOR(3)*100));
end

% --------------------------------------------------------------------
function varargout = togglebutton7_Callback(h, eventdata, handles, varargin)
global CURRENTCOLOR
global CURRENTNUMBER
if get(h,'Value')==0
    set(h,'Value',1);
else
    set(eval(['handles.togglebutton',num2str(CURRENTNUMBER)]),'Value',0);
    CURRENTNUMBER = 7;
    CURRENTCOLOR = get(h,'BackgroundColor');
    set(handles.slider_red,'Value',CURRENTCOLOR(1)*100);
    set(handles.slider_green,'Value',CURRENTCOLOR(2)*100);
    set(handles.slider_blue,'Value',CURRENTCOLOR(3)*100);
    set(handles.edit_red,'String',num2str(CURRENTCOLOR(1)*100));
    set(handles.edit_green,'String',num2str(CURRENTCOLOR(2)*100));
    set(handles.edit_blue,'String',num2str(CURRENTCOLOR(3)*100));
end

% --------------------------------------------------------------------
function varargout = togglebutton8_Callback(h, eventdata, handles, varargin)
global CURRENTCOLOR
global CURRENTNUMBER
if get(h,'Value')==0
    set(h,'Value',1);
else
    set(eval(['handles.togglebutton',num2str(CURRENTNUMBER)]),'Value',0);
    CURRENTNUMBER = 8;
    CURRENTCOLOR = get(h,'BackgroundColor');
    set(handles.slider_red,'Value',CURRENTCOLOR(1)*100);
    set(handles.slider_green,'Value',CURRENTCOLOR(2)*100);
    set(handles.slider_blue,'Value',CURRENTCOLOR(3)*100);
    set(handles.edit_red,'String',num2str(CURRENTCOLOR(1)*100));
    set(handles.edit_green,'String',num2str(CURRENTCOLOR(2)*100));
    set(handles.edit_blue,'String',num2str(CURRENTCOLOR(3)*100));
end

% --------------------------------------------------------------------
function varargout = togglebutton9_Callback(h, eventdata, handles, varargin)
global CURRENTCOLOR
global CURRENTNUMBER
if get(h,'Value')==0
    set(h,'Value',1);
else
    set(eval(['handles.togglebutton',num2str(CURRENTNUMBER)]),'Value',0);
    CURRENTNUMBER = 9;
    CURRENTCOLOR = get(h,'BackgroundColor');
    set(handles.slider_red,'Value',CURRENTCOLOR(1)*100);
    set(handles.slider_green,'Value',CURRENTCOLOR(2)*100);
    set(handles.slider_blue,'Value',CURRENTCOLOR(3)*100);
    set(handles.edit_red,'String',num2str(CURRENTCOLOR(1)*100));
    set(handles.edit_green,'String',num2str(CURRENTCOLOR(2)*100));
    set(handles.edit_blue,'String',num2str(CURRENTCOLOR(3)*100));
end

% --------------------------------------------------------------------
function varargout = togglebutton10_Callback(h, eventdata, handles, varargin)
global CURRENTCOLOR
global CURRENTNUMBER
if get(h,'Value')==0
    set(h,'Value',1);
else
    set(eval(['handles.togglebutton',num2str(CURRENTNUMBER)]),'Value',0);
    CURRENTNUMBER = 10;
    CURRENTCOLOR = get(h,'BackgroundColor');
    set(handles.slider_red,'Value',CURRENTCOLOR(1)*100);
    set(handles.slider_green,'Value',CURRENTCOLOR(2)*100);
    set(handles.slider_blue,'Value',CURRENTCOLOR(3)*100);
    set(handles.edit_red,'String',num2str(CURRENTCOLOR(1)*100));
    set(handles.edit_green,'String',num2str(CURRENTCOLOR(2)*100));
    set(handles.edit_blue,'String',num2str(CURRENTCOLOR(3)*100));
end

% --------------------------------------------------------------------
function varargout = togglebutton11_Callback(h, eventdata, handles, varargin)
global CURRENTCOLOR
global CURRENTNUMBER
if get(h,'Value')==0
    set(h,'Value',1);
else
    set(eval(['handles.togglebutton',num2str(CURRENTNUMBER)]),'Value',0);
    CURRENTNUMBER = 11;
    CURRENTCOLOR = get(h,'BackgroundColor');
    set(handles.slider_red,'Value',CURRENTCOLOR(1)*100);
    set(handles.slider_green,'Value',CURRENTCOLOR(2)*100);
    set(handles.slider_blue,'Value',CURRENTCOLOR(3)*100);
    set(handles.edit_red,'String',num2str(CURRENTCOLOR(1)*100));
    set(handles.edit_green,'String',num2str(CURRENTCOLOR(2)*100));
    set(handles.edit_blue,'String',num2str(CURRENTCOLOR(3)*100));
end

% --------------------------------------------------------------------
function varargout = togglebutton12_Callback(h, eventdata, handles, varargin)
global CURRENTCOLOR
global CURRENTNUMBER
if get(h,'Value')==0
    set(h,'Value',1);
else
    set(eval(['handles.togglebutton',num2str(CURRENTNUMBER)]),'Value',0);
    CURRENTNUMBER = 12;
    CURRENTCOLOR = get(h,'BackgroundColor');
    set(handles.slider_red,'Value',CURRENTCOLOR(1)*100);
    set(handles.slider_green,'Value',CURRENTCOLOR(2)*100);
    set(handles.slider_blue,'Value',CURRENTCOLOR(3)*100);
    set(handles.edit_red,'String',num2str(CURRENTCOLOR(1)*100));
    set(handles.edit_green,'String',num2str(CURRENTCOLOR(2)*100));
    set(handles.edit_blue,'String',num2str(CURRENTCOLOR(3)*100));
end

% --------------------------------------------------------------------
function varargout = togglebutton13_Callback(h, eventdata, handles, varargin)
global CURRENTCOLOR
global CURRENTNUMBER
if get(h,'Value')==0
    set(h,'Value',1);
else
    set(eval(['handles.togglebutton',num2str(CURRENTNUMBER)]),'Value',0);
    CURRENTNUMBER = 13;
    CURRENTCOLOR = get(h,'BackgroundColor');
    set(handles.slider_red,'Value',CURRENTCOLOR(1)*100);
    set(handles.slider_green,'Value',CURRENTCOLOR(2)*100);
    set(handles.slider_blue,'Value',CURRENTCOLOR(3)*100);
    set(handles.edit_red,'String',num2str(CURRENTCOLOR(1)*100));
    set(handles.edit_green,'String',num2str(CURRENTCOLOR(2)*100));
    set(handles.edit_blue,'String',num2str(CURRENTCOLOR(3)*100));
end

% --------------------------------------------------------------------
function varargout = togglebutton14_Callback(h, eventdata, handles, varargin)
global CURRENTCOLOR
global CURRENTNUMBER
if get(h,'Value')==0
    set(h,'Value',1);
else
    set(eval(['handles.togglebutton',num2str(CURRENTNUMBER)]),'Value',0);
    CURRENTNUMBER = 14;
    CURRENTCOLOR = get(h,'BackgroundColor');
    set(handles.slider_red,'Value',CURRENTCOLOR(1)*100);
    set(handles.slider_green,'Value',CURRENTCOLOR(2)*100);
    set(handles.slider_blue,'Value',CURRENTCOLOR(3)*100);
    set(handles.edit_red,'String',num2str(CURRENTCOLOR(1)*100));
    set(handles.edit_green,'String',num2str(CURRENTCOLOR(2)*100));
    set(handles.edit_blue,'String',num2str(CURRENTCOLOR(3)*100));
end

% --------------------------------------------------------------------
function varargout = togglebutton15_Callback(h, eventdata, handles, varargin)
global CURRENTCOLOR
global CURRENTNUMBER
if get(h,'Value')==0
    set(h,'Value',1);
else
    set(eval(['handles.togglebutton',num2str(CURRENTNUMBER)]),'Value',0);
    CURRENTNUMBER = 15;
    CURRENTCOLOR = get(h,'BackgroundColor');
    set(handles.slider_red,'Value',CURRENTCOLOR(1)*100);
    set(handles.slider_green,'Value',CURRENTCOLOR(2)*100);
    set(handles.slider_blue,'Value',CURRENTCOLOR(3)*100);
    set(handles.edit_red,'String',num2str(CURRENTCOLOR(1)*100));
    set(handles.edit_green,'String',num2str(CURRENTCOLOR(2)*100));
    set(handles.edit_blue,'String',num2str(CURRENTCOLOR(3)*100));
end

% --------------------------------------------------------------------
function varargout = togglebutton16_Callback(h, eventdata, handles, varargin)
global CURRENTCOLOR
global CURRENTNUMBER
if get(h,'Value')==0
    set(h,'Value',1);
else
    set(eval(['handles.togglebutton',num2str(CURRENTNUMBER)]),'Value',0);
    CURRENTNUMBER = 16;
    CURRENTCOLOR = get(h,'BackgroundColor');
    set(handles.slider_red,'Value',CURRENTCOLOR(1)*100);
    set(handles.slider_green,'Value',CURRENTCOLOR(2)*100);
    set(handles.slider_blue,'Value',CURRENTCOLOR(3)*100);
    set(handles.edit_red,'String',num2str(CURRENTCOLOR(1)*100));
    set(handles.edit_green,'String',num2str(CURRENTCOLOR(2)*100));
    set(handles.edit_blue,'String',num2str(CURRENTCOLOR(3)*100));
end

% --------------------------------------------------------------------
function varargout = togglebutton17_Callback(h, eventdata, handles, varargin)
global CURRENTCOLOR
global CURRENTNUMBER
if get(h,'Value')==0
    set(h,'Value',1);
else
    set(eval(['handles.togglebutton',num2str(CURRENTNUMBER)]),'Value',0);
    CURRENTNUMBER = 17;
    CURRENTCOLOR = get(h,'BackgroundColor');
    set(handles.slider_red,'Value',CURRENTCOLOR(1)*100);
    set(handles.slider_green,'Value',CURRENTCOLOR(2)*100);
    set(handles.slider_blue,'Value',CURRENTCOLOR(3)*100);
    set(handles.edit_red,'String',num2str(CURRENTCOLOR(1)*100));
    set(handles.edit_green,'String',num2str(CURRENTCOLOR(2)*100));
    set(handles.edit_blue,'String',num2str(CURRENTCOLOR(3)*100));
end

% --------------------------------------------------------------------
function varargout = togglebutton18_Callback(h, eventdata, handles, varargin)
global CURRENTCOLOR
global CURRENTNUMBER
if get(h,'Value')==0
    set(h,'Value',1);
else
    set(eval(['handles.togglebutton',num2str(CURRENTNUMBER)]),'Value',0);
    CURRENTNUMBER = 18;
    CURRENTCOLOR = get(h,'BackgroundColor');
    set(handles.slider_red,'Value',CURRENTCOLOR(1)*100);
    set(handles.slider_green,'Value',CURRENTCOLOR(2)*100);
    set(handles.slider_blue,'Value',CURRENTCOLOR(3)*100);
    set(handles.edit_red,'String',num2str(CURRENTCOLOR(1)*100));
    set(handles.edit_green,'String',num2str(CURRENTCOLOR(2)*100));
    set(handles.edit_blue,'String',num2str(CURRENTCOLOR(3)*100));
end

% --------------------------------------------------------------------
function varargout = togglebutton19_Callback(h, eventdata, handles, varargin)
global CURRENTCOLOR
global CURRENTNUMBER
if get(h,'Value')==0
    set(h,'Value',1);
else
    set(eval(['handles.togglebutton',num2str(CURRENTNUMBER)]),'Value',0);
    CURRENTNUMBER = 19;
    CURRENTCOLOR = get(h,'BackgroundColor');
    set(handles.slider_red,'Value',CURRENTCOLOR(1)*100);
    set(handles.slider_green,'Value',CURRENTCOLOR(2)*100);
    set(handles.slider_blue,'Value',CURRENTCOLOR(3)*100);
    set(handles.edit_red,'String',num2str(CURRENTCOLOR(1)*100));
    set(handles.edit_green,'String',num2str(CURRENTCOLOR(2)*100));
    set(handles.edit_blue,'String',num2str(CURRENTCOLOR(3)*100));
end

% --------------------------------------------------------------------
function varargout = togglebutton20_Callback(h, eventdata, handles, varargin)
global CURRENTCOLOR
global CURRENTNUMBER
if get(h,'Value')==0
    set(h,'Value',1);
else
    set(eval(['handles.togglebutton',num2str(CURRENTNUMBER)]),'Value',0);
    CURRENTNUMBER = 20;
    CURRENTCOLOR = get(h,'BackgroundColor');
    set(handles.slider_red,'Value',CURRENTCOLOR(1)*100);
    set(handles.slider_green,'Value',CURRENTCOLOR(2)*100);
    set(handles.slider_blue,'Value',CURRENTCOLOR(3)*100);
    set(handles.edit_red,'String',num2str(CURRENTCOLOR(1)*100));
    set(handles.edit_green,'String',num2str(CURRENTCOLOR(2)*100));
    set(handles.edit_blue,'String',num2str(CURRENTCOLOR(3)*100));
end



