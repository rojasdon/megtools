% script to clean up bug triggers in 4D system - output remains 4D format

% file to process
file = 'c,rfhp0.1Hz';

% read 4D file
cnt = get4D(file); % get4D will clean the trigger line

% make a copy of 4D file with corrected trigger line
put4D(file,[file ',clean'],cnt);