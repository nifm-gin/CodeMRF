%%
clear Properties
clear dictionary

% flag to indicate if need to load a dico or json files
flagIsDico = 1;
dicoPath = 'DICO.mat';
% path to pre json
prePath = '/home/aurelien/Data/SeqComparison/Wang10k/2020-12-07_11-45-44-541_ModelPar_dico_Wang_dico.json'; 
% path to post json
postPath = '/home/aurelien/Data/SeqComparison/Wang10k/2020-12-07_11-45-44-541_ModelPar_dico_Post_Wang_dico.json';

% path to save the files
outPath = '/home/aurelien/Data/SeqComparison/Wang10k';
% combination of signals ('Ratio', 'Concat', 'Hybrid', 'Other')
comb = 'None';

%%
if flagIsDico
    load(dicoPath)
    Tacq = Dico.Tacq(1:end) * 1e3; % convert to ms
    MRSignals{1} = getAcqEchoes(abs(Dico.MRSignals{1}), Tacq, Dico.Sequence);
    MRSignals{2} = getAcqEchoes(abs(Dico.MRSignals{2}), Tacq, Dico.Sequence);
    Parameters = Dico.Parameters;
    clear Dico
else
    pre = loadjson(prePath);
    post = loadjson(postPath);
    Tacq = pre.Sequence.Tacq(1:end) * 1e3; % convert to ms

    MRSignals{1} = getAcqEchoes(abs(pre.MRSignals), Tacq, pre.Sequence);
    MRSignals{2} = getAcqEchoes(abs(post.MRSignals), Tacq, pre.Sequence);
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
    case 'Pre'
        dictionary = MRSignals{1};
    case 'None'
        dictionary.MRSignals{1} = MRSignals{1};
        dictionary.MRSignals{2} = MRSignals{2};
    case 'Other'
        % Implement here what you want
        warning('"Other" method must be implemented')
        dictionary = [];
    otherwise
        error("Please specify a combination ('Ratio', 'Concat', 'Hybrid', 'Other')")
end

nbParameters = numel(Parameters.Labels); %need to remove mandatory parameters (Id, RTry, Timer)
toKeep = true(1, nbParameters);

for i = 1:nbParameters
   if contains(Parameters.Labels{i}, 'Id') || contains(Parameters.Labels{i}, 'RTry') || contains(Parameters.Labels{i}, 'Timer') 
       toKeep(i) = 0;
   end
end

nbParameters = nnz(toKeep);
Parameters.Labels = Parameters.Labels(toKeep);
Parameters.Par = Parameters.Par(:, toKeep);

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

function interpolated = getAcqEchoes(signals, Tacq, Seq)
% Interpolates the given signals to match acquisition times from GIN
% MGEFIDSE acquisitions 
if nargin < 3
    Seq = [];
end

if isempty(Seq)
    % hardcoded echo times from acquired data
    acqTimes =  [ 3.0000, 6.3000, 9.6000, 12.9000, 16.2000, 19.5000, 22.8000, 26.1000, 33.1876, 36.4876, 39.7876, 43.0876, 46.3876, 49.6876, ...
        52.9876, 56.2876, 59.5876, 62.8876, 66.1876, 69.4876, 72.7876, 76.0876, 79.3876, 82.6876, 85.9876, 89.2876, 92.5876, 95.8876, 99.1876, ...
        102.4876, 105.7876, 109.0876 ];

else
    %% values used on GIN scanners
    tStart = 3;
    tInter = 3.3;
    tPulse = 7.0876;
    pulseTime = Seq.RF.exc.time(1:end) * 1e3;
    nPulse = numel(pulseTime);
    
    acqTimes = tStart;
    % Set gradient echo times (one every 3.3ms, jump 7.0876ms around a pulse
    for p = 2 : nPulse
        nAcq = fix((pulseTime(p) - acqTimes(end))/tInter);
        acqTimes = [acqTimes, acqTimes(end) + tInter * [1:nAcq-1]];
        acqTimes = [acqTimes, acqTimes(end) + tPulse];
    end
    % Continue sampling up to last echo
    lastEcho = 60;%Seq.TEacq(end) *1e3;
    nAcq = fix((lastEcho - acqTimes(end))/tInter);
    acqTimes = [acqTimes, acqTimes(end) + tInter * [1:nAcq]];
    
    % Keep sampling for 15 more points (as done in MGEFIDSE)
    nAcq = 15;
    acqTimes = [acqTimes, acqTimes(end) + tInter * [1:nAcq]];
    
    
end

% double transposition to match interpolation shape requirement
interpolated = interp1(Tacq, signals', acqTimes)';

end