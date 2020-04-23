function [s, sd] = EPG(nPulses, T1, T2, df, RFalphatrain, TRtrain, TEtrain, spoilType, invPulse)
% EPG computation, using functions written by B. Hargreaves
% This function simulates a single signal using the parameters given
% -------------------------------------------------------------------------
% - nPulses: number of successive RF pulses
% - T1: T1 value (s)
% - T2: T2 value (s)
% - df: off resonance frequency (Hz), positive or negative
% - RFalphatrain: flip angle list (rad), must have nPulses elements
% - TRtrain: Repetition time list (s), must have nPulses elements
% - TEtrain: Echo (acquisition) time list (s), must have nPulses elements
% - spoilType: type of spoiling: "FID" = pulse- Acq - spoil, "Echo" = pulse - spoil - Acq, "bSSFP" = no spoiling
% - invPulse: magnetization inversion (M0 = [0,0,-1]) if 1
% 
% - s: signal
% - sd: phase demodulated signal
% -------------------------------------------------------------------------

nStates = 200;	% Number of states to simulate (easier to keep constant if showing state evolution)

%% RF phase train
RFphasetrain=0*ones(1,nPulses);
flipphaseincr = 0;  % Phase increment 0 to start.
% flipphaseincrincr = 117;    % Phase increment-increment of 117 deg.
flipphaseincrincr = 0;

for k = 1:nPulses
    RFphasetrain(k) = RFphasetrain(k) + pi/180*(flipphaseincr); % Incr. phase
    flipphaseincr = flipphaseincr + flipphaseincrincr;  % Increment increment!
end


%% Initialize
P = zeros(3, nStates);   % State matrix
switch invPulse
    case 1
        P(3,1) = -1; % Equilibrium magnetization.
    otherwise     
        P(3,1) = 1;   % Equilibrium magnetization.
end

s = zeros(1,nPulses); % Signal 
sd = zeros(1,nPulses); % Phase demodulated signal

switch spoilType
    case 'Echo' % Pulse - SPOILER - Acq
        spoilBeforeAcq = 1;
        spoilAfterAcq = 0;
     case 'FID' % Pulse - Acq - SPOIL
        spoilBeforeAcq = 0;
        spoilAfterAcq = 1;
    case 'bSSFP'
        spoilBeforeAcq = 0;
        spoilAfterAcq = 0;
    otherwise
        error('Sequence.spoilType must be "FID", "Echo" of "bSSFP"')      
end

for k = 1:nPulses
    P = EPG_rf(P,RFalphatrain(k),RFphasetrain(k));   %  RF pulse

    P = EPG_grelax(P,T1,T2,TEtrain(k),0,0,spoilBeforeAcq,1, df * ~spoilBeforeAcq);  %  Relaxation with spoiler -> df unaccounted

    s(k) = P(1,1);  % Signal is F0 state.
    sd(k) = s(k)*exp(-1i*RFphasetrain(k));   % Phase-Demodulated signal.

    P = EPG_grelax(P,T1,T2,TRtrain(k)-TEtrain(k),1,0,spoilAfterAcq,1, df * ~spoilAfterAcq);   % relaxation
end
