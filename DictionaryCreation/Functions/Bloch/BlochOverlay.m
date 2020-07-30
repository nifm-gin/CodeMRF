function [dictionary, tF] = BlochOverlay(Properties, Sequence, gradAmp, gradDur, fov)
% Overlay function for Bloch computation, using functions written by B. Hargreaves
% This function uses a parfor loop from Matlab Parallel Computing Toolbox
% -------------------------------------------------------------------------
% - Properties: structure containing physical properties of the simulated
% medium (T1, T2 etc.)
% - Sequence: structure containing sequence description (list of FA, TE, TR etc.)
% - gradAmp: spoiling gradient amplitude (T/m)
% - gradDur: spoiling gradient duration (s)
% - fov = field of view (m), used to compute isochromat positions
%
% - dictionary = matrix nSignals * nPulses, complex double
% - tF = computation time measured by toc function
% -------------------------------------------------------------------------
if nargin < 5
    fov = 256e-6; % m
end
if nargin < 4
    gradAmp = 0.02;  % T/m
    gradDur = 0.005; % s
end

% Putting lists in separate variables to avoid passing full
% structures to parfor
T1list = Properties.T1list * 1e-3;
T2list = Properties.T2list * 1e-3;
B1list = Properties.B1rellist;
dflist = Properties.dflist;
nP = Sequence.nPulses;
FA = Sequence.FA;
Phi = Sequence.Phi;
TR = Sequence.TR * 1e-3;
TE = Sequence.TE * 1e-3;
spoilType = Sequence.spoilType;

switch Sequence.m0(3)
    case 1
        invPulse = 0;
    case -1
        invPulse = 1;
end

% WIP - gradients
gradDur = gradDur * ones(1, nP);
gradAmp = gradAmp * ones(1,nP); 
Shim = 0;

dictionary = zeros(numel(T1list), nP);

% parfor if nSignals > nWorkers
% ps = parallel.Settings;
if numel(T1list) > 6; %ps.SchedulerComponents.NumWorkers
    if isempty(gcp)
        delete(gcp('nocreate'))
        parpool;
    end
    t = tic;
    parfor_progress(numel(T1list));
    parfor i = 1:numel(T1list)
        [dictionary(i,:)] = SimuBloch(B1list(i)*FA, Phi, TR, TE, T1list(i), T2list(i), dflist(i), gradDur, gradAmp, Shim, spoilType, invPulse, fov);
        parfor_progress;
    end
    parfor_progress(0);
    tF = round(toc(t));
    fprintf('\n'); fprintf('\n');
else
    % Serial for otherwise
    t = tic;
    for i = 1:numel(T1list)
        [dictionary(i,:)] = SimuBloch(B1list(i)*FA, Phi, TR, TE, T1list(i), T2list(i), dflist(i), gradDur, gradAmp, Shim, spoilType, invPulse, fov);
    end
    tF = round(toc(t));
end
dictionary = dictionary;
end