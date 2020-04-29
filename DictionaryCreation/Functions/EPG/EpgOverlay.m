function [dictionary, tF, dictionarySD] = EpgOverlay(Properties, Sequence)
% Overlay function for EPG computation, using functions written by B. Hargreaves
% This function uses a parfor loop from Matlab Parallel Computing Toolbox
% -------------------------------------------------------------------------
% - Properties: structure containing physical properties of the simulated
% medium (T1, T2 etc.)
% - Sequence: structure containing sequence description (list of FA, TE, TR etc.)
%
% - dictionary = matrix nSignals * nPulses, complex double
% - tF = computation time measured by toc function
% - phase demodulated dictionary = matrix nSignals * nPulses, complex double
% -------------------------------------------------------------------------

% Putting lists in separate variables to avoid passing full
% structures to parfor
T1list = Properties.T1list *1e-3;
T2list = Properties.T2list *1e-3;
B1list = Properties.B1rellist;
dflist = Properties.dflist;
nP = Sequence.nPulses;
FA = Sequence.FA;
Phi = Sequence.Phi;
TR = Sequence.TR *1e-3;
TE = Sequence.TE *1e-3;
spoilType = Sequence.spoilType;

switch Sequence.m0(3)
    case 1
        invPulse = 0;
    case -1
        invPulse = 1;
end

dictionary = zeros(numel(T1list), nP);
dictionarySD = zeros(numel(T1list), nP);
% parfor if nSignals > nWorkers
ps = parallel.Settings;
if numel(T1list) > ps.SchedulerComponents.NumWorkers
    if isempty(gcp)
        delete(gcp('nocreate'))
        parpool;
    end
    t = tic;
    parfor_progress(numel(T1list));
    parfor i = 1:numel(T1list)
        [dictionary(i,:), dictionarySD(i,:)] = EPG(nP, T1list(i), T2list(i), dflist(i), FA.*B1list(i), Phi, TR, TE, spoilType, invPulse);
        parfor_progress;
    end
    parfor_progress(0);
    tF = round(toc(t));
    fprintf('\n'); fprintf('\n');
else
    % Serial for otherwise
    t = tic;
    for i = 1:numel(T1list)
        [dictionary(i,:), dictionarySD(i,:)] = EPG(nP, T1list(i), T2list(i), dflist(i), FA.*B1list(i), Phi, TR, TE, spoilType, invPulse);
    end
    tF = round(toc(t));
end
end