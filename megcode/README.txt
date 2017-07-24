MEGtools function names and descriptions

USAGE - see megtools_examples.m file, or type help [SPACE] function_name in command window

Alphabetical function listing:

averager.m - 		averages an epoched MEG structure

concatMEG.m -		concatenates 2 or more MEG structures

create_events.m -   makes an EEGLAB formatted event structure

deleter.m -			deletes channels from MEG data structure

eeglab2meg.m -		converts eeglab data to MEG struct

plot_hs_sens.m -	displays headshape, fiducials and sensors from MEG structure

deepoch.m -         deconstruct epochs from epoched dataset
			
epocher.m -			epochs a MEG structure returned via get4D.m

event2epoch -		converts an event structure to an epoch structure

filterer.m -		filters a MEG structure

get4D.m -			reads native 4D file format using pdf4D object from Eugene Kronberg. Returns a structure
					containing information about the data as well as the data.

meg_plot2d.m -		contour map of MEG sensor data flattened to 2d projection

meg_plot2d_misc.m - flat topography of any arbitrary dataset to coil locations - similar to meg_plot2d.m

meg_plot3d.m -		same as meg_plot2d except 3-dimensional and prettier

meg_ssp_noise.m	- 	use ssp based methods such as svd and ica to rid oneself of noise

meg2eeglab.m - 		convert MEG structure to EEGLAB EEG structure and save files

meg2ft.m - 		    convert MEG structure to Fieldtrip

meg2spm.m - 		convert MEG structure to SPM8 D structure and save files

offset.m -			DC offset correction for MEG structure

process_auxiliary.m Use a channel other than trig or resp to create triggers (e.g., EMG)

put4D.m - 			Opposite of get4D.m

qtft.m - 			like tft.m, but for ssp.m output

reepoch.m -         re-epoch a de-epoched dataset

resample_meg.m - 	resamples an MEG structure to another sampling rate

ssp.m -				source space projection from dipole

subtractor.m - 		subtract 1 waveform from another

tft.m - 			time-frequency transform of channel level data from MEG structure

triangulate_meg.m - create triangles out of npoint x 3 array (e.g., coil locations)

thetaphi.m -		projects 3d points into 2d map (used by flatmap, meg_plot2d, etc.)

xrms.m -			computes root mean square data from input MEG structure
		  
		