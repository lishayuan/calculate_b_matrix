%*************************************************************************
%	Script name: read_timePoints_from_excel.m
%
%   Brief description: 
%       read control variables from the excel
%
%   input:
%       filename    - the path and name of the excel file
%       idx_sheets  - the excel sheet containing control variables
%   output:
%       calc_Params: control variables used to calculate b-matrix
%
%   Copyright 2023, Lisha Yuan (lishayuan@zju.edu.cn)
%*************************************************************************

function calc_params = read_timePoints_from_excel(filename, idx_sheet)
%% Part I: control variables and the final time points
[sheet_num, ~, sheet_raw] = xlsread(filename, idx_sheet);
if(sheet_num(1,1)==0)
    % sequence types without 180degree pulse
    calc_params.seqType = 'GE/SE/EPI/RARE'; 
    assert(isequal(reshape(sheet_raw(3:end,1),[1,3]),[{'ExciteInstant'}, {'AntiphaseInstant'}, {'RefocusInstant'}]));
    calc_params.startTime = sheet_num(2,1);     % start_time
    calc_params.endTime = sheet_num(4,1);       % end_time
    
    if (isnan(sheet_num(3,1)))
        tmp_antiPhase = str2num(cell2mat(sheet_raw(4,2))); % antiphase_time
        if (isempty(tmp_antiPhase))
            calc_params.antiPhase = [];
        else
            calc_params.antiPhase = tmp_antiPhase(tmp_antiPhase < calc_params.endTime);
        end
    else  
        if (sheet_num(3,1) >= calc_params.endTime)
            calc_params.antiPhase = [];
        else
            calc_params.antiPhase = sheet_num(3,1);
        end
    end
    
else
    %% Throw an error if the Seqence type is not supported. 
    error('Please provide SeqType Menu!');
end
clear sheet_num sheet_raw

end

