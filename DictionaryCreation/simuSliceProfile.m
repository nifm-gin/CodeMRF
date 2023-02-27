
%% Parameters
paramName = 'spgr_phantomPhilips.txt';
FA = 30; % degree
sliceThickness = 4; %mm


%% Get slice profile
fullProfile = getSliceProfile(FA, sliceThickness);
reductionFactor = 1;
reducedProfile = fullProfile(1:reductionFactor:end)';
[countFA, uniqueFA] = groupcounts(reducedProfile);

doPlot = 1; % 1 for plot
if doPlot
    xplot = linspace(0, sliceThickness, numel(fullProfile));
    figure; 
    plot(xplot, fullProfile, '-+', 'MarkerSize', 2);
    hold on
    plot(xplot(1:reductionFactor:end), reducedProfile, '-o')
    xlim([0,max(xplot)])
    xlabel('mm')
    ylabel('FA (°)')
    legend({'Full profile', 'Undersampled'})
end

%% Simu
tmpRootDir  = fileparts(mfilename('fullpath'));
idx = strfind(tmpRootDir,'/');
rootDir = tmpRootDir(1:idx(end));
[tmp.toDo, tmp.PulseProfile, tmp.Properties, tmp.Sequence, tmp.Dico] = readParameters(fullfile(rootDir, 'DictionaryCreation/dicoSimParameters/', paramName));
[tmp.Properties] = genproperties_mrfv3(tmp.Properties);
tmp.toDo.saveDico = 0;
tmp.toDo.savePropStruct = 0;
tmp.toDo.saveSeqStruct = 0;
tmpDico = [];
tStart = tic;
for i = 1:numel(uniqueFA)
    fprintf('========== Simu %i / %i ==========\n', i, numel(uniqueFA));
    tmp.Sequence.FAmin  = uniqueFA(i);
    tmp.Sequence.FAmax  = uniqueFA(i);
    tmp.Sequence        = genSeq(tmp.Sequence);
    if isempty(tmpDico)
        tmpDico         = countFA(i).*dictionarySimulation(tmp);
    else
        tmpDico         = tmpDico + countFA(i).*dictionarySimulation(tmp);
    end
end
tEnd = toc(tStart);
dictionary = tmpDico / sum(countFA);
fprintf('========== End of simulations ==========\n')
fprintf('%i dictionaries generated in %f seconds\n', numel(uniqueFA), tEnd)
fprintf('========================================\n')

%% Save dico and structs
assert(mkdir([rootDir, 'DictionaryCreation/Results/', tmp.Dico.saveName]));
% dico
save([rootDir, 'DictionaryCreation/Results/', tmp.Dico.saveName, '/dico_', tmp.Dico.saveName], 'dictionary',  '-v7.3')

% seq
tmp.Sequence.FAmin  = FA;
tmp.Sequence.FAmax  = FA;
tmp.Sequence        = genSeq(tmp.Sequence);
Sequence = tmp.Sequence;
save([rootDir, 'DictionaryCreation/Results/', tmp.Dico.saveName, '/seq_', tmp.Dico.saveName, '.mat'], 'Sequence')

% prop
Properties = tmp.Properties;
save([rootDir, 'DictionaryCreation/Results/', tmp.Dico.saveName, '/prop_', tmp.Dico.saveName, '.mat'], 'Properties')

