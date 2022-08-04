function [filepath, filename, name] = get_filename_batch(file_wildcard)
% return the filepath, filename, name(without extension)

[filepath, ~, ~] = fileparts(file_wildcard);
file = cellstr(ls(file_wildcard));
Num_files = length(file);

filename = cell(size(file));
name = cell(size(file));
for i = 1:Num_files
    filename{i} = [filepath,filesep,file{i}];
    [~, name{i}, ~] = fileparts(file{i});
end