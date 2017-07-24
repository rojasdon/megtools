% --------------------------------------------------------------------
% NewWaveForm: Add New Waveform to global variable WAVEFORMS
% --------------------------------------------------------------------
function NewWaveForm(name,Npts,TSB,DI,data,type)
global WAVEFORMS

% increase length of variable WAVEFORMS by 1 and assign all fields 
WAVEFORMS(length(WAVEFORMS)+1).name = name; 
WAVEFORMS(length(WAVEFORMS)).Npts = Npts;   
WAVEFORMS(length(WAVEFORMS)).TSB = TSB;
WAVEFORMS(length(WAVEFORMS)).DI = DI;
WAVEFORMS(length(WAVEFORMS)).data = data;
WAVEFORMS(length(WAVEFORMS)).type = type;

% sort the elements of WAVEFORMS by name
[sorted_names,sorted_index] = sortrows({WAVEFORMS.name}');
WAVEFORMS=WAVEFORMS(sorted_index);