clc
clear
close all

tic
%% Step 1: Define the folder & names for the GradientsTiming excel-files
[filepath, filename, name] = get_filename_batch([pwd, filesep, '*.xlsx']);
mkdir([filepath, filesep, 'b_matrix']); % make new folder to save the calculated b-matrix

Num_files = length(filename);
%% Step 2: b matrix calculation for single/multiple excel files
for n = 1:Num_files
    b_matrix = calculate_b_matrix(filename{n});

    name_b_matrix = [name{n} '.mat'];
    save([filepath, filesep, 'b_matrix', filesep, name_b_matrix],'b_matrix')
    fprintf('The %03d / %03d file: b matrix has been calculated.\n', n, Num_files); 
end

toc