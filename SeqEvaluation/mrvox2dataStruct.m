%%
clear Properties
clear dictionary

% flag to indicate if need to load a dico or json files
flagIsDico = 1;
dicoPath = '/home/aurelien/Installations/MP3/data/dictionaries/G0A0/DICO.mat';
% path to pre json
prePath = '/home/aurelien/Installations/MP3/data/dictionaries/G0A0/2020-08-06_09-27-05-090_ModelPar_Blood_3D_anisotropic_Dict_GESFIDE_PRE_dico.json'; 
% path to post json
postPath = '/home/aurelien/Installations/MP3/data/dictionaries/G0A0/2020-08-06_09-27-05-090_ModelPar_Blood_3D_anisotropic_Dict_GESFIDE_POST_dico.json';

% path to save the files
outPath = '/home/aurelien/Installations/CodeMRF/DictionaryCreation/Results/testFromMRVOX2';
% combination of signals ('Ratio', 'Concat', 'Hybrid', 'Other')
comb = 'Concat';

%%
if flagIsDico
    load(dicoPath)
    Tacq = Dico.Tacq(1:end-1) * 1e3; % convert to ms
    MRSignals{1} = getAcqEchoes(abs(Dico.MRSignals{1}), Tacq);
    MRSignals{2} = getAcqEchoes(abs(Dico.MRSignals{2}), Tacq);
    Parameters = Dico.Parameters;
    clear Dico
else
    pre = loadjson(prePath);
    post = loadjson(postPath);
    Tacq = pre.Sequence.Tacq(1:end-1) * 1e3; % convert to ms

    MRSignals{1} = getAcqEchoes(abs(pre.MRSignals), Tacq);
    MRSignals{2} = getAcqEchoes(abs(post.MRSignals), Tacq);
    Parameters = pre.Parameters;
    clear pre post
end
switch comb
    case 'Ratio'
        dictionary = MRSignals{2} ./ MRSignals{1};
    case 'Concat'
        dictionary = [ MRSignals{1}, MRSignals{2} ];
    case 'Hybrid'
        dictionary = [ MRSignals{2}(:, 1:9) ./ MRSignals{1}(:, 1:9), MRSignals{1}(:, 10:end), MRSignals{2}(:,10:end) ];
    case 'Other'
        % Implement here what you want
        warning('"Other" method must be implemented')
        dictionary = [];
    otherwise
        error("Please specify a combination ('Ratio', 'Concat', 'Hybrid', 'Other')")
end

nbParameters = numel(Parameters.Labels) - 3; % nb labels -3 to account for the 3 mandatory parameters (Id, RTry, Timer)

for i = 1:nbParameters
   Split = strsplit(Parameters.Labels{i},'.');
   Properties.([Split{end}, 'list']) = Parameters.Par(:,i); 
end

mkdir(outPath);
Split = strsplit(outPath, filesep);
if isempty(Split{end})
    folderName = Split{end-1};
else
    folderName = Split{end};
end
save(fullfile(outPath, ['dico_', folderName, '.mat']), 'dictionary');
save(fullfile(outPath, ['prop_', folderName, '.mat']), 'Properties');

function interpolated = getAcqEchoes(signals, Tacq)
% Interpolates the given signals to match acquisition times from GIN
% MGEFIDSE acquisitions 

% hardcoded echo times from acquired data
acqTimes =  [ 3.0000, 6.3000, 9.6000, 12.9000, 16.2000, 19.5000, 22.8000, 26.1000, 33.1876, 36.4876, 39.7876, 43.0876, 46.3876, 49.6876, ...
    52.9876, 56.2876, 59.5876, 62.8876, 66.1876, 69.4876, 72.7876, 76.0876, 79.3876, 82.6876, 85.9876, 89.2876, 92.5876, 95.8876, 99.1876, ...
    102.4876, 105.7876, 109.0876 ];

% double transposition to match interpolation shape requirement
interpolated = interp1(Tacq, signals', acqTimes)';

end