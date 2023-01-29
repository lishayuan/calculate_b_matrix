%*************************************************************************
%	Script name: sym__get_gradientPluse_Expression.m
%
%   Brief description: 
%       expain all gradient pulses of one axis as a piecewise function
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
%       func_struct - a structure defining the subfunction of an interval
%   output:
%       pulse_list - a list of subfunctions (contain the symbolic unknown_T)
%
%   Copyright 2023, Lisha Yuan (lishayuan@zju.edu.cn)
%*************************************************************************
    
function  pulse_list = sym__get_gradientPluse_Expression(grad_spec, func_struct)
    syms unknown_T;
    pulse_list = [];
    for idx = 1:size(grad_spec,1)
        %% Part I: read the specification of individual gradient
        startTime       = grad_spec(idx).start_time;    % us
    	amplitude       = grad_spec(idx).amplitude;     % mT/m
    	rampUpTime      = grad_spec(idx).rampup;        % us
    	duration        = grad_spec(idx).duration;      % us
    	rampDownTime    = grad_spec(idx).rampdown;      % us
        gradShape       = grad_spec(idx).shape;

        %% Part II: explain each gradient shape as several subfunctions
        switch gradShape{1}
            case 'Sinusoid'
                % disp('The gradient has a sinusoidal shape.');
                if (amplitude == 0)
                    continue;
                end
                assert(rampUpTime==0 && rampDownTime==0);
                % (duration period) sinusoid function
                pulse_list = cat(1,pulse_list, func_struct);
                pulse_list(end).start_time = startTime;
                pulse_list(end).end_time = startTime + duration;
                pulse_list(end).func = amplitude*sin(pi./duration.*(unknown_T-startTime));

            case 'Trapezoid'
                % disp('The gradient has a trapezoidal shape.');
                if (amplitude == 0)
                    continue;
                end
                assert(duration >= rampUpTime);
                % ramp up function
                if (rampUpTime > 0)
                    pulse_list = cat(1,pulse_list, func_struct);
                    pulse_list(end).start_time = startTime;
                    pulse_list(end).end_time = startTime + rampUpTime;
                    pulse_list(end).func = amplitude/rampUpTime*(unknown_T-startTime);
                end
                % plateau function
                if (duration > rampUpTime)
                    pulse_list = cat(1,pulse_list, func_struct);
                    pulse_list(end).start_time = startTime + rampUpTime;
                    pulse_list(end).end_time = startTime + duration;
                    pulse_list(end).func = amplitude;
                end
                % ramp down function
                if (rampDownTime > 0)
                    pulse_list = cat(1,pulse_list, func_struct);
                    pulse_list(end).start_time = startTime + duration;
                    end_time = startTime + duration + rampDownTime;
                    pulse_list(end).end_time = end_time;
                    pulse_list(end).func = (-1)*amplitude/rampDownTime*(unknown_T - end_time);
                    clear end_time
                end

            otherwise
                error('Undefined gradient shape! Please define its sub-functions!');
        end
        clear startTime amplitude rampUpTime duration rampDownTime gradShape
    end
    clear grad_spec
end   


