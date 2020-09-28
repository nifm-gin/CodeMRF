function metrics = seqEvaluation(pathToDico, nbNeighbours)

if nargin < 2
    nbNeighbours = 0;
end

% Load dictionary and associated parameters
pathSplit = split(pathToDico, filesep);
load(fullfile(pathToDico, ['dico_', pathSplit{end}, '.mat']), 'dictionary')
load(fullfile(pathToDico, ['prop_', pathSplit{end}, '.mat']), 'Properties')

% Define if estimation on whole dico or only on close neighbours
if nbNeighbours == 0
    localMatch = 0;
else
    localMatch = 1;
end

% Prepare dictionary evaluation
nEntries = size(dictionary, 1);
nbLocs = 50; %Number of dictionary entries to compute, from Sommer et al.
locs = round(linspace(1, nEntries, nbLocs));
nbReps = 2000; %2000 in sommer et al. 

propList = fieldnames(Properties);
propList = propList(contains(propList, 'list'));
for i = 1:numel(propList)
    if numel(Properties.(propList{i})) == 1 
        propList{i} = '';
    elseif numel(unique(Properties.(propList{i}))) == 1
        propList{i} = '';
    end
end
propList = propList(~cellfun(@isempty, propList));
nbParameters = numel(propList);

% Allocate error matrices
for i = 1:nbParameters
    % skip parameters with only one value
    allErrors.(propList{i}) = zeros(nbLocs, nbReps);
end

for r = 1:nbReps
    % Normalise dictionary and noised entries
    noisedEntries = addNoise(dictionary(locs, :), 'aliasing');
    noisedEntries = noisedEntries./vecnorm(noisedEntries, 2, 2);
    
    dictionary = dictionary./vecnorm(dictionary, 2, 2);
    
    % match
    [~,idxMatch] = max(noisedEntries * dictionary', [], 2, 'omitnan');
    for i = 1:nbParameters
        allErrors.(propList{i})(:,r) = abs(Properties.(propList{i})(locs) - Properties.(propList{i})(idxMatch));
    end
end

for i = 1:nbParameters
    metrics.(propList{i}) = sum( mean(allErrors.(propList{i}), 2) ./ Properties.(propList{i})(locs) ) / nbLocs;
end


