function [toDo, PulseProfile, Properties, Sequence, Dico] = readParameters(filePath)

% Reads .txt file to create toDo structure, containing instructions for dico simulation
% filePath is the path to the txt file to read

%% Check if file exists
if ~exist(filePath,'file')
    filePath = which(filePath); % Try to find m-file on the Matlab path
    if isempty(filePath)
        fprintf('Parameter file does not exist.\n');
        return
    end
end

%% Read lines
fid = fopen(filePath,'rt');
if fid > 0
    txtFile = textscan(fid, '%s', 'Delimiter',''); txtFile = txtFile{1};
    fclose(fid);
else
    fprintf('Cannot open Parameter file\n');
    return
end

%% Search for Model and Seq structure in the file
%toDoLine = cellfun( @(x)strncmp(x,'toDo.',5) ,txtFile );

%% Read Model strucutre
%for a=find(toDoLine)'
   %eval(txtFile{a}); 
%end
for i=1:numel(txtFile)
    eval(txtFile{i});
end
% toDo = toDo;
% PulseProfile = PulseProfile;
% Properties = Properties;
% Sequence = Sequence;

end