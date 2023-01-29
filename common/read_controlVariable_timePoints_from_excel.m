%*************************************************************************
%	Script name: read_controlVariable_timePoints_from_excel.m
%
%   Brief description: 
%       read control variables and extract time points from the excel
%
%   input:
%       filename    - the path and name of the excel file
%       idx_sheets  - the excel sheet containing control variables
%   output:
%       calc_Params: control variables used to calculate b-matrix
%       time_points: [calc_params.startTime calc_params.antiPhase calc_params.endTime]';
%              For SPEN, calc_params.endTime -> the center instant of different echoes
%
%   Copyright 2023, Lisha Yuan (lishayuan@zju.edu.cn)
%*************************************************************************

function [calc_params, time_points] = read_controlVariable_timePoints_from_excel(filename, idx_sheet)
%% Part I: read the content of the excel file
[sheet_num, ~, sheet_raw] = xlsread(filename, idx_sheet);
if (isequal(sheet_raw(2,1),{'seqType'})) 
    switch sheet_num(1,1)
        case 0
            % For GE/SE/EPI/RARE sequences
            %% Part II: read the control variables
            calc_params.seqType = 'GE/SE/EPI/RARE'; 
            assert(isequal(reshape(sheet_raw(3:end,1),[1,3]),[{'ExciteInstant'}, {'AntiphaseInstant'}, {'RefocusInstant'}]));
            calc_params.startTime = sheet_num(2,1);     % start_time
            calc_params.endTime = sheet_num(4,1);       % end_time
            
            % antiphase instants: 
            %   handle cases without or with single/multiple 180degree RF pulses
            if (isnan(sheet_num(3,1)))
                % without or with multiple 180degree RF pulses
                tmp_antiPhase = str2num(cell2mat(sheet_raw(4,2))); % antiphase_time
                if (isempty(tmp_antiPhase))
                    calc_params.antiPhase = [];
                else
                    calc_params.antiPhase = tmp_antiPhase(tmp_antiPhase < calc_params.endTime);
                end
            else
                % with single 180degree RF pulse
                if (sheet_num(3,1) >= calc_params.endTime)
                    calc_params.antiPhase = [];
                else
                    calc_params.antiPhase = sheet_num(3,1);
                end
            end
            
            %% Part III: extract time points
            time_points = [calc_params.startTime calc_params.antiPhase calc_params.endTime]';
            
        case 1
            % For SPEN sequences
            %% Part II: read the control variables
            % Step 1: the important variables
            calc_params.seqType = 'SPEN';
            assert(isequal(reshape(sheet_raw(3:end,1),[1,6]),[{'Nspen'},{'yFirstExcite'},{'yLastExcite'},{'AntiphaseInstant'},{'yFirstRefoc'},{'yLastRefoc'}]));
            Nspen = sheet_num(2, 1);
            yFirstExcite = sheet_num(3, 1);
            yLastExcite = sheet_num(4, 1);
            yFirstRefoc = sheet_num(6, 1);
            yLastRefoc = sheet_num(7, 1);

            % antiphase instants: 
            %   handle cases without or with single/multiple 180degree RF pulses
            if (isnan(sheet_num(5,1)))
                % without or with multiple 180degree RF pulses
                tmp_antiPhase = str2num(cell2mat(sheet_raw(6, 2))); % antiphase_time
                if (isempty(tmp_antiPhase))
                    antiPhase = [];
                else
                    antiPhase = tmp_antiPhase(tmp_antiPhase < yLastRefoc);
                end
                clear tmp_antiPhase
            else
                % with single 180degree RF pulse
                if (sheet_num(5,1) >= yLastRefoc)
                    antiPhase = [];
                else
                    antiPhase = sheet_num(5, 1);
                end
            end
            
            te_y = create_equispaced_timepoints(yFirstExcite, yLastExcite, Nspen);
            ta_y_inverse = create_equispaced_timepoints(yFirstRefoc, yLastRefoc, Nspen);
            ta_y = flip(ta_y_inverse);
            clear ta_y_inverse
            
            % Step 2: => common control variables
            calc_params.startTime = yFirstExcite;
            calc_params.antiPhase = antiPhase;
            calc_params.endTime = yLastRefoc;

            % Step 3: => specific control variables for SPEN sequence
            calc_params.Nspen = Nspen;
            calc_params.teY = te_y;
            calc_params.taY = ta_y;
            
            %% Part III: extract time points
            time_points = [yFirstExcite antiPhase ta_y']';
            
            clear Nspen yFirstExcite yLastExcite yFirstRefoc yLastRefoc
            clear antiPhase te_y ta_y

        otherwise
            %% if the sequence type is not supported, throw an error
            error('unknow sequence type!');
    end
else
    %% Throw an error if the Seqence type is not supported. 
    error('Please provide SeqType Menu!');
end
clear sheet_num sheet_raw

end

