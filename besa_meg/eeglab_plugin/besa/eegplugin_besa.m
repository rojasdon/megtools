%eegplugin_besa() - import/export from/to BESA using generic data format

function vers = eegplugin_besagen(fig, try_strings, catch_strings);

%with 'vers' output plugin will be treated as "plugin" and not as "plugin function"
vf = fopen(fullfile(fileparts(mfilename), 'version.txt'),'r');
if vf == -1
    vers = 'besa generic beta';
else
    vers = fgetl(vf);
    fclose(vf);
end

%find menu objects
importmenu = findobj(fig,'tag','import data');
exportmenu = findobj(fig,'tag','export');

%callbacks
impgen = [try_strings.no_check '[EEG LASTCOM] = pop_besa2eeg;' catch_strings.new_non_empty];
expgen = [try_strings.no_check 'LASTCOM = pop_eeg2besa(EEG);' catch_strings.add_to_hist];

%menu items
imenu = uimenu(importmenu,'label','Import BESA generic (.dat)','callback',impgen,'separator','on');
emenu = uimenu(exportmenu,'label','Export BESA generic (.dat)','callback',expgen,'separator','on');
