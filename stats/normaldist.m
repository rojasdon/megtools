function p = normaldist(z)
% function returns 1 - cumulative probability for a normal distribution given 
% input of z value. p is one tailed.
% author: Don Rojas

% defaults: todo changeable inputs to function
mu = 0;
sigma = 1;
u = mu-3.5*sigma:0.001:mu+3.5*sigma ;

% distribution
d = (1/(sqrt(2*pi)*sigma))*exp(1).^(-((u-mu).^2)./(2*sigma^2));
maxd = max(d);
d = d/maxd;

% return 1-tail prob
if sign(z) == 1
    p = sum(d(u > z)) * 0.001 * maxd;
else
    p = sum(d(u < z)) * 0.001 * maxd;
end