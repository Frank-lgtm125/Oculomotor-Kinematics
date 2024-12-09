function output = freq_filter(data, params)
     
    ehp_left_3d = data.ehp_left;
    ehp_right_3d = data.ehp_right;
    evp_left_3d = data.evp_left;
    evp_right_3d = data.evp_right;
    
    ehp_left_3d_filtered = cell(size(ehp_left_3d,1),1);
    ehp_right_3d_filtered = cell(size(ehp_left_3d,1),1);
    evp_left_3d_filtered = cell(size(ehp_left_3d,1),1);
    evp_right_3d_filtered = cell(size(ehp_left_3d,1),1);


    for i = 1:size(ehp_left_3d, 1)
        ehp_left_3d_filtered{i} = lowpass(ehp_left_3d{i}, params);
        ehp_right_3d_filtered{i} = lowpass(ehp_right_3d{i}, params);
        evp_left_3d_filtered{i} = lowpass(evp_left_3d{i}, params);
        evp_right_3d_filtered{i} = lowpass(evp_right_3d{i}, params);
    end
  
    ehv_left_3d = cell(size(ehp_left_3d,1),1);
    ehv_right_3d = cell(size(ehp_left_3d,1),1);
    evv_left_3d = cell(size(ehp_left_3d,1),1);
    evv_right_3d = cell(size(ehp_left_3d,1),1);

    for i = 1:size(evp_right_3d,1)
        ehv_left_3d{i} = lowpass(gradient(ehp_left_3d{i}), params);
        ehv_right_3d{i} = lowpass(gradient(ehp_right_3d{i}), params);
        evv_left_3d{i} = lowpass(gradient(evp_left_3d{i}), params);
        evv_right_3d{i} = lowpass(gradient(evp_right_3d{i}), params);
    end

    output.ehp_left = ehp_left_3d_filtered;
    output.ehp_right = ehp_right_3d_filtered;
    output.evp_left = evp_left_3d_filtered;
    output.evp_right = evp_right_3d_filtered;

    output.ehv_left = ehv_left_3d;
    output.ehv_right = ehv_right_3d;
    output.evv_left = evv_left_3d;
    output.evv_right = evv_right_3d;
    if isfield(data, 'list')
        output.list = data.list;
    end
end


function filtered_signal = lowpass(signal, params)
%% lowpass filter parameters
cutoff = params.cf;
fs = params.fs; % 1000 Hz sampling frequency
%% filter 
filtered_signal = signal;

%51st order finite impulse-response filter with a Hamming window and a cutoff at 125Hz)
filter_order = 51;     % 51st-order FIR filter

%Normalize the cutoff frequency (cutoff frequency / Nyquist frequency)
wn = cutoff / (fs / 2);  % Nyquist frequency is fs/2

%Design the 51st-order FIR filter with a Hamming window
fir_coeffs = fir1(filter_order, wn, 'low', hamming(filter_order + 1));



% Apply the filter to signal with zero-phase digital filter
filtered_signal = filtfilt(fir_coeffs, 1, filtered_signal);

end