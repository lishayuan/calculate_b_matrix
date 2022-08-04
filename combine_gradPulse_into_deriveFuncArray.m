%*******************************************************************
%	Copyright 2019-2020
%   Author: Lisha Yuan (lishayuan@zju.edu.cn)
    %   Function statement: combine functions of gradient pulses from all three axes together
    %   input:
    %       x_grad_pulses - functions of each trapezoid gradient for x-axis, like [start_time, end_time,func(default:0)]
    %       y_grad_pulses - functions of each trapezoid gradient for y-axis
    %       z_grad_pulses - functions of each trapezoid gradient for z-axis
    %       time_points - determine how many sections should be considered
    %       derive_function_array - a standard struct, in which each section contains start_time, end_time, and the function of three axes
    % 
    %   output:
    %       derive_pulse_list - the 3D piecewise function combined from three axes
    
%********************************************************************

function derive_pulse_list = combine_gradPulse_into_deriveFuncArray(x_grad_pulses,y_grad_pulses,z_grad_pulses, time_points, derive_function_struct)

derive_pulse_list = [];
for idx = 1:(size(time_points,1)-1)
    derive_pulse_list = cat(1,derive_pulse_list, derive_function_struct);
    derive_pulse_list(idx).start_time = time_points(idx);
    derive_pulse_list(idx).end_time = time_points(idx+1);
    
    %% Part I: define x_func (if there is X_pulse.func definition)
    % Otherwise, keep x_func = 0 as default.
    for func_idx = 1:size(x_grad_pulses,1)
        if (( derive_pulse_list(idx).start_time >= x_grad_pulses(func_idx).start_time) ...
           &&( derive_pulse_list(idx).end_time <= x_grad_pulses(func_idx).end_time))
            derive_pulse_list(idx).x_func = x_grad_pulses(func_idx).func;
            break;
        end
    end

    %% Part II: define y_func, same as above
    for func_idx = 1:size(y_grad_pulses,1)
        if (( derive_pulse_list(idx).start_time >= y_grad_pulses(func_idx).start_time) ...
           &&( derive_pulse_list(idx).end_time <= y_grad_pulses(func_idx).end_time))
            derive_pulse_list(idx).y_func = y_grad_pulses(func_idx).func;
            break;
        end
    end

    %% Part III: define z_func, same as above
    for func_idx = 1:size(z_grad_pulses,1)
        if (( derive_pulse_list(idx).start_time >= z_grad_pulses(func_idx).start_time) ...
          &&( derive_pulse_list(idx).end_time <= z_grad_pulses(func_idx).end_time))
            derive_pulse_list(idx).z_func = z_grad_pulses(func_idx).func;
            break;
        end
    end

end