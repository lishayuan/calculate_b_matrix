%*******************************************************************
%	Copyright 2019-2020
%   Author: Lisha Yuan (lishayuan@zju.edu.cn)
    %   Function statement: read gradient timing ([Ampl, Rut, Dur, Rdt, StartTime]) for each axis
    %   input:
    %       x_grad_pulses - the piecewise function of gradients in x-axis
    %       y_grad_pulses - the piecewise function of gradients in y-axis
    %       z_grad_pulses - the piecewise function of gradients in z-axis
    %
    %       filename    - the name of the excel file
    %       idx_sheets  - the index of the selected sheet for the above excel
    %                   both above input parameters define the control variables
    % 
    %   output:
    %       calc_Params: control variables used to calculate b-matrix
    %       time_points: time points (used to construct a 3D piecewise function)
%********************************************************************

function [calc_params, time_points] = extract_timepoints_from_gradPulse_controlVariable(x_grad_pulses,y_grad_pulses,z_grad_pulses, filename, idx_sheets)
%% Part I: time points from the piecewise function of gradients in each axis
tmp_struct = [x_grad_pulses; y_grad_pulses; z_grad_pulses];
tmp_cell = struct2cell(tmp_struct)';
tmp_time_points = [cell2mat(tmp_cell(:,1)); cell2mat(tmp_cell(:,2))];
time_points_1 = sort(unique(tmp_time_points));
clear x_grad_pulses y_grad_pulses z_grad_pulses
clear tmp_struct tmp_cell tmp_time_points

%% Part II: control variables and the final time points
[sheet_num,~,sheet_raw]=xlsread(filename,idx_sheets);
if (isequal(sheet_raw(2,1),{'seqType'})) 
    switch sheet_num(1,1) % check the seqence type
        case 0
            %% Step 1: let's obtain control variables
            calc_params.seqType = 'EPI/PGSE/OGSE/TGSE';
            assert(isequal(reshape(sheet_raw(3:end,1),[1,3]),[{'ExciteInstant'},{'AntiphaseInstant'},{'RefocusInstant'}]));
            calc_params.startTime = sheet_num(2,1);     % calcStartTime
            calc_params.RF180ss = sheet_num(3,1);       % halfEchoTime
            calc_params.endTime = sheet_num(4,1);       % calcEndTime
            
            %% Step 2:  combine & unique/sort & restrict all time points
            time_points_2 = [calc_params.startTime calc_params.RF180ss calc_params.endTime]';
            time_points = [time_points_1; time_points_2];
            time_points = sort(unique(time_points));
            index = (time_points >= calc_params.startTime) & (time_points <= calc_params.endTime);
            time_points = time_points(index);
            clear time_points_1 time_points_2 index

        case 1
            %% Step 1: let's obtain control variables
            calc_params.seqType = 'SPEN';
            assert(isequal(reshape(sheet_raw(3:end,1),[1,7]),[{'yFirstExcite'},{'yLastExcite'},{'Nspen'},{'RF180ss'},{'yFirstRefoc'},{'yLastRefoc'},{'flag_UniformTA'}]));
            calc_params.yFirstExcite = sheet_num(2,1);
            calc_params.yLastExcite = sheet_num(3,1);
            calc_params.Nspen = sheet_num(4,1);
            calc_params.RF180ss = sheet_num(5,1);       % halfEchoTime
            calc_params.yFirstRefoc = sheet_num(6,1);
            calc_params.yLastRefoc = sheet_num(7,1);
            calc_params.flag_UniformTA = sheet_num(8,1);
            
            %% Step 2:  combine & unique/sort & restrict all time points
            switch calc_params.flag_UniformTA
                case 0 % 'accurate'
                    calcRefocTime = create_equispaced_timepoints(calc_params.yFirstRefoc, calc_params.yLastRefoc, calc_params.Nspen);
                    time_points_2 = [calc_params.yFirstExcite calc_params.RF180ss calcRefocTime']'; % for the accurate calculation
                    clear calcRefocTime
                case 1 % 'approximate: uniform TA'
                    time_points_2 = [calc_params.yFirstExcite calc_params.RF180ss calc_params.yLastRefoc]'; % for the approximate calculation
                otherwise
                    error('For SPEN sequence: the flag definition cannot be recognized!');
            end
            time_points = [time_points_1; time_points_2];
            time_points = sort(unique(time_points));
            index = (time_points >= calc_params.yFirstExcite) & (time_points <= calc_params.yLastRefoc);
            time_points = time_points(index);
            clear time_points_1 time_points_2 index
    
        otherwise
            %% if the sequence type is not supported, throw an error
            error('unknow sequence type! only support SE-EPI or SPEN');
    end
else
    %% if there is on SeqType choise, throw an error
    error('Please provide SeqType Menu!');
end
clear sheet_num sheet_raw

end

