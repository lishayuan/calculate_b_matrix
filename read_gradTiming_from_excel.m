%*******************************************************************
%	Copyright 2019-2020
%   Author: Lisha Yuan (lishayuan@zju.edu.cn)
    %   Function statement: read gradient timing ([Ampl, Rut, Dur, Rdt, StartTime]) for each axis
    %   input:
    %       filename - the name of one excel file which defines the gradients' timing
    % 
    %   output:
    %       x_grad_timing - timing of each gradient in x-axis
    %       y_grad_timing - timing of each gradient in y-axis
    %       z_grad_timing - timing of each gradient in z-axis
    %       max_amplitude: record the max amplitude of all gradident pulses
    
%********************************************************************

function [x_grad_timing,y_grad_timing,z_grad_timing, max_amplitude] = read_gradTiming_from_excel(filename, idx_sheets, base_timing_struct)

    %% first, let's get the gradient timing information
    [sheet_num,~,sheet_raw]=xlsread(filename,idx_sheets);
    assert(isequal(sheet_raw(1,4:end),[{'StartTime'},{'Ampl'},{'Rut'},{'Dur'},{'Rdt'},{'RepeatTimes'},{'RepeatTimeGap'},{'x_axis'},{'y_axis'},{'z_axis'}]));
    column_indexes = num2cell([4:13]);
    [idx_startTime,idx_magnitude,idx_rut,idx_dur,idx_rdt,idx_repeatTimes,idx_repeatGap,idx_x_axis,idx_y_axis,idx_z_axis] = deal(column_indexes{:});

    max_amplitude = 0;
    max_amplitude = max([abs(sheet_num(:,idx_magnitude));max_amplitude]); % [mT/m]

    %% second, save the timing of individual gradient into each axis
    x_grad_timing = [];
    y_grad_timing = [];
    z_grad_timing = [];
    for idx_entry = 1: size(sheet_num,1) % each entry in the sheet
        grad_timing = [];
        magnitude = sheet_num(idx_entry, idx_magnitude);
        repeat_times = sheet_num(idx_entry, idx_repeatTimes);
        if (magnitude ~=0 && repeat_times >= 1)
            %% Step 1: save the gradient timing into a template
            start_time = sheet_num(idx_entry, idx_startTime);
            rampup = sheet_num(idx_entry, idx_rut);
            duration = sheet_num(idx_entry, idx_dur);
            rampdown = sheet_num(idx_entry, idx_rdt);
            repeat_gap = sheet_num(idx_entry, idx_repeatGap);

            tmp_grad_timing = base_timing_struct;
            tmp_grad_timing(end).start_time = start_time;
            tmp_grad_timing(end).magnitude = round(magnitude,4); %LY modified
            tmp_grad_timing(end).rampup = rampup;
            tmp_grad_timing(end).duration = duration;
            tmp_grad_timing(end).rampdown = rampdown;
            tmp_grad_timing(end).shape = sheet_raw(idx_entry+1,3);

            %% Step 2: interpret repeatitions into grad_timing
            grad_timing = cat(1,grad_timing,tmp_grad_timing);
            for idx_repeat = 2 :  repeat_times
                new_start_time = start_time+(idx_repeat-1)*repeat_gap;
                tmp_grad_timing(end).start_time = new_start_time;
                grad_timing = cat(1,grad_timing,tmp_grad_timing);
                clear new_start_time
            end
            clear start_time magnitude rampup duration rampdown repeat_gap
            clear tmp_grad_timing idx_repeat
 
            %% Step 3: regard the xyz axis value as the direction vector
            % get the direction vector from the excel
            direction_raw = [sheet_num(idx_entry,idx_x_axis),sheet_num(idx_entry,idx_y_axis),sheet_num(idx_entry,idx_z_axis)];
            % check the value and cook it a little bit
            direction = direction_sanity_check(direction_raw);
            
            % x axis
            if direction(1,1) ~= 0
                assert(direction(1,1)==1 || direction(1,1)==-1);
                direct_grad_timing = grad_timing;
                for idx_repeat = 1 :  repeat_times
                    direct_grad_timing(idx_repeat).magnitude = direct_grad_timing(idx_repeat).magnitude*direction(1,1);
                end
                x_grad_timing = cat(1, x_grad_timing, direct_grad_timing);
                clear direct_grad_timing
            end
            % y axis
            if direction(1,2) ~= 0
                assert(direction(1,2)==1 || direction(1,2)==-1);
                direct_grad_timing = grad_timing;
                for idx_repeat = 1 :  repeat_times
                    direct_grad_timing(idx_repeat).magnitude = direct_grad_timing(idx_repeat).magnitude*direction(1,2);
                end
                y_grad_timing = cat(1, y_grad_timing, direct_grad_timing);
                clear direct_grad_timing
            end
            % z axis
            if direction(1,3) ~= 0
                assert(direction(1,3)==1 || direction(1,3)==-1);
                direct_grad_timing = grad_timing;
                for idx_repeat = 1 :  repeat_times
                    direct_grad_timing(idx_repeat).magnitude = direct_grad_timing(idx_repeat).magnitude*direction(1,3);
                end
                z_grad_timing = cat(1, z_grad_timing, direct_grad_timing);
                clear direct_grad_timing direction
            end
            clear direction_raw
        end
    end
    clear repeat_times grad_timing
    clear idx_startTime idx_magnitude idx_rut idx_dur idx_rdt idx_repeatTimes column_indexes
    clear idx_repeatGap idx_x_axis idx_y_axis idx_z_axis idx_entry
    clear idx_sheets sheet_num sheet_raw
end

function [direction] = direction_sanity_check(direction)
    % check if the value for the direction is valid
    assert(isequal(size(direction),[1,3]));
    for temp_idx = 1: size(direction,2)
        assert(~isnan(direction(1,temp_idx)),'there is element is NaN!');
        % (in case of precision error) regard it as zero if the value is too small
        if abs(direction(1,temp_idx)) < 0.000001
            direction(1,temp_idx) = 0;
        end
    end
end