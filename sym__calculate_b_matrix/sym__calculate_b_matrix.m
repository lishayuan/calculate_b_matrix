%*************************************************************************
%	Script name: sym__calculate_b_matrix.m
%
%   Brief description: 
%       Calculating b-matrix based on the divide-and-conquer approach
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

function b_matrix = sym__calculate_b_matrix(filename)
%% Step 2a: obtain gradient specifications of three axes from excel
idx_sheet = 1;
baseStruct = struct( 'start_time', 0, 'shape', 'Trapezoid', 'amplitude', 0, 'rampup', 0, 'duration', 0, 'rampdown', 0);
[xGradSpec, yGradSpec, zGradSpec, maxAmplitude] = parse_gradSpec_of_excel(filename, idx_sheet, baseStruct);
clear idx_sheet baseStruct

%% Step 2b: form a piecewise function of the original gradients for each axis
FuncStruct = struct('start_time', 0, 'end_time', 1, 'func', 0);
xGradPulse = sym__get_gradientPluse_Expression(xGradSpec, FuncStruct);
yGradPulse = sym__get_gradientPluse_Expression(yGradSpec, FuncStruct);
zGradPulse = sym__get_gradientPluse_Expression(zGradSpec, FuncStruct);
clear xGradSpec yGradSpec zGradSpec FuncStruct

%% Step 3a: time points from control variables and segmenting gradient pulses
%   calcParams: control variables used to calculate b-matrix
%   timePoints_1: [calc_params.startTime calc_params.antiPhase calc_params.endTime]';
idx_sheet = 2;
[calcParams, timePoints_1] = read_controlVariable_timePoints_from_excel(filename, idx_sheet);

%   timePoints_2: segmenting the whole period based on the gradient shape
timePoints_2 = sym__extract_timepoints_from_gradPulse(xGradPulse, yGradPulse, zGradPulse);

% iii. the final "timePoints"
timePoints_tot = [timePoints_1; timePoints_2];
timePoints_tot = sort(unique(timePoints_tot));
index = (timePoints_tot >= calcParams.startTime) & (timePoints_tot <= calcParams.endTime);
timePoints = timePoints_tot(index);
clear idx_sheet timePoints_1 timePoints_2 timePoints_tot index

%% Step 3b: construct the 3D piecewise function of the original gradients
deriveStruct = struct(          'start_time',   0, ...
                                'end_time',     0,  ...
                                'x_func',       0,  ... 
                                'y_func',       0,  ...
                                'z_func',       0);
combinedGradPulse = sym__combine_gradPulse_into_3D(xGradPulse, yGradPulse, zGradPulse, timePoints, deriveStruct);
clear xGradPulse yGradPulse zGradPulse deriveStruct

%% Step 4: plot the sequence diagram
sym__plot_3D_piecewiseFunc(combinedGradPulse, timePoints, maxAmplitude);

%% Step 5: Calculate the b-matrix symbolically
if (isequal(calcParams.seqType, 'GE/SE/EPI/RARE'))
    % support sequence types without /with single /with multiple 180degree pulse
    b_matrix = sym__calc_bMatrix_symbolic(combinedGradPulse, calcParams.antiPhase);
elseif (isequal(calcParams.seqType, 'SPEN'))
    %% Method 1: speed optimization
    b_matrix =  sym__calc_bMatrix_symbolic_for_spen(combinedGradPulse, timePoints, calcParams);
    
%     %% Method 2: calculate b-matrix Nspen times (for each position) -- too slowly
%     Nspen = calcParams.Nspen;
%     te_y = calcParams.teY;
%     ta_y = calcParams.taY;
%     [~, index_refoc] = ismember(ta_y, timePoints);
%     
%     b_matrix = zeros(Nspen, 6);
%     for idx = 1 : Nspen
%         % For a given position, sign its start_time and end_time
%         index_total = 1:index_refoc(idx)-1;
%         combinedGradPulse_y = combinedGradPulse(index_total);
%         combinedGradPulse_y(1).start_time = te_y(idx);
%         
%         b_matrix(idx,:) = sym__calc_bMatrix_symbolic(combinedGradPulse_y, calcParams.antiPhase);
%     end
else
    error('unknow sequence type!');
end
