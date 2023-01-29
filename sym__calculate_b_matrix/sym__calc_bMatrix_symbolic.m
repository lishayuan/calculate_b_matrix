%*************************************************************************
%	Script name: sym__calc_bMatrix_symbolic.m
%
%   Brief description: 
%       calculate b-matrix of the continus curve (based on symbolic integral)
%
%   input:
%       combined_grad_pulses - the 3D piecewise function of gradient pulses
%       antiphase_time - the center of the 180° refocusing pulses
%   output:
%       b_matrix - includes six b elements [bxx byy bzz bxy bxz byz]
%
%   Copyright 2023, Lisha Yuan (lishayuan@zju.edu.cn)
%*************************************************************************

function b_matrix = sym__calc_bMatrix_symbolic(combined_grad_pulses, antiphase_time)

syms unknown_T          % constant_0;
gama = 42.5756*10^6;    % 1/(T*s), excluding 2*pi

%% Part I: a structure to save the integral value of the gradient function at specified point
integral_func_value = struct('time', 0, 'F_x', 0, 'F_y', 0, 'F_z', 0);
first_integral_value = integral_func_value;
first_integral_value.time = combined_grad_pulses(1).start_time;
% integral_func_value.F_z = 23.96*480;  %(if necessary, like OGSE) assign an initial value 

antiphase_time = [antiphase_time combined_grad_pulses(end).end_time + 1000];
num_180RF_pre = 0;
cur_antiphase_time = antiphase_time(num_180RF_pre + 1);
tmp_b_matrix = zeros(size(combined_grad_pulses, 1), 6);

%% Part II: calculate the b-matrix
for idx = 1 : size(combined_grad_pulses, 1)
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

    assert(first_integral_value(idx).time == start_time);
    
    %% step 1: calculate Fx_func, Fy_func, Fz_func
    Fx_start = first_integral_value(idx).F_x;
    int_x_func = int(x_func, unknown_T);
    Fx_func = Fx_start + int_x_func - subs(int_x_func, unknown_T, start_time);
    Fx_end = double(subs(Fx_func, unknown_T, end_time));
    clear Fx_start x_func int_x_func

    Fy_start = first_integral_value(idx).F_y;
    int_y_func = int(y_func, unknown_T);
    Fy_func = Fy_start + int_y_func - subs(int_y_func, unknown_T, start_time);
    Fy_end = double(subs(Fy_func, unknown_T, end_time));
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
    clear Fx_end Fy_end Fz_end
    
    %% step 3: calculate the b-matrix based on Fi*Fj
	tmp_bxx = (2*pi*gama).^2*int(Fx_func*Fx_func, unknown_T, start_time, end_time).*10^(-30);
    tmp_byy = (2*pi*gama).^2*int(Fy_func*Fy_func, unknown_T, start_time, end_time).*10^(-30);
	tmp_bzz = (2*pi*gama).^2*int(Fz_func*Fz_func, unknown_T, start_time, end_time).*10^(-30);
	tmp_bxy = (2*pi*gama).^2*int(Fx_func*Fy_func, unknown_T, start_time, end_time).*10^(-30);
	tmp_bxz = (2*pi*gama).^2*int(Fx_func*Fz_func, unknown_T, start_time, end_time).*10^(-30);
	tmp_byz = (2*pi*gama).^2*int(Fy_func*Fz_func, unknown_T, start_time, end_time).*10^(-30);
    tmp_b_matrix(idx,:) = [tmp_bxx tmp_byy tmp_bzz tmp_bxy tmp_bxz tmp_byz];
	clear Fx_func Fy_func Fz_func start_time end_time
    clear tmp_bxx tmp_byy tmp_bzz tmp_bxy tmp_bxz tmp_byz
end
clear integral_func_value
b_matrix = sum(tmp_b_matrix,1);
clear tmp_b_matrix

end