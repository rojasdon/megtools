function varargout = boot(varargin)
% gui for determining average and bootstrap confidence interval

% Last Modified by GUIDE v2.0 06-Mar-2002 10:59:36

if nargin == 0  % LAUNCH GUI
    
    % open gui defined in 'boot.fig' and set background color
	fig = openfig(mfilename,'reuse');
    set(fig,'Color',get(0,'DefaultUicontrolBackgroundColor'));
    
	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);
    
    % move gui to the upper left screen corner
    movegui(fig,'northwest');
    set(fig,'Visible','On');
    
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
% pushbutton_OK_Callback
% --------------------------------------------------------------------
function varargout = pushbutton_OK_Callback(h, eventdata, handles, varargin)
global WAVEFORMS        % imported waveforms
global PLOTAXES         % handle of the axes in the plot window
global DATAWINDOW       % handle of the main window
global PLOTFIGURE       % handle of the plot figure
global BOOTSTRAP_DATA   % data selected for calculating average and confidence interval

% Check which confidence limit is selected and set z_alpha accordingly (Compare Efron/Tibshirani, BCa method)
switch get(handles.popupmenu_ci,'Value')
case 1
    z_alpha = 1.645;
    ci = '90%';
case 2
    z_alpha = 1.960;
    ci = '95%';
end
% initialize data matrix and close the gui window
data = zeros(size(BOOTSTRAP_DATA,2),BOOTSTRAP_DATA(1).Npts);
close;

% read data points of selected data
for i=1:size(BOOTSTRAP_DATA,2)
    data(i,:)=BOOTSTRAP_DATA(i).data;
end

% calculate average and confidence interval using the subfunction boot_ci_alpha
[grand_av,theta_lo,theta_hi] = boot_ci_alpha(data,z_alpha);

% Make plot window visible and set current axes to those in the plot window
try
    set(PLOTFIGURE,'Visible','On');
catch       % if plot window does not exist yet
    plotwindow;
    set(PLOTFIGURE,'Visible','On');
end
try
    axes(PLOTAXES);
catch
    plotwindow
end
% Clear axes
cla;
% name the new waveform 'bootstrap_(bootnumber)_CI(ci)', where bootnumber counts from 1 onwards
% first determine which bootnumbers already exist with that confidence interval
bootnumber=1;
i=1;
while i<=length(WAVEFORMS)
    if strcmp(['bootstrap_',num2str(bootnumber),'_CI',ci],char(WAVEFORMS(i).name))
        bootnumber=bootnumber+1;
        i=0;
    end
    i=i+1;
end
% add new data set with the desired name to the variable WAVEFORMS
NewWaveForm(['bootstrap_',num2str(bootnumber),'_CI',ci],BOOTSTRAP_DATA(1).Npts,BOOTSTRAP_DATA(1).TSB,BOOTSTRAP_DATA(1).DI,[grand_av;theta_lo;theta_hi],'boot')

% update list box in main window
datawindowhandles = guihandles(DATAWINDOW);
guidata(DATAWINDOW, datawindowhandles);
waveforms('update_listbox',datawindowhandles);

% get indices of the selected data sets
index = zeros(1,size(BOOTSTRAP_DATA,2));
for i=1:size(BOOTSTRAP_DATA,2)
    index(i)=strmatch(char(BOOTSTRAP_DATA(i).name),char(WAVEFORMS.name),'exact');
end
% activate selected data and the new bootstrap data in list box of main window
set(datawindowhandles.listbox,'Value',[index strmatch(['bootstrap_',num2str(bootnumber),'_CI',ci],char(WAVEFORMS.name),'exact')])
% plot original and averaged data
waveforms('pushbutton_Plot_Callback',h, eventdata,datawindowhandles,varargin);
% check which buttons are to be enabled in the main window
waveforms('set_button_enabling',datawindowhandles);
    

% --------------------------------------------------------------------
% pushbutton_Cancel_Callback (close bootstrap window)
% --------------------------------------------------------------------
function varargout = pushbutton_Cancel_Callback(h, eventdata, handles, varargin)
close


% --------------------------------------------------------------------
% popupmenu_ci_Callback (empty)
% --------------------------------------------------------------------
function varargout = popupmenu_ci_Callback(h, eventdata, handles, varargin)
