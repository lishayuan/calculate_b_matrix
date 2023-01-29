%*************************************************************************
%	Script name: sym__combine_gradPulse_into_3D.m
%
%   Brief description: 
%       combine the piecewise function of gradient pulses from all three axes together
%
%   input:
%       x_grad_pulses - the piecewise function of x-axis
%       y_grad_pulses - the piecewise function of y-axis
%       z_grad_pulses - the piecewise function of z-axis
%       time_points - time points which defines the intervals
%       derive_struct - contains the 3D subfunction of all intervals
%   output:
%       combined_grad_pulses - the 3D piecewise function of gradient pulses
%
%   Copyright 2023, Lisha Yuan (lishayuan@zju.edu.cn)
%*************************************************************************

function combined_grad_pulses = sym__combine_gradPulse_into_3D(x_grad_pulses, y_grad_pulses, z_grad_pulses, time_points, derive_struct)

combined_grad_pulses = [];
for idx = 1:(size(time_points,1)-1)
    
    %% Part I: For each interval, define [start_time end_time]
    combined_grad_pulses = cat(1,combined_grad_pulses, derive_struct);
    combined_grad_pulses(idx).start_time = time_points(idx);
    combined_grad_pulses(idx).end_time = time_points(idx+1);
    
    %% Part IIa: For each interval, define x_func
    % If there is x_grad_pulses.func defined. Otherwise, keep x_func = 0.
    for func_idx = 1:size(x_grad_pulses,1)
        if (( combined_grad_pulses(idx).start_time >= x_grad_pulses(func_idx).start_time) ...
           &&( combined_grad_pulses(idx).end_time <= x_grad_pulses(func_idx).end_time))
            combined_grad_pulses(idx).x_func = x_grad_pulses(func_idx).func;
            break;
        end
    end

    %% Part IIb: For each interval, define y_func
    % If there is y_grad_pulses.func defined. Otherwise, keep y_func = 0.
    for func_idx = 1:size(y_grad_pulses,1)
        if (( combined_grad_pulses(idx).start_time >= y_grad_pulses(func_idx).start_time) ...
           &&( combined_grad_pulses(idx).end_time <= y_grad_pulses(func_idx).end_time))
            combined_grad_pulses(idx).y_func = y_grad_pulses(func_idx).func;
            break;
        end
    end

    %% Part IIc: For each interval, define z_func
    % If there is z_grad_pulses.func defined. Otherwise, keep z_func = 0.
    for func_idx = 1:size(z_grad_pulses,1)
        if (( combined_grad_pulses(idx).start_time >= z_grad_pulses(func_idx).start_time) ...
          &&( combined_grad_pulses(idx).end_time <= z_grad_pulses(func_idx).end_time))
            combined_grad_pulses(idx).z_func = z_grad_pulses(func_idx).func;
            break;
        end
    end

end