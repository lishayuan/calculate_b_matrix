%*************************************************************************
%	Script name: read_gradSpec_from_excel.m
%
%   Brief description: 
%       read gradient specifications for each axis
%
%   input:
%       filename - the path and name of the excel file
%       idx_sheet - the excel sheet containing gradient specifications
%       base_struct - gradient specification
%                     [StartTime, Shape, Ampl, Rut, Dur, Rdt]
%   output:
%       x_grad_spec - the specifications of all gradients in x-axis
%       y_grad_spec - the specifications of all gradients in y-axis
%       z_grad_spec - the specifications of all gradients in z-axis
%       max_amplitude: record the max amplitude of all gradident pulses
%
%   Copyright 2023, Lisha Yuan (lishayuan@zju.edu.cn)
%*************************************************************************

function [x_grad_spec, y_grad_spec, z_grad_spec, max_amplitude] = read_gradSpec_from_excel(filename, idx_sheet, base_struct)

    %% first, let's get the gradient specifications
    [sheet_num, ~, sheet_raw] = xlsread(filename, idx_sheet);
    assert(isequal(sheet_raw(1,4:end),[{'StartTime'},{'Ampl'},{'Rut'},{'Dur'},{'Rdt'},{'RepeatTimes'},{'RepeatTimeGap'},{'x_axis'},{'y_axis'},{'z_axis'}]));
    column_indexes = num2cell(4:13);
    [idx_startTime, idx_amplitude, idx_rut, idx_dur, idx_rdt, idx_repeatTimes, idx_repeatGap, idx_x_axis, idx_y_axis, idx_z_axis] = deal(column_indexes{:});

    max_amplitude = 0;
    max_amplitude = max([abs(sheet_num(:,idx_amplitude)); max_amplitude]); % [mT/m]

    %% second, save the specification of individual gradient into each axis
    x_grad_spec = [];
    y_grad_spec = [];
    z_grad_spec = [];
    for idx_entry = 1: size(sheet_num, 1) % each entry in the sheet
        grad_spec = [];
        amplitude = sheet_num(idx_entry, idx_amplitude);
        repeat_times = sheet_num(idx_entry, idx_repeatTimes);
        if (amplitude ~=0 && repeat_times >= 1)
            %% Step 1: save the gradient specification into a template
            start_time = sheet_num(idx_entry, idx_startTime);
            rampup = sheet_num(idx_entry, idx_rut);
            duration = sheet_num(idx_entry, idx_dur);
            rampdown = sheet_num(idx_entry, idx_rdt);
            repeat_gap = sheet_num(idx_entry, idx_repeatGap);

            tmp_grad_spec = base_struct;
            tmp_grad_spec.start_time = start_time;
            tmp_grad_spec.amplitude = round(amplitude, 4); %LY modified
            tmp_grad_spec.rampup = rampup;
            tmp_grad_spec.duration = duration;
            tmp_grad_spec.rampdown = rampdown;
            tmp_grad_spec.shape = sheet_raw(idx_entry+1, 3);

            %% Step 2: unfold the item if it contains duplicates
            grad_spec = cat(1, grad_spec, tmp_grad_spec);

            for idx_repeat = 2:repeat_times
                new_start_time = start_time + (idx_repeat-1) * repeat_gap;
                tmp_grad_spec.start_time = new_start_time;
                grad_spec = cat(1, grad_spec, tmp_grad_spec);
                clear new_start_time
            end
            clear start_time amplitude rampup duration rampdown repeat_gap
            clear tmp_grad_spec idx_repeat
 
            %% Step 3: put all items of the same axis together
            % get the direction vector from the excel
            direction_raw = [sheet_num(idx_entry, idx_x_axis), sheet_num(idx_entry, idx_y_axis), sheet_num(idx_entry, idx_z_axis)];
            % check the value and cook it a little bit
            direction = direction_sanity_check(direction_raw);
            clear direction_raw

            % x axis
            if direction(1,1) ~= 0
                assert(direction(1,1)==1 || direction(1,1)==-1);
                direct_grad_spec = grad_spec;
                for idx_repeat = 1 :  repeat_times
                    direct_grad_spec(idx_repeat).amplitude = grad_spec(idx_repeat).amplitude * direction(1,1);
                end
                x_grad_spec = cat(1, x_grad_spec, direct_grad_spec);
                clear direct_grad_spec
            end
            
            % y axis
            if direction(1,2) ~= 0
                assert(direction(1,2)==1 || direction(1,2)==-1);
                direct_grad_spec = grad_spec;
                for idx_repeat = 1 :  repeat_times
                    direct_grad_spec(idx_repeat).amplitude = grad_spec(idx_repeat).amplitude * direction(1,2);
                end
                y_grad_spec = cat(1, y_grad_spec, direct_grad_spec);
                clear direct_grad_spec
            end
            
            % z axis
            if direction(1,3) ~= 0
                assert(direction(1,3)==1 || direction(1,3)==-1);
                direct_grad_spec = grad_spec;
                for idx_repeat = 1 :  repeat_times
                    direct_grad_spec(idx_repeat).amplitude = grad_spec(idx_repeat).amplitude * direction(1,3);
                end
                z_grad_spec = cat(1, z_grad_spec, direct_grad_spec);
                clear direct_grad_spec
            end
            
            clear direction
        end
        
        clear repeat_times 
    end
    
    clear idx_startTime idx_amplitude idx_rut idx_dur idx_rdt idx_repeatTimes column_indexes
    clear idx_repeatGap idx_x_axis idx_y_axis idx_z_axis idx_entry
    clear idx_sheets sheet_num sheet_raw
end

function direction = direction_sanity_check(direction)
    % check if the value for the direction is valid
    assert(isequal(size(direction),[1,3]));
    for temp_idx = 1: size(direction,2)
        assert(~isnan(direction(1,temp_idx)),'there is element is NaN!');
        % (in case of precision error) regard it as zero if the value is too small
        if abs(direction(1,temp_idx)) < 0.000001
            direction(1,temp_idx) = 0;
        end
    end
    clear temp_idx
end