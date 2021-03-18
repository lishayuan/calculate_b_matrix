%*******************************************************************
%	Copyright 2019-2021 Lisha Yuan
%   File name:
%   Author: Lisha Yuan
%   Brief introduction:
%********************************************************************

function  pulse_list = get_gradientPluse_Expression(grad_timing,base_function_struct)
    %   Function statement: expain each gradient timing as several piecewise functions
    %   input:
    %       gradTiming - all gradient events
    %                   each line means one gradient, and it contains timing parameters as follows,  
    %                   amplitude       : the amplitude of the ramp up
    %                   rampUpTime      : the ramp up time
    %                   duration        : ramp up and hold time 
    %                   rampDownTime    : the ramp dowm time
    %                   startTime       : the start time for pulse
    %       BaseFunctStruct - the base structure to define the piecewise function
    %                         besides, make sure the the default function is an invalid value
    % 
    %   output:
    %       unique_pulse_list - a list of functions (contain the symbolic unknown_T constant_0)
    %                           if two ramp functions were defined within one segment, merge them.
    %       flag_grad_merge - tell the user if there is gradients merge case.
    % 
    % 
    %	(c) Lisha Yuan 2019

    syms unknown_T;
    %% Part I: explain individual gradient event as several functions
    pulse_list = [];
    for idx = 1:size(grad_timing,1)
        startTime       = grad_timing(idx).start_time;  % s
    	magnitude       = grad_timing(idx).magnitude;  % T/m
    	rampUpTime      = grad_timing(idx).rampup;  % s
    	duration        = grad_timing(idx).duration;  % s
    	rampDownTime    = grad_timing(idx).rampdown;  % s
        gradShape = grad_timing(idx).shape;

        switch gradShape{1}
            case 'Sinusoid'
                % disp('The gradient has a sinusoidal shape.');
                if (magnitude == 0)
                    continue;
                end
                assert(rampUpTime==0 && rampDownTime==0);
                % (duration period) sinusoid function
                pulse_list = cat(1,pulse_list,base_function_struct);
                pulse_list(end).start_time = startTime;
                pulse_list(end).end_time = startTime + duration;
                pulse_list(end).func = magnitude*sin(pi./duration.*(unknown_T-startTime));

            case 'Trapezoid'
                % disp('The gradient has a trapezoidal shape.');
                if (magnitude == 0)
                    continue;
                end
                assert(duration>=rampUpTime);
                % ramp up function
                if (rampUpTime>0)
                    pulse_list = cat(1,pulse_list,base_function_struct);
                    pulse_list(end).start_time = startTime;
                    pulse_list(end).end_time = startTime + rampUpTime;
                    pulse_list(end).func = magnitude/rampUpTime*(unknown_T-startTime);
                end
                % plateau function
                if (duration>rampUpTime)
                    pulse_list = cat(1,pulse_list,base_function_struct);
                    pulse_list(end).start_time = startTime + rampUpTime;
                    pulse_list(end).end_time = startTime + duration;
                    pulse_list(end).func = magnitude;
                end
                % ramp down function
                if (rampDownTime>0)
                    pulse_list = cat(1,pulse_list,base_function_struct);
                    pulse_list(end).start_time = startTime + duration;
                    end_time = startTime + duration + rampDownTime;
                    pulse_list(end).end_time = end_time;
                    pulse_list(end).func = (-1)*magnitude/rampDownTime*(unknown_T - end_time);
                    clear end_time
                end

            otherwise
                disp('The gradient has an undefined shape!')
                error('The function of gradients with a specific shape should be defined by yourself!');
        end
        clear startTime magnitude rampUpTime duration rampDownTime gradShape
    end
    % clear grad_timing

    %% Part II: (if necessary) merge functions which were defined in a common segment
    % unique_pulse_list = merge_overlap_gradientPluse(pulse_list);
end   


% function merged_pulse_list = merge_overlap_gradientPluse(pulse_list)
%     temp_pulse_list = pulse_list;
%     merge_completed = false;
%     % unlikely case, there is only one pluse in the list
%     if size(temp_pulse_list,1) == 1
%         merged_pulse_list = pulse_list;
%         merge_completed = true;
%     end
% 
%     while ~merge_completed
%         [~,idx_list] = sort([temp_pulse_list.start_time]);
%         temp_pulse_list = temp_pulse_list(idx_list);
%         % save the first pulse
%         merged_pulse_list = temp_pulse_list(1);
%         for idx = 2:size(temp_pulse_list,1)
%             if merged_pulse_list(end).end_time <= temp_pulse_list(idx).start_time
%                 % there is no overlap, just copy it
%                 merged_pulse_list = cat(1,merged_pulse_list, temp_pulse_list(idx));
%             else
%                 %now let's consider the overlap senerio
%                 % A : |________________________|
%                 % B :    |____________________________|
%                 % S1: |__|
%                 % S2:    |_____________________|
%                 % S3:                          |_______|
%                 % we could see that PUSLE A & B have a common area P2.
%                 % S1 = expression of A; S2 = expression of A + expression of B
%                 % S3 = expression of B
%                 pulseA = merged_pulse_list(end);
%                 pulseB = temp_pulse_list(idx);
%                 points = sort(unique([pulseA.start_time, pulseA.end_time, pulseB.start_time, pulseB.end_time]));
%                 switch size(points,2)
%                     case 2
%                         % A : |_________________|
%                         % B : |_________________|
%                         merged_pulse_list(end).func = pulseA.func + pulseB.func;
%                     case 3
%                         % A : |_________________|
%                         % B : |____________|
%                         %   or
%                         % A : |_________________|
%                         % B :     |_____________|
%                         slice1 = base_function_struct;
%                         slice2 = base_function_struct;
%                         slice1.start_time = points(1);
%                         slice1.end_time = points(2);
%                         slice2.start_time = points(2);
%                         slice2.end_time = points(3);
%                         if pulseA.start_time == pulseB.start_time
%                             slice1.func = pulseA.func + pulseB.func;
%                             if pulseA.end_time < pulseB.end_time
%                                 slice2.func = pulseB.func;
%                             else
%                                 slice2.func = pulseA.func;
%                             end
%                         else
%                             slice1.func = pulseA.func;
%                             slice2.func = pulseA.func + pulseB.func;
%                         end
%                         merged_pulse_list(end).end_time = slice1.end_time;
%                         merged_pulse_list(end).func = slice1.func;
%                         merged_pulse_list = cat(1,merged_pulse_list, slice2);
%                     case 4
%                         % A : |________________________|
%                         % B :    |____________________________|
%                         %    or 
%                         % A : |________________________|
%                         % B :    |_________________|
%                         % for the first slice, we only need to ajust the end time in the merged list
%                         merged_pulse_list(end).end_time = points(2);
%                         slice2 = base_function_struct;
%                         slice3 = base_function_struct;
%                         slice2.start_time = points(2);
%                         slice2.end_time = points(3);
%                         slice3.start_time = points(3);
%                         slice3.end_time = points(4);
%                         slice2.func = pulseA.func + pulseB.func;
%                         if pulseA.end_time < pulseB.end_time
%                             slice3.func = pulseB.func;
%                         else
%                             slice3.func = pulseA.func;
%                         end
%                         merged_pulse_list = cat(1,merged_pulse_list, slice2);
%                         merged_pulse_list = cat(1,merged_pulse_list, slice3);
%                     otherwise
%                         assert(0, 'unknown case');
%                 end
%                 % after merge, let's check if the next pulse has overlap with current one
%                 if idx < size(temp_pulse_list,1)
%                     if merged_pulse_list(end).end_time > temp_pulse_list(idx+1).start_time
%                         % if yes, it is too complicated to list all the cases for overlap of 3+ pulses
%                         % as it is a rare senerio, if this really happened,
%                         % we could handle it by saving current merge result, sorting list and doing 2 pulse overlap process
%                         % it is slow, but shoule be able to handle it!
%                         merged_pulse_list = cat(1,merged_pulse_list, temp_pulse_list(idx+1:end));
%                         temp_pulse_list = merged_pulse_list;
%                         % break for the for loop, it may re-enter again as the while loop does not exit yet
%                         break;
%                     end
%                 end
%             end
% 
%             if idx == size(temp_pulse_list,1)
%                 merge_completed = true;
%             end 
%         end
%     end
    

    %start_points = cell2mat(tmp(:,1));
    %unique_start_points = unique(start_points);
    %clear tmp
    %
    %if length(unique_start_points)==length(start_points)
    %    disp('There is no merge case (multiple functions are defined within one segment)!')
    %	unique_pulse_list = pulse_list;
    %	return;
    %else
    %    disp('there are merge cases (multiple functions defined within one segment)')
    %    for idx = 1:size(unique_start_points,1)
    %        start_time = unique_start_points(idx);
    %        unique_pulse_list = cat(1,unique_pulse_list, base_function_struct);
    %        unique_pulse_list(idx).start_time = start_time;
    %
    %        index = find(start_points==start_time);
    %        end_time = pulse_list(index(1)).end_time;
    %        unique_pulse_list(idx).end_time = end_time;
    %        for rep = 1:length(index)
    %            segment_num = index(rep);
    %            assert(pulse_list(segment_num).end_time == end_time);
    %            unique_pulse_list(idx).func = unique_pulse_list(idx).func + pulse_list(segment_num).func;
    %            clear segment_num
    %        end
    %        clear start_time index end_time rep
    %    end
    %end
    %clear start_points unique_start_points
% end
