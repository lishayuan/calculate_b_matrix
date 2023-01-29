%*************************************************************************
%	Script name: sym__calc_bMatrix_symbolic_for_spen.m
%
%   Brief description: 
%       calculate b-matrix of the continus curve for SPEN sequence
%
%   input:
%       combined_grad_pulses - the 3D piecewise function of gradient pulses
%       time_points - time points which defines the intervals
%       calc_parames - control variables used to calculate b-matrix
%   output:
%       b_matrix - the b matrix for all y-positions

% chirp pulse -> different y-position has different excitation time (t90_y)
% During the first section, we assume that,
%       i. the accumulated integral value along y-axis is accumStartFy
%       ii. there is no pulse along the x- or z-axis 
%
%   Copyright 2023, Lisha Yuan (lishayuan@zju.edu.cn)
%*************************************************************************

function b_matrix = sym__calc_bMatrix_symbolic_for_spen(combined_grad_pulses, time_points, calc_params)

syms unknown_T  accumStartFy    % constant_0;
gama = 42.5756*10^6;            % 1/(T*s), excluding 2*pi

%% Part I: a structure to save the integral value of the gradient function at specified point
integral_func_value = struct('time', 0, 'F_x', 0, 'F_y', 0,'F_z', 0, 'F_x_tmp', 0, 'F_y_tmp', 0, 'F_z_tmp',0);
% time_point_1
first_integral_value = integral_func_value;
first_integral_value.time = combined_grad_pulses(1).start_time;
% time_point_2
first_integral_value = cat(1, first_integral_value, integral_func_value);
first_integral_value(end).time = combined_grad_pulses(1).end_time;
first_integral_value(end).F_y = accumStartFy;  %(if necessary) assign an initial value 

antiphase_time = [calc_params.antiPhase combined_grad_pulses(end).end_time + 1000];
num_180RF_pre = 0;
cur_antiphase_time = antiphase_time(num_180RF_pre + 1);

%% Part II: calculate the b-matrix (for the 2nd ~ the end segment)
% (for SPEN-axis, byy is a function of accumStartFy)
tmp_b_matrix = [0 0 0 0 0 0];
for idx = 2 : (size(time_points,1)-1)
    start_time = combined_grad_pulses(idx).start_time;
	end_time = combined_grad_pulses(idx).end_time;

    if (start_time >= cur_antiphase_time)
        num_180RF_pre = num_180RF_pre + 1;
        cur_antiphase_time = antiphase_time(num_180RF_pre + 1);
    end
    sign = (-1).^num_180RF_pre;
    
    x_func = sign*combined_grad_pulses(idx).x_func;
	y_func = sign*combined_grad_pulses(idx).y_func;
	z_func = sign*combined_grad_pulses(idx).z_func;
        
	%% step 1: calculate Fx_func, Fy_func, Fz_func
	Fx_start = first_integral_value(idx).F_x;
	int_x_func = int(x_func, unknown_T);
	Fx_func = Fx_start + int_x_func - subs(int_x_func, unknown_T, start_time);
	Fx_end = double(subs(Fx_func, unknown_T, end_time));
	clear Fx_start x_func int_x_func

	Fy_start = first_integral_value(idx).F_y;
	int_y_func = int(y_func, unknown_T);
	Fy_func = Fy_start + int_y_func - subs(int_y_func, unknown_T, start_time);
	Fy_end = subs(Fy_func, unknown_T, end_time);
	clear Fy_start y_func int_y_func

	Fz_start = first_integral_value(idx).F_z;
	int_z_func = int(z_func, unknown_T);
	Fz_func = Fz_start + int_z_func - subs(int_z_func, unknown_T, start_time);
	Fz_end = double(subs(Fz_func, unknown_T, end_time));
	clear Fz_start z_func int_z_func

	%% step 2: save end_time and the correspinding Fx_end/Fy_end/Fz_end
    first_integral_value = cat(1,first_integral_value, integral_func_value);
	first_integral_value(end).time = end_time; 
	first_integral_value(end).F_x = Fx_end;
	first_integral_value(end).F_y = Fy_end;
	first_integral_value(end).F_z = Fz_end;
	first_integral_value(end).F_y_tmp = double(subs(Fy_end, accumStartFy, 0));
	clear Fx_end Fy_end Fz_end

	%% step 3: calculate the b-Matrix based on Fi_func*Fj_func
	tmp_bxx = (2*pi*gama).^2*int(Fx_func*Fx_func, unknown_T, start_time, end_time).*10^(-30);
	tmp_byy = (2*pi*gama).^2*int(Fy_func*Fy_func, unknown_T, start_time, end_time).*10^(-30);
	tmp_bzz = (2*pi*gama).^2*int(Fz_func*Fz_func, unknown_T, start_time, end_time).*10^(-30);
	tmp_bxy = (2*pi*gama).^2*int(Fx_func*Fy_func, unknown_T, start_time, end_time).*10^(-30);
	tmp_bxz = (2*pi*gama).^2*int(Fx_func*Fz_func, unknown_T, start_time, end_time).*10^(-30);
	tmp_byz = (2*pi*gama).^2*int(Fy_func*Fz_func, unknown_T, start_time, end_time).*10^(-30);
    tmp_b = [tmp_bxx tmp_byy tmp_bzz tmp_bxy tmp_bxz tmp_byz];
	tmp_b_matrix = cat(1, tmp_b_matrix, tmp_b);
	clear Fx_func Fy_func Fz_func start_time end_time
	clear tmp_bxx tmp_byy tmp_bzz tmp_bxy tmp_bxz tmp_byz tmp_b
end
clear idx integral_func_value

%% Part III: calculate the b-matrix including the first segment
Nspen = calc_params.Nspen;
te_y = calc_params.teY;
ta_y = calc_params.taY;
[~, index_refoc] = ismember(ta_y, time_points);

% for the first interval
Fy_start = 0;
y_func = combined_grad_pulses(1).y_func;
int_y_func = int(y_func, unknown_T);
end_time = te_y(end);
clear y_func

b_matrix = zeros(Nspen, 6);
for idx = 1 : Nspen
	start_time = te_y(idx);
	Fy_func = Fy_start + int_y_func - subs(int_y_func, unknown_T, start_time);
	tmp_byy = (2*pi*gama).^2*int(Fy_func*Fy_func, unknown_T, start_time, end_time).*10^(-30);
	tmp_b_matrix(1,:) = [0 tmp_byy 0 0 0 0];
	Fy_end = subs(Fy_func, unknown_T, end_time);
    
    y_tmp_b_matrix = double(subs(tmp_b_matrix, accumStartFy, Fy_end));
    
    % b_matrix(idx,:) = sum(y_tmp_b_matrix, 1); % uniform TA
    index_total = 1:index_refoc(idx)-1;
    b_matrix(idx,:)  = sum(y_tmp_b_matrix(index_total,:), 1);
    clear index_total

	clear start_time Fy_func tmp_byy Fy_end y_tmp_b_matrix
end
clear Fy_start y_func int_y_func end_time tmp_b_matrix calc_params

end