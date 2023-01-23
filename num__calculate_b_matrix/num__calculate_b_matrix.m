%*************************************************************************
%	Script name: num__calculate_b_matrix.m
%
%   Brief description: 
%       Calculating b-matrix based on numerical integration
%
%   input:
%       filename - the path and name of the excel file
%                   (Excel file) sheet 1: gradient specifications
%                   (Excel file) sheet 2: control variables
%	output:
%       b_matrix - the calculated b matrix
%
%   Copyright 2023, Lisha Yuan (lishayuan@zju.edu.cn)
%*************************************************************************

function b_matrix = num__calculate_b_matrix(filename)
%% Step 2: obtain gradient specifications of three axes from excel
idx_sheet = 1;
baseStruct = struct( 'start_time', 0, 'shape', 'Trapezoid', 'amplitude', 0, 'rampup', 0, 'duration', 0, 'rampdown', 0);
[xGradSpec, yGradSpec, zGradSpec, maxAmplitude] = read_gradSpec_from_excel(filename, idx_sheet, baseStruct);
clear idx_sheet baseStruct

%% Step 3a: extract time points
idx_sheet = 2;
stepSize = 10;
calcParams = read_timePoints_from_excel(filename, idx_sheet);

timePoints = (calcParams.startTime:stepSize:calcParams.endTime)';
timeGroups = [calcParams.startTime calcParams.antiPhase calcParams.endTime];

%% Part 3b: generate gradient series points
% xGradPulse/yGradPulse/zGradPulse: functions of each trapezoid gradient
xGradSeries = num__get_gradientPluse_timeSeries(xGradSpec, timePoints);
yGradSeries = num__get_gradientPluse_timeSeries(yGradSpec, timePoints);
zGradSeries = num__get_gradientPluse_timeSeries(zGradSpec, timePoints);
%clear xGradSpec yGradSpec zGradSpec

GradSeries = [xGradSeries yGradSeries zGradSeries];

%% Step 4: plot gradient series points
num__plot_3D_discreteData(GradSeries, timePoints, maxAmplitude);

%% Step 5: calculate b-matrix numerically
sign_effGradSeries = num__calc_sign_effGradSeries(timePoints, stepSize, timeGroups);

effGradSeries = GradSeries(:,1:3).*sign_effGradSeries(:);
b_matrix = num__calc_bMatrix_numerical(effGradSeries, stepSize);

toc