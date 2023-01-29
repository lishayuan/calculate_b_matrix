%**************************************************************************
%	Script name: num__calc_sign_effGradSeries.m
%
%   Brief description: 
%       calculate the sign of effective gradients
%
%       input:
%           time points - sampling points of the discrete data
%                         (uniformly discretizing the whole time)
%           step_size - sampling step
%           time_group - number of groups formed by antiphase instants
%       output:
%           sign_eff - the sign of effective gradients
%
%   Copyright 2023, Lisha Yuan (lishayuan@zju.edu.cn)
%**************************************************************************

function sign_eff = num__calc_sign_effGradSeries(time_points, step_size, time_group)
%% Part I: assign a default value of 1 (the same size as time_points)
sign_eff = ones(length(time_points), 1);

%% Part II: assign values for different groups
if (length(time_group)-1 > 1)
    start_time = time_group(1);
    for idx_group = 1 : length(time_group)-1
        end_time = time_group(idx_group + 1);

        % the antiphase instant belongs to its previous interval
        idx_time = (time_points >= start_time) & (time_points <= end_time);
        sign_eff(idx_time) = (-1)^(idx_group-1); 

        time_range = start_time : step_size : end_time;
        start_time = time_range(end) + step_size;
        clear end_time idx_time time_range
    end
    clear start_time idx_group
end
