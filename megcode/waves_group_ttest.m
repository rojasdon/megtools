function [tvals pvals, x1, x2] = waves_group_ttest()
% PURPOSE:  to calculate the t test and p value associated with it between
%           two groups of waveform data, on a time-point by time-point
%           basis.  Output is a vector of pvals and tvals equal in length 
%           to the number of time bins compared.  Mean waveforms for group
%           1 and 2 are also output for plotting purposes

G1      = spm_select([1,Inf],'mat','Select files for group 1');
G2      = spm_select([1,Inf],'mat','Select files for group 2');
tails   = spm_input('Tails?',1,'b','1-tailed|2-tailed',[1 2], 2);
dep     = spm_input('Type?',1,'b','Independent|Dependent',[0 1], 0);
n1      = size(G1,1);
n2      = size(G2,1);

if n1 ~= n2
    type = 2;
    if dep
        error('To conduct dependent t-tests, n1 and n2 must be equal!');
    end
else
    if dep
        type = 3;
    else
        type = 1;
    end
end

% load the mat-files with waveform data
field  = spm_input('Fieldname of waveform in mat?',1,'s');
tmp     = load(G1(1,:));
wave    = getfield(tmp, field);
len     = size(wave,2);
D1      = zeros(n1,len);
D2      = zeros(n2,len);

for i=1:n1
    tmp     = load(G1(i,:));
    wave    = getfield(tmp, field);
    D1(i,:) = wave;
end

for i=1:n2
    tmp     = load(G2(i,:));
    wave    = getfield(tmp, field);
    D2(i,:) = wave;
end

x1 = mean(D1,1);
x2 = mean(D2,1);

tvals = zeros(1,len);
pvals = ones(1,len);

% iterate t-test through waveform
for i=1:len
    [tvals(i) pvals(i)] = t_test(D1(:,i),D2(:,i),type,tails);
end

end