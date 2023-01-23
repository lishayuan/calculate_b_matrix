%**************************************************************************
%	Script name: main_calc_b_matrix_demo.m
%
%   Brief description: 
%       main function for calculating b-matrix
%
%       input:
%           (line 19) - select the excel file
%           Flag_use_symbolic - select the approach
%           	true: Auto-b based on the divide-and-conquer approach
%               false: Auto-b based on numerical integration
%       output:
%           b_matrix - the calculated b matrix
%
%   Copyright 2023, Lisha Yuan (lishayuan@zju.edu.cn)
%**************************************************************************

clc
clear
close all
%% Part I: Select the excel file and the approach to calculate the b-matrix
tic

[file, filepath] = uigetfile('*.xlsx'); % select the excel file
Flag_use_symbolic = true;   % select the approach to calculate b-matrix

if(Flag_use_symbolic == true)
    % Method 1: (default) Auto-b based on the divide-and-conquer approach 
	b_matrix = sym__calculate_b_matrix([filepath, filesep, file]);
else
    % Method 2:  Auto-b based on numerical integration 
	b_matrix = num__calculate_b_matrix([filepath, filesep, file]);
end

%% Part II: (optional) Save the result
% Step 1: (output folder) filepath/b_matrix
output_filepath = [filepath, filesep, 'b_matrix'];
if exist (output_filepath, 'dir')~= 7 % output folder
    mkdir(output_filepath);
end

% Step 2: (output filename) same as the excel file but with a changed suffix
name = file(1:end-5);
output_file = [output_filepath, filesep, name, '.mat'];

% Step 3: save the result
save(output_file, 'b_matrix')
clear output_filepath name output_file

toc