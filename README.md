# Oculomotor-Kinematic
Instruction to some of .m codes is included in the instruction of the pipeline.docx
.m file with anderson string in filename are those created to apply similar methods used by Anderson: pca: principal component analysis, test: nonlinearfit for coefficient A and time constant TC, plotting_anderson: plot figures to quantify the dynamic of ipsi and contral eye movement, stimulation_stat is to plot peak ipsi eye position as the function of sitmulation frequency, duration and current amplitude.
This document aims to explain and instruct the function of the pipeline.

Usually, the original eye movement response collected for either horizontal or vertical from ipsilateral/contralateral consists of artifacts and noise, resulting in a low signal-to-noise ratio. Consequently, a Matlab based pipeline is proposed to remove artifacts and increase the SNR.

The pipeline made here consists of 3 code script (main.m, plotting.m, plotting_contra.m) and 6 function scripts use. Main.m code is responsible for processing original data as the following procedure shows:
•	1. extract segments from each BR file
•	2. use a low pass filter to filter position and velocity calculated by gradient(position). 
•	Cut off frequency is 125Hz with a hamming window function.
•	3. Do a velocity check
•	300 deg/s for both horizontal and vertical velocity at alpha period(pre-pulse)
•	600 deg/s for both during the pulse
•	800 deg/s for omega period(post pulse)
•	4. Do a position check
•	An initial position check for alpha period (45 deg for current setting by comparing the processing effect of different values)
•	Calculate offset value by calculate the mean of 20ms right before the pulse
•	Apply the offset
•	5. Do another low pass filter to filter both
•	Cut off frequency is 75Hz with a hamming window function 
•	Refer to Van Horn MR, Waitzman DM, Cullen KE. Vergence neurons identified in the rostral superior colliculus code smooth eye movements in 3D space. 
•	6. Check if remained trials/BR > 5
The input of the main code is a structure variable named “p” in the following format:

p.prebuffer = 100; %alpha length ms
p.postbuffer = 150; %omega length ms
% p.num_pulse_threshold = 5; %An BR file should have >5 pulses
p.cf1 = 125; %the cutoff frequency for low-pass filter before doing velocity check
p.cf2 = 75; %the cutoff frequency for low-pass filter after processing
p.fs = 1000; %sampling frequency
p.flag = 1; % do filtering on velocity data only
p.prebuffer = 100; %prepulse length ms
p.postbuffer = 150; %postpulse length ms
p.threshs = [45, 300, 600, 800, 300, 300, 800];
% initial position threshold
% horizontal eye velocity threshold for alpha
% horizontal eye velocity threshold for during
% horizontal eye velocity threshold for omega
% vertical eye velocity threshold for alpha
% vertical eye velocity threshold for during
% vertical eye velocity threshold for omega
Threshold = 5; % the min of the filtered response in each BR file

The main code will use prebuffer and postbuffer variable to determine the total timeframe of the event of interest, which is processed by extract_segment.m function that output the total eye movement responses to the stimulation with the eye velocity calculated by gradient function. Hence, the sampling frequency here is 1000Hz, meaning each timeframe is 1s/1000=1ms, thus the velocity actually calculated here is in deg/ms. After segment extraction, the data is processed by low-pass filter (freq_filter.m) consisting of 51st-order finite impulse-response filter with a hamming window. The cutoff frequency is referred to p.cf1. Followed by low-pass filter is a zero-phase digital filter to eliminate the group delay in the output signal of a filter.   

After frequency filter, the data is processed with velocity check. Currently, the velocity threhold set up in parameters is empirically got by visually comparing the filtered response with different parameters. The general idea is that the velocity during omega period should not exceed the saccade velocity (800deg/s), and during the pulse, should not exceed 600 deg/s for ipsilateral and 300deg/s for contralateral, which is inferred from the previous experiments. For velocity threshold for alpha period, a 300deg/s seems work fine with the data processing. One eye movement response can only pass if its eye horizontal/vertical velocity of both ipsilateral and contralateral within the range constrained by the threshold value. Since the sample currently processed defined the negative axis as the expected direction. Besides set up an absolute velocity check, the pipeline also add a positive velocity < 100 deg/s threshold to ensure the passed response should have moved in right direction.

The position check is then applied to the filtered signal. If there is any eye horizontal position during the alpha period exceeding the threshold (currently 45 deg), it will be removed. Next, the offset value is calculated by the mean of eye horizontal position during the 20ms right before the onset of the pulse to make sure all response starts from 0 deg at the start of the pulse.

Once it is done, the pipeline checks if there are enough filtered responses in each processed BR file. The reason for doing this check is that if there are few filtered responses left, it should be a suspect of reliability. Currently, at least 5 filtered responses should be in each passed BR file. Then, the mean response over all responses in one BR file with a 95% t-confidence interval is performed to examine the performance of the pipeline. 

Plotting.m and plotting_contra.m codes plot the ehp/ehv for ipsilateral and contralateral respectively.
