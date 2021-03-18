%*******************************************************************
%	Copyright 2019-2021 Lisha Yuan
%   File name:
%   Author: Lisha Yuan
%   Brief introduction:
%********************************************************************

function b_matrix = calculate_b_matrix(filename)
% Function statement: the main pipeline to calculate b matrix

%% Part I: get gradTiming from excel (which provide gradient events of three axes)
% X_gradTiming/Y_gradTiming/Z_gradTiming: (timing of each gradient) [Ampl, Rut, Dur, Rdt, StartTime]
% calcParameters: important parameters used to calculate b-matrix for specific sequence
idx_sheets = 1;
baseTimeStruct = struct( 'start_time', 0, 'magnitude', 0, 'rampup', 0, 'duration', 0, 'rampdown', 0, 'shape', 'Trapezoid');
[xGradTiming, yGradTiming, zGradTiming, maxAmplitude] = read_gradTiming_from_excel(filename, idx_sheets, baseTimeStruct);
clear baseTimeStruct idx_sheets

%% Part II: calculate gradPulse from gradTiming (expain each gradient timing as several piecewise functions)
% X_gradPulse/Y_gradPulse/Z_gradPulse: functions of each trapezoid gradient
baseFuncStruct = struct('start_time', 0, 'end_time', 1, 'func', 0);
xGradPulse = get_gradientPluse_Expression(xGradTiming,baseFuncStruct);
yGradPulse = get_gradientPluse_Expression(yGradTiming,baseFuncStruct);
zGradPulse = get_gradientPluse_Expression(zGradTiming,baseFuncStruct);
clear xGradTiming yGradTiming zGradTiming baseFuncStruct

%% Part III: extract important time parameters [calcParameters, time_points]
idx_sheets = 2;
[calcParams, timePoints] = extract_timepoints_from_gradPulse_controlVariable(xGradPulse,yGradPulse,zGradPulse,filename,idx_sheets);

%% Part IV: Divide the gradient time series of three axes into common sections
deriveFuncStruct = struct(      'start_time',   0, ...
                                'end_time',     0,  ...
                                'x_func',       0,  ... 
                                'y_func',       0,  ...
                                'z_func',       0);
combinedGradPulse = combine_gradPulse_into_deriveFuncArray(xGradPulse,yGradPulse,zGradPulse, timePoints, deriveFuncStruct);
clear xGradPulse yGradPulse zGradPulse deriveFuncStruct

% plot and check the timing of combinedGradPulse
% plot_3D_piecewiseFunc(combinedGradPulse, timePoints, maxAmplitude);

%% Part V: Calculate the b-Matrix (double integration)
if (isequal(calcParams.seqType, 'EPI/PGSE/OGSE/TGSE'))         % EPI/OGSE/PGSE/TGSE
    b_matrix = calc_bMatrix_from_combinedGradPulse_for_epi(combinedGradPulse,calcParams.RF180ss);
    disp('dEPI: b matrix has been calculated.');
else
	assert(isequal(calcParams.seqType, 'SPEN'), 'unknown sequence type!'); % only SPEN is supported.
    b_matrix =  calc_bMatrix_from_combinedGradPulse_for_spen(combinedGradPulse,timePoints, calcParams);
end