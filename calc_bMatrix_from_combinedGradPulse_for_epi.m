%*******************************************************************
%	Copyright 2019-2020
%   Author: Lisha Yuan (lishayuan@zju.edu.cn)
    %   Function statement: calculate b matrix for SE/SE-EPI sequence
    %   input:
    %           combined_gradPulse - the 3D piecewise function (combing xGradPulse,yGradPulse and zGradPulse)
    %           calc_parames - important parameters used to calculate b-matrix
    % 
    %   output:
    %       b_matrix - includes six b elements [bxx byy bzz bxy bxz byz]
    
%********************************************************************
function b_matrix = calc_bMatrix_from_combinedGradPulse_for_epi(combined_gradPulse,half_echoTime)

syms unknown_T          % constant_0;
gama = 42.5756*10^6;    % 1/(T*s), excluding 2*pi

%% Part I: a structure to save the integral value of the gradient function at specified point
integral_func_value = struct('time', 0, 'F_x', 0, 'F_y', 0,'F_z', 0, 'F_x_tmp', 0, 'F_y_tmp', 0, 'F_z_tmp',0);
first_integral_value = integral_func_value;
first_integral_value.time = combined_gradPulse(1).start_time;
% integral_func_value.F_z = 23.96*480;  %(if necessary, like OGSE) assign an initial value 
% integral_func_value.F_z_tmp = 23.96*480;

lambda = 0;
Fx_half_echoTime = 0;
Fy_half_echoTime = 0;
Fz_half_echoTime = 0;

tmp_b_matrix = zeros(size(combined_gradPulse,1),6);

%% Part II: calculate the b-matrix
for idx = 1 : size(combined_gradPulse,1)
    start_time = combined_gradPulse(idx).start_time;
    end_time = combined_gradPulse(idx).end_time;
    
    if (start_time == half_echoTime)
        lambda = 1;   % label "lambda" at appropriate time
    end
    assert(first_integral_value(idx).time == start_time);
    
    %% step 1: calculate Fx_func, Fy_func, Fz_func
    Fx_start = first_integral_value(idx).F_x;
    x_func = combined_gradPulse(idx).x_func;
    int_x_func = int(x_func, unknown_T);
    Fx_func = Fx_start + int_x_func - subs(int_x_func, unknown_T, start_time);
    Fx_end = double(subs(Fx_func, unknown_T, end_time));
    clear Fx_start x_func int_x_func

    Fy_start = first_integral_value(idx).F_y;
    y_func = combined_gradPulse(idx).y_func;
    int_y_func = int(y_func, unknown_T);
    Fy_func = Fy_start + int_y_func - subs(int_y_func, unknown_T, start_time);
    Fy_end = double(subs(Fy_func, unknown_T, end_time));
    clear Fy_start y_func int_y_func
    
    Fz_start = first_integral_value(idx).F_z;
    z_func = combined_gradPulse(idx).z_func;
    int_z_func = int(z_func, unknown_T);
    Fz_func = Fz_start + int_z_func - subs(int_z_func, unknown_T, start_time);
    Fz_end = double(subs(Fz_func, unknown_T, end_time));
    clear Fz_start z_func int_z_func
    
    %% step 2a: label Fx(/Fy/Fz)_half_echoTime (at appropriate segment)
    if (end_time == half_echoTime)
        Fx_half_echoTime = Fx_end;
        Fy_half_echoTime = Fy_end;
        Fz_half_echoTime = Fz_end;
    end
    %% step 2b: save end_time and the correspinding Fx_end/Fy_end/Fz_end
    first_integral_value = cat(1,first_integral_value, integral_func_value);
    first_integral_value(end).time = end_time;
    first_integral_value(end).F_x = Fx_end;
    first_integral_value(end).F_y = Fy_end;
    first_integral_value(end).F_z = Fz_end;
    first_integral_value(end).F_x_tmp = Fx_end-2*lambda*Fx_half_echoTime;
    first_integral_value(end).F_y_tmp = Fy_end-2*lambda*Fy_half_echoTime;
    first_integral_value(end).F_z_tmp = Fz_end-2*lambda*Fz_half_echoTime;
    clear Fx_end Fy_end Fz_end
    
    %% step 3: calculate the b-matrix based on Fi*Fj
	tmp_bxx = (2*pi*gama).^2*int((Fx_func-2*lambda*Fx_half_echoTime)*(Fx_func-2*lambda*Fx_half_echoTime), unknown_T, start_time, end_time).*10^(-30);
    tmp_byy = (2*pi*gama).^2*int((Fy_func-2*lambda*Fy_half_echoTime)*(Fy_func-2*lambda*Fy_half_echoTime), unknown_T, start_time, end_time).*10^(-30);
	tmp_bzz = (2*pi*gama).^2*int((Fz_func-2*lambda*Fz_half_echoTime)*(Fz_func-2*lambda*Fz_half_echoTime), unknown_T, start_time, end_time).*10^(-30);
	tmp_bxy = (2*pi*gama).^2*int((Fx_func-2*lambda*Fx_half_echoTime)*(Fy_func-2*lambda*Fy_half_echoTime), unknown_T, start_time, end_time).*10^(-30);
	tmp_bxz = (2*pi*gama).^2*int((Fx_func-2*lambda*Fx_half_echoTime)*(Fz_func-2*lambda*Fz_half_echoTime), unknown_T, start_time, end_time).*10^(-30);
	tmp_byz = (2*pi*gama).^2*int((Fy_func-2*lambda*Fy_half_echoTime)*(Fz_func-2*lambda*Fz_half_echoTime), unknown_T, start_time, end_time).*10^(-30);
    tmp_b_matrix(idx,:) = [tmp_bxx tmp_byy tmp_bzz tmp_bxy tmp_bxz tmp_byz];
	clear Fx_func Fy_func Fz_func start_time end_time
    clear tmp_bxx tmp_byy tmp_bzz tmp_bxy tmp_bxz tmp_byz
end
clear integral_func_value
b_matrix = sum(tmp_b_matrix,1);
clear tmp_b_matrix

end