function [grand_av,theta_lo,theta_hi] = boot_ci_z_alpha(daten,z_alpha)

% -----------------------------------------------------------------------
% [grand_av,theta_lo,theta_hi] = boot_ci_z_alpha(daten,z_alpha)
% 
% This function calculates bootstrap BCa confidence intervals
% Input: 'daten': data matrix (Dimension: #subjects x #TimePoints).
%        'z_alpha' corresponds to the confidence limit alpha: 
%               Phi(z_alpha)=1-alpha, where Phi is the cumulative normal 
%               distribution. (i. e. z_alpha = 1.645 for the 90%, 
%               1.960 for the 95% confidence interval)
% outpout: 
%        'grand_av': Average waveform
%        'theta_lo, theta_hi': lower and upper confidence lmit
% --------------------------------------------------------------------- 

anz_samples = 1000;                                                      % desired number of bootstrap samples (at least 1000 recommended)

anz_prob = size(daten,1);
Npts = size(daten,2);

% Perform Bootstrapping and show waitbar
boot_data=zeros(anz_samples,anz_prob,Npts);
h=waitbar_db(0,'Performing bootstrapping procedure...');
for i = 1:anz_samples
    waitbar_db(i/(anz_samples+Npts),h);
    for j = 1:anz_prob
        proband = ceil(rand(1)*anz_prob);
        boot_data(i,j,:) = daten(proband,:);
    end
end

% take average of the data
grand_av = squeeze(mean(daten,1));

% take averages of bootstrapped data and sort them in ascending order
mittel_sort = sort(squeeze(mean(boot_data,2)));	
waitbar_db(anz_samples/(anz_samples+Npts),h,'Calculating confidence interval...');

% Determine confidence interval
for t=1:Npts
    if max(daten(:,t))==min(daten(:,t))
        theta_lo(t)=max(daten(:,t));
        theta_hi(t)=theta_lo(t);
    else
        waitbar_db((anz_samples+t)/(anz_samples+Npts),h);
        
        % Determine the index used for calculating z0 (see page 186 Efron)
        difference = sign(mittel_sort(:,t)-grand_av(t));
        index = ceil((length(difference)-sum(difference))/2);
        
        % calculate z_0
        z_0=sqrt(2)*erfinv(2*(index/(anz_samples))-1);                       % Inverse of the integral over the Gaussian distribution: y=sqrt(2)*erfinv(2*x-1);
        
        % Calculate acceleration acc for every time point and for all components 
        l_j = daten(:,t)-mean(daten(:,t));                                   % Davison Example p. 47
        acc = sum((l_j).^3)/6/(sum((l_j).^2).^1.5);                          % Davison p. 209
        
        % calculate z_alpha_1 and z_alpha_2
        alpha1 = 0.5+0.5*erf((z_0+(z_0-z_alpha)/(1-acc*(z_0-z_alpha)))/sqrt(2)); % Integral über die Gaussverteilung: y=0.5+0.5*erf(x/sqrt(2));
        alpha2 = 0.5+0.5*erf((z_0+(z_0+z_alpha)/(1-acc*(z_0+z_alpha)))/sqrt(2));  
        
        % determine upper and lower limit of confidence interval
        theta_lo(t) = mittel_sort(ceil(alpha1*anz_samples),t);
        theta_hi(t) = mittel_sort(ceil(alpha2*anz_samples),t);
    end
end

% close waitbar
close(h);