function [removed, remained] = pipeline(file_dir, params, session_name)
sample = load(file_dir);
[~, file_name, ~] = fileparts(file_dir);
description = str2double(regexp(file_name, '\d+', 'match'));

number = description(1);
density = description(2);
dur = description(3); % stimulation duration in ms
freq = description(4); % stimulation frequency in Hz 
current = description(5); % stimulation current in uA

%% extract trials from original data 
[D0,timeframe] = extract_segments(sample, params);

%% freq filter first and then do artifact removal
params.cf = params.cf1;
D1 = freq_filter(D0, params);
[D1_removed, D1_remained] = velocity_filter(D1, params);
if isempty(D1_remained.ehp_left) ~= 1 %see if there is filtered response remained after velocity filter, continue to process as the pipeline design states
    [D2_removed, D2_remained] = position_filter(D1_remained, params);
    params.flag = 1;
    params.cf = params.cf2
    D3_remained = freq_filter(D2_remained, params);
    D3_removed = freq_filter(D2_removed, params);
else % if there is no filtered response left after velocity filter, assign null value to the remained struct
    D3_remained = [];
    D3_remained.list = D1_remained.list;
    D3_removed = [];
    D3_removed.list = D1_removed.list;
end
%% return parameters
removed = D3_removed;
removed.timeframe = timeframe;
remained= D3_remained;
remained.timeframe = timeframe;
end
