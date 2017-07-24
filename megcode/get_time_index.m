function tind = get_time_index(indat,t)
% function to return time index from structure when input t is in ms/s/etc  

if isfield(indat,'time')
        tind = get_index(indat.time,t);
else
    if isa(indat,'double')
        tind = get_index(indat,t);
    else
        error('Input does not contain time vector!');
    end
end