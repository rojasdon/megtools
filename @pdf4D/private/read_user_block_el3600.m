%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Read eeg locations (COHBlock)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% from dftk_config_blocks.h
%#	define DFTK_LABEL_STRLEN	(16)
% // ---------- electrode location ----------
% struct elec_entry
% {	char	label[DFTK_LABEL_STRLEN];
% 	Pnt	loc;
% };
function el = read_user_block_el3600(fid, user_space_size)
nel = user_space_size/40;
el = cell(1,nel);

for ii=1:length(el)
    el{ii} = read_el_loc(fid);
end

function el = read_el_loc(fid)
el.label = read_el_label(fid);
el.loc = fread(fid, 3, '*double');

function label = read_el_label(fid)
DFTK_LABEL_STRLEN = 16;

l = fread(fid, [1,DFTK_LABEL_STRLEN], '*uint8');
z = find(l==0,1);
if z == 1
    label = '';
else
    label = char(l(1:z-1));
end