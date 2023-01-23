%*************************************************************************
%	Script name: num__get_gradientPluse_timeSeries.m
%
%   Brief description: 
%       expain all gradient pulses of one axis as discrete gradient data
%
%   input:
%       grad_spec - all gradient events, each line contains the
%                       following specification of one gradient,
%                           start_time  : the start time
%                           shape       : the gradient shape
%                           amplitude   : the amplitude
%                           rampup      : the ramp up time
%                           duration    : ramp up and hold time 
%                           rampdown    : the ramp dowm time
%       time points - sampling points of the discrete data
%                     (uniformly discretizing the whole time)
%   output:
%       grad_series - discrete gradient data (gradients of the same axis)
%
%   Copyright 2023, Lisha Yuan (lishayuan@zju.edu.cn)
%*************************************************************************
    
function  grad_series = num__get_gradientPluse_timeSeries(grad_spec, time_points)

    grad_series = zeros(length(time_points), 1);
    %% Part I: explain individual gradient event as several functions
    for idx = 1:size(grad_spec,1)
        startTime       = grad_spec(idx).start_time;  % s
    	amplitude       = grad_spec(idx).amplitude;  % T/m
    	rampUpTime      = grad_spec(idx).rampup;  % s
    	duration        = grad_spec(idx).duration;  % s
    	rampDownTime    = grad_spec(idx).rampdown;  % s
        gradShape = grad_spec(idx).shape;

        switch gradShape{1}
            case 'Sinusoid'
                % disp('The gradient has a sinusoidal shape.');
                if (amplitude == 0)
                    continue;
                end
                assert(rampUpTime==0 && rampDownTime==0);
                % (duration period) sinusoid function
                start_time = startTime;
                end_time = startTime + duration; %time_range = (start_time : step_size : end_time)';
                index = (time_points >= start_time) & (time_points <= end_time);
                time_range = time_points(index);
                grad_series(index) = amplitude*sin(pi./duration.*(time_range-startTime));
                clear start_time end_time index time_range
                

            case 'Trapezoid'
                % disp('The gradient has a trapezoidal shape.');
                if (amplitude == 0)
                    continue;
                end
                assert(duration >= rampUpTime);
                % ramp up function
                if (rampUpTime > 0)
                    start_time = startTime;
                    end_time = startTime + rampUpTime;
                    index = (time_points >= start_time) & (time_points <= end_time);
                    time_range = time_points(index);
                    grad_series(index) = amplitude/rampUpTime*(time_range-startTime);
                    clear start_time end_time time_range index
                end
                % plateau function
                if (duration > rampUpTime)
                    start_time = startTime + rampUpTime;
                    end_time = startTime + duration;
                    index = (time_points >= start_time) & (time_points <= end_time);
                    grad_series(index) = amplitude;
                    clear start_time end_time index
                end
                % ramp down function
                if (rampDownTime > 0)
                    start_time = startTime + duration;
                    end_time = startTime + duration + rampDownTime;
                    index = (time_points >= start_time) & (time_points <= end_time);
                    time_range = time_points(index);
                    grad_series(index) = (-1)*amplitude/rampDownTime*(time_range - end_time);
                    clear start_time end_time time_range index
                end

            otherwise
                disp('The gradient has an undefined shape!')
                error('The new gradient shape should define its function by yourself!');
        end
        clear startTime amplitude rampUpTime duration rampDownTime gradShape
    end
    clear grad_spec
end