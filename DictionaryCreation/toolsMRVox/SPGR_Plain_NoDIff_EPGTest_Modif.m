function [s, sd] = SPGR_Plain_NoDiff_EPGTest_Modif(N, T1test, T2test, dftest, RFalphatrain, TRtrain)

%% Test MR Fingerprinting with SPGR simulations (EPG):
% (1) Create trains of parameters (2) Show 1 signal evolution

%% Init Parameters
% N=200;          % Number of time repetitions in fingerprint
% T1test=0.779;   % T1 value for Signal Test (in sec)
% T2test=0.045;   % T2 value for Signal Test (in sec)
% dftest=0;       % Frequency shift for Signal Test (in Hz)
Nstates = 200;	% Number of states to simulate (easier to keep constant if showing state evolution)

%% Flip Angle train
% alpha=10;       % Flip Angle (in deg)
% RFalphatrain=alpha*ones(1,N);   %Constant

%% RF phase train
RFphasetrain=0*ones(1,N);
flipphaseincr = 0;  % Phase increment 0 to start.
% flipphaseincrincr = 117;    % Phase increment-increment of 117 deg.
flipphaseincrincr = 0;

for k = 1:N
    RFphasetrain(k) = RFphasetrain(k) + pi/180*(flipphaseincr); % Incr. phase
    flipphaseincr = flipphaseincr + flipphaseincrincr;  % Increment increment!
end

%% TR train
% TR=6*1e-3;  % Repetition Time (s)
% TRtrain=TR*ones(1,N);   %Constant

%% Initialize
P = zeros(3,Nstates);   % State matrix
P(3,1)=1;   % Equilibrium magnetization.

s = zeros(1,N); % Signal 
sd = zeros(1,N); % Phase demodulated signal

for k = 1:N
    P = epg_rf(P,pi/180*RFalphatrain(k),RFphasetrain(k));   %  RF pulse
    
    P = epg_grelax(P,T1test,T2test,TRtrain(k)/2,0,0,1,1);   %  Relaxation.
    
    s(k) = P(1,1);  % Signal is F0 state.
    sd(k) = s(k)*exp(-i*RFphasetrain(k));   % Phase-Demodulated signal.
    
    P = epg_grelax(P,T1test,T2test,TRtrain(k)/2,1,0,0,1);   % Spoiler gradient, relaxation
end

%% Visu
% figure();
% magphase(sd);
%
% figure();
% magphase(s);
