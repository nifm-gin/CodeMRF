function [metricsGlobal, metricsDetail] = seqEvaluation(pathToDico, nbNeighbours, noiseType, SNR, pattern)
    oneByOne = 0; % debug option, if 0 matching is performed with matrix operations, else matching is sequential, one noised entry by one
    if nargin < 5
        pattern = 'None';
    end    
    if nargin < 4
        SNR = 4;
    end
    if nargin < 3
        noiseType = 'aliasing';
    end
    if nargin < 2
        nbNeighbours = 0;
    end

    if isstr(pathToDico)
        % Load dictionary and associated parameters
        pathSplit = split(pathToDico, filesep);
        load(fullfile(pathToDico, ['dico_', pathSplit{end}, '.mat']), 'dictionary')
        load(fullfile(pathToDico, ['prop_', pathSplit{end}, '.mat']), 'Properties')
    elseif isstruct(pathToDico)
        dictionary = pathToDico.dictionary;
        Properties = pathToDico.Properties;
    end
    
    if ~strcmp(pattern, 'None') % if pattern is specified
        MRSignals = dictionary.MRSignals;            
        dictionary = makePattern(dictionary.MRSignals{1}, dictionary.MRSignals{2}, pattern);
    else
        dictionary = dictionary.MRSignals;
    end
    
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

    normedDictionary = dictionary./vecnorm(dictionary, 2, 2);
    for r = 1:nbReps
        % Normalise dictionary and noised entries
        if strcmp(pattern, 'None')
            noisedEntries = addNoise(dictionary(locs, :), noiseType, SNR);           
        else
            noisedEntries = makePattern(addNoise(MRSignals{1}(locs,:), 'thermal', SNR(1)), addNoise(MRSignals{2}(locs,:), 'thermal', SNR(1)), pattern);
        end      
        
        if ~oneByOne
            noisedEntries = noisedEntries./vecnorm(noisedEntries, 2, 2);
        end
        % match
        if ~oneByOne
            [~,idxMatch] = max(noisedEntries * normedDictionary', [], 2, 'omitnan');
        else
            idxMatch = nan(1,nbLocs);
            tmp = 0;
            score = 0;
            perfectMatch = zeros(1, nbLocs);
            for s = 1:nbLocs
                localSig = noisedEntries(s,:);
                toRemove = isinf(localSig) | isnan(localSig);
                localSig = localSig(~toRemove);
                localSig = localSig / vecnorm(localSig, 2, 2);
                [~, idxMatch(s)] = max(localSig * normedDictionary(:, ~toRemove)', [], 2, 'omitnan');
                perfectMatch(s) = (locs(s) == idxMatch(s));
            end
%             if tmpScore > score
%                 idxMatch(s) = tmpIdx;
%                 score = tmpScore;
%             end
        end
        
        for i = 1:nbParameters
            allErrors.(propList{i})(:,r) = abs(Properties.(propList{i})(locs) - Properties.(propList{i})(idxMatch));
        end
    end

    for i = 1:nbParameters
        tmpErr = allErrors.(propList{i}) ./ Properties.(propList{i})(locs);
        metricsDetail.(propList{i})(:, 1) = mean(tmpErr, 2);
        metricsDetail.(propList{i})(:, 2) = std(tmpErr, 0, 2);
        metricsDetail.(propList{i})(:, 3) = Properties.(propList{i})(locs);
%         metricsGlobal.(propList{i})(1) = mean(metricsDetail.(propList{i})(:, 1));
%         metricsGlobal.(propList{i})(2) = std(metricsDetail.(propList{i})(:, 1));
        metricsGlobal.(propList{i})(1) = mean(tmpErr, 'all');
        metricsGlobal.(propList{i})(2) = std(tmpErr, 0, 'all');
    end
end

