function [s, sd] = EPG(nPulses, T1test, T2test, df, RFalphatrain, TRtrain, TEtrain, spoilTag, invPulse)

%% Test MR Fingerprinting with SPGR simulations (EPG):
% (1) Create trains of parameters (2) Show 1 signal evolution

%% Init Parameters
% N=200;          % Number of time repetitions in fingerprint
% T1test=0.779;   % T1 value for Signal Test (in sec)
% T2test=0.045;   % T2 value for Signal Test (in sec)
% dfTest=0;       % Frequency shift for Signal Test (in Hz)
nStates = 200;	% Number of states to simulate (easier to keep constant if showing state evolution)
% Nstates = N;

%% Flip Angle train
% alpha=10;       % Flip Angle (in deg)
% RFalphatrain=alpha*ones(1,N);   %Constant

%% RF phase train
RFphasetrain=0*ones(1,nPulses);
flipphaseincr = 0;  % Phase increment 0 to start.
% flipphaseincrincr = 117;    % Phase increment-increment of 117 deg.
flipphaseincrincr = 0;

for k = 1:nPulses
    RFphasetrain(k) = RFphasetrain(k) + pi/180*(flipphaseincr); % Incr. phase
    flipphaseincr = flipphaseincr + flipphaseincrincr;  % Increment increment!
end

%% TR train
% TR=6*1e-3;  % Repetition Time (s)
% TRtrain=TR*ones(1,N);   %Constant

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

switch spoilTag
    case 'v9' % Pulse - SPOILER - Acq
        for k = 1:nPulses
            P = epg_rf(P,pi/180*RFalphatrain(k),RFphasetrain(k));   %  RF pulse

            P = epg_grelax(P,T1test,T2test,TEtrain(k),0,0,1,1, 0);  %  Relaxation with spoiler -> df unaccounted

            s(k) = P(1,1);  % Signal is F0 state.
            sd(k) = s(k)*exp(-1i*RFphasetrain(k));   % Phase-Demodulated signal.

            P = epg_grelax(P,T1test,T2test,TRtrain(k)-TEtrain(k),1,0,0,1, df);   % relaxation
        end
        
    case 'v10' % Pulse - Acq - SPOIL
        for k = 1:nPulses
            P = epg_rf(P,pi/180*RFalphatrain(k),RFphasetrain(k));   %  RF pulse

            P = epg_grelax(P,T1test,T2test,TEtrain(k),0,0,0,1, df);   %  Relaxation 

            s(k) = P(1,1);  % Signal is F0 state.
            sd(k) = s(k)*exp(-1i*RFphasetrain(k));   % Phase-Demodulated signal.

            P = epg_grelax(P,T1test,T2test,TRtrain(k)-TEtrain(k),1,0,1,1, 0); % Relaxation with spoiler -> df unaccounted
        end
        
    otherwise
        error('Ambiguous spoiler position, please specify v9 or v10 in Seq.v9_v10 structure')      
end
%% Visu
% figure();
% magphase(sd);
%
% figure();
% magphase(s);
