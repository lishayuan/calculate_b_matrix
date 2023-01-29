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
[xGradSpec, yGradSpec, zGradSpec, maxAmplitude] = parse_gradSpec_of_excel(filename, idx_sheet, baseStruct);
clear idx_sheet baseStruct

%% Step 3a: extract sampling time points and group time (determined by antiphase instants)
idx_sheet = 2;
stepSize = 10;
%   calcParams: control variables used to calculate b-matrix
[calcParams, ~] = read_controlVariable_timePoints_from_excel(filename, idx_sheet);

start_time = round(calcParams.startTime/stepSize)*stepSize;
antiphase_time = round(calcParams.antiPhase./stepSize).*stepSize;
end_time = round(calcParams.endTime/stepSize)*stepSize;
timePoints = (start_time : stepSize : end_time)';   % sampling time points
timeGroups = [start_time antiphase_time end_time];  % dividing discrete data into groups 
clear idx_sheet start_time antiphase_time end_time

%% Part 3b: Convert the gradient specifications to 3D discrete data
xGradSeries = num__get_gradientPluse_timeSeries(xGradSpec, timePoints);
yGradSeries = num__get_gradientPluse_timeSeries(yGradSpec, timePoints);
zGradSeries = num__get_gradientPluse_timeSeries(zGradSpec, timePoints);
clear xGradSpec yGradSpec zGradSpec

GradSeries = [xGradSeries yGradSeries zGradSeries]; % 3D discrete data

%% Step 4: plot the sequence diagram
num__plot_3D_discreteData(GradSeries, timePoints, maxAmplitude);

%% Step 5: calculate b-matrix numerically
%   sign_effGradSeries: the sign of effective gradients
%   effGradSeries: the discrete data of effective gradients
sign_effGradSeries = num__calc_sign_effGradSeries(timePoints, stepSize, timeGroups);
effGradSeries = GradSeries(:,1:3).*sign_effGradSeries(:);

if (isequal(calcParams.seqType, 'GE/SE/EPI/RARE'))
	b_matrix = num__calc_bMatrix_numerical(effGradSeries, stepSize);
elseif (isequal(calcParams.seqType, 'SPEN'))
    % assign a unique excitation and refocusing instant to each position
	Nspen = calcParams.Nspen;
    te_y = round(calcParams.teY./stepSize).*stepSize;
    ta_y = round(calcParams.taY./stepSize).*stepSize;
	[~, index_excite] = ismember(te_y, timePoints);
 	[~, index_refoc] = ismember(ta_y, timePoints);
	
	b_matrix = zeros(Nspen, 6);
	for idx = 1 : Nspen
		index_range = index_excite(idx):index_refoc(idx);
        % calculate the b-matrix for each position
		b_matrix(idx, :) = num__calc_bMatrix_numerical(effGradSeries(index_range,:), stepSize);
	end
end