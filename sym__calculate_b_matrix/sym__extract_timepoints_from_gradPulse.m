%*************************************************************************
%	Script name: sym__extract_timepoints_from_gradPulse.m
%
%   Brief description: 
%       extract all start_time and end_time instants from gradient pulses 
%       of three axes.
%
%   input:
%       x_grad_pulses - the piecewise function of gradients in x-axis
%       y_grad_pulses - the piecewise function of gradients in y-axis
%       z_grad_pulses - the piecewise function of gradients in z-axis
%   output:
%       time_points: time points extracted from gradient pulses
%
%   Copyright 2023, Lisha Yuan (lishayuan@zju.edu.cn)
%*************************************************************************

function time_points = sym__extract_timepoints_from_gradPulse (x_grad_pulses, y_grad_pulses, z_grad_pulses)
%% Part I: time points from the piecewise function of gradients in each axis
tmp_struct = [x_grad_pulses; y_grad_pulses; z_grad_pulses];
tmp_cell = struct2cell(tmp_struct)';
tmp_time_points = [cell2mat(tmp_cell(:,1)); cell2mat(tmp_cell(:,2))];
time_points = sort(unique(tmp_time_points));
clear x_grad_pulses y_grad_pulses z_grad_pulses
clear tmp_struct tmp_cell tmp_time_points

end

