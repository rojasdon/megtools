function z = ztest4corr(r1,r2,n1,n2)
% computes z test between two correlation coefficients
% author: Don Rojas
% Todo: return p value
    z = (0.5*log((1+r1)/(1-r1))) - (0.5*log((1+r2)/(1-r2)));
    z = z/sqrt((1/(n1-3)) + (1/(n2-3)));
end