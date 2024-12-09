clear
clc
close all

%% This is the main code for data processing, output processed BR files, removed BR files

Filelist = dir('*uA.mat');
%% parameters for preprocessing
p.prebuffer = 100; %prepulse length ms
p.postbuffer = 150; %postpulse length ms
% p.num_pulse_threshold = 5; %An BR file should have >5 pulses
p.cf1 = 125; %the cutoff frequency for low-pass filter before doing velocity check
p.cf2 = 75; %the cutoff frequency for low-pass filter after processing
p.fs = 1000; %sampling frequency
p.flag = 1; % do filtering on velocity data only
p.prebuffer = 100; %prepulse length ms
p.postbuffer = 150; %postpulse length ms
% p.num_pulse_threshold = 5; %An BR file should have >5 pulses
p.threshs = [45, 300, 600, 800, 300, 300, 800];
% initial position threshold
% horizontal eye velocity threshold for alpha
% horizontal eye velocity threshold for during
% horizontal eye velocity threshold for omega
% vertical eye velocity threshold for alpha
% vertical eye velocity threshold for during
% vertical eye velocity threshold for omega
session_name = "Caesar-session-2";
Processed_Data = cell(size(Filelist, 1), 1);
Removed_Data = cell(size(Filelist, 1), 1);
for i=1:size(Filelist,1)

    description = str2double(regexp(Filelist(i).name, '\d+', 'match'));

    number = description(1);% BR file number
    density = description(2);% # of channels used
    dur = description(3); % stimulation duration in ms
    freq = description(4); % stimulation frequency in Hz 

    current = description(5); % stimulation current in uA
    fprintf('Current File is %s \n', Filelist(i).name) % for debug purpose

    [removed, output] = pipeline(Filelist(i).name, p, session_name); 
    
    if ~isempty(output.list) %see if there are remained BR file after processing
        output.freq = freq;
        output.dur = dur;
        output.density = density;
        output.current = current;
        output.number = number;
        if freq == 0
            output.flag = 0; % 0 for non-current steering
        else
            output.flag = 1; % 1 for current steering
        end  
        Processed_Data{i} = output;
    else
        Processed_Data{i} = []; % if there is no remained, assgin null value
    end
    if ~isempty(removed.list) % removed BR file after processing for parameter improvement
        removed.freq = freq;
        removed.dur = dur;
        removed.density = density;
        removed.current = current;
        removed.number = number;
        if freq == 0
            removed.flag = 0; % 0 for non-current steering
        else
            removed.flag = 1; % 1 for current steering
        end  
        Removed_Data{i} = removed;
    else
        Removed_Data{i} = []; % if there is no removed, assgin null value
    end
end

%% remove any processed BR file with null value in processed_data struct and removed_data struct
Processed_Data1 = Processed_Data(~cellfun('isempty', Processed_Data));
save("processed_data.mat", "Processed_Data1")
Removed_Data1 = Removed_Data(~cellfun('isempty', Removed_Data));
save("removed_data.mat", "Removed_Data1")

%% post process the data (mean and confidence interval)
Refined_Data = post_process(Processed_Data1);
Refined_Data1 = Refined_Data(~cellfun('isempty', Refined_Data));
save("refined_data.mat", "Refined_Data1")
%% For each processed BR file, at least 5 trials should be left, otherwaise, remove them.
Threshold = 5;
Refined_Data2 = Refined_Data1;
for i = 1:length(Refined_Data1)
    if size(Refined_Data1{i}.ehp_left,1)<Threshold
        Refined_Data2{i} = []
    else
        Refined_Data2{i} = Refined_Data1{i}
    end
end
Refined_Data2 = Refined_Data2(~cellfun('isempty', Refined_Data2));
save("Refined_Data2")
%% helper method to get the indices of the data with field value
function [output, indices] = extract_on_field(A, fieldName, value)
    indices = find(cellfun(@(s) isfield(s, fieldName) && isequal(s.(fieldName), value), A));
    if ~isempty(indices)
        output = A{indices};
    else
        output = [];
    end
end



