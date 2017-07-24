foi = [30 50];
toi = [30 80];

[s foistart]     = min(abs(tf.freq - foi(1)));
[s foistop]      = min(abs(tf.freq - foi(2)));
[s toistart]     = min(abs(tf.time - toi(1)));
[s toistop]      = min(abs(tf.time - toi(2)));
fvals            = tf.freq(foistart:foistop);
tvals            = tf.time(toistart:toistop);

[val ind]        = max(max(tf.nepower(foistart:foistop,toistart:toistop),...
                   [],2));
peakf            = fvals(ind);
[row, ind]       = find(tf.nepower(foistart:foistop,toistart:toistop) == val);
peakt            = tvals(ind);