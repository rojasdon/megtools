function frind = get_frequency_index(tf,t)
% function to return time index from tf structure when input f is in Hz
    if isfield(tf,'freq')
        frind = get_index(tf.freq,t);
    else
        error('Structure does not contain frequency vector!');
    end
end