function [dictionary, tF] = EpgOverlay(Properties, Sequence)
% Overlay function for EPG computation, using functions written by B. Hargreaves
% This function uses a parfor loop from Matlab Parallel Computing Toolbox
% -------------------------------------------------------------------------
% - Properties: structure containing physical properties of the simulated
% medium (T1, T2 etc.)
% - Sequence: structure containing sequence description (list of FA, TE, TR etc.)
%
% - dictionary = matrix nSignals * nPulses, complex double
% - tF = computation time measured by toc function
% -------------------------------------------------------------------------

% Putting lists in separate variables to avoid passing full
% structures to parfor
T1list = Properties.T1list;
T2list = Properties.T2list;
B1list = Properties.B1rellist;
dflist = Properties.dflist;
nP = Sequence.nPulses;
FA = Sequence.FA;
TR = Sequence.TR;
TE = Sequence.TE;
spoilType = Sequence.spoilType;

switch Sequence.m0(3)
    case 1
        invPulse = 0;
    case -1
        invPulse = 1;
end

% WIP - Temporary phase train at 0
RFphasestrain = zeros(1, nP);

dictionary = zeros(numel(T1list), nP);

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
        [dictionary(i,:), ~] = EPG(nP, T1list(i)*1e-3, T2list(i)*1e-3, dflist(i), FA.*B1list(i), TR*1e-3, TE*1e-3, spoilType, invPulse);
        parfor_progress;
    end
    parfor_progress(0);
    tF = round(toc(t));
    fprintf('\n'); fprintf('\n');
else
    % Serial for otherwise
    t = tic;
    for i = 1:numel(T1list)
        [dictionary(i,:), ~] = EPG(nP, T1list(i)*1e-3, T2list(i)*1e-3, dflist(i), FA.*B1list(i), TR*1e-3, TE*1e-3, spoilType, invPulse);
    end
    tF = round(toc(t));
end
end