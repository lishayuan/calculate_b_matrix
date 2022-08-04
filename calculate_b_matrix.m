function b_matrix = calculate_b_matrix(filename)
% Function statement: the main pipeline to calculate b matrix

%% Part I: obtain gradient timing from excel (including gradient events of three axes)
% xGradTiming/yGradTiming/zGradTiming: (timing of each gradient) [start_time, magnitude, rampup, duration, rampdown, shape]

idx_sheets = 1;
baseTimeStruct = struct( 'start_time', 0, 'magnitude', 0, 'rampup', 0, 'duration', 0, 'rampdown', 0, 'shape', 'Trapezoid');
[xGradTiming, yGradTiming, zGradTiming, maxAmplitude] = read_gradTiming_from_excel(filename, idx_sheets, baseTimeStruct);
clear baseTimeStruct idx_sheets

%% Part II: form the piecewise function of each axis (expain each gradient timing as several functions)
% xGradPulse/yGradPulse/zGradPulse: functions of each trapezoid gradient
baseFuncStruct = struct('start_time', 0, 'end_time', 1, 'func', 0);
xGradPulse = get_gradientPluse_Expression(xGradTiming,baseFuncStruct);
yGradPulse = get_gradientPluse_Expression(yGradTiming,baseFuncStruct);
zGradPulse = get_gradientPluse_Expression(zGradTiming,baseFuncStruct);
clear xGradTiming yGradTiming zGradTiming baseFuncStruct

%% Part IIIa: time points selection [calcParameters, time_points]
% calcParameters: control variables (for specific sequence)

idx_sheets = 2;
[calcParams, timePoints] = extract_timepoints_from_gradPulse_controlVariable(xGradPulse,yGradPulse,zGradPulse,filename,idx_sheets);

%% Part IIIb: construct a 3D piecewise function
deriveFuncStruct = struct(      'start_time',   0, ...
                                'end_time',     0,  ...
                                'x_func',       0,  ... 
                                'y_func',       0,  ...
                                'z_func',       0);
combinedGradPulse = combine_gradPulse_into_deriveFuncArray(xGradPulse,yGradPulse,zGradPulse, timePoints, deriveFuncStruct);
clear xGradPulse yGradPulse zGradPulse deriveFuncStruct

%% Part IV: plot the diagram of sequence timing
% plot_3D_piecewiseFunc(combinedGradPulse, timePoints, maxAmplitude);

%% Part V: Calculate the b-matrix automatically
if (isequal(calcParams.seqType, 'EPI/PGSE/OGSE/TGSE'))         % EPI/OGSE/PGSE/TGSE
    b_matrix = calc_bMatrix_from_combinedGradPulse_for_epi(combinedGradPulse,calcParams.RF180ss);
    disp('dEPI: b matrix has been calculated.');
else
	assert(isequal(calcParams.seqType, 'SPEN'), 'unknown sequence type!'); % only SPEN is supported.

    switch calcParams.flag_UniformTA
        case 0 % 'accurate'
            b_matrix =  calc_bMatrix_from_combinedGradPulse_for_spen(combinedGradPulse,timePoints, calcParams);
        case 1 % 'approximate: uniform TA'
            b_matrix =  calc_bMatrix_from_combinedGradPulse_for_spen_uniformTA(combinedGradPulse,timePoints, calcParams);
        otherwise
            error('For SPEN sequence: the flag definition cannot be recognized!');
    end

end