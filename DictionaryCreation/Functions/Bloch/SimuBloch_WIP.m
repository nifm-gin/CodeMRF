function [SignalEvol, S] =SimuBloch(RFalphatrain ,RFphasetrain ,TRtrain ,TEtrain, T1, T2, df, gradDur, gradAmp, Shim, spoilType, invPulse, fov)
% Simulate fast GRE sequence with options of gradients and custom RF shapes
% alpha in rad, TR in sec, T1 and T2 in sec, df in Hz (can be [-200:200]),
% Tcrush in s, Ampcrush in T/m, converted to G/cm for C function

%	--- Setup parameters ---
N=numel(RFalphatrain);
% Trf = 0.00001; % 10 us "hard" RF pulse.
% Trf = 10 * 1e-6;
Trf = 1e-3; %as in MRVox
gradAmp = gradAmp * 1e2; % Conversion from T/m to G/cm
gamma = 4258; % Hz/G.
numPos = 1000;
x = linspace(-fov/2, fov/2, numPos); % positions in m
x = x * 1e2; % positions in cm for C function
% x =-2:.04:2; % isochromats so we can simulate effects of gradients x =-2:.02:2

switch spoilType
    case 'Echo'
        sBefore     = 1;
        sAfter      = 0;
    case 'FID'
        sBefore     = 0;
        sAfter      = 1;
    case 'bSSFP'
        sBefore     = 0;
        sAfter      = 0;
    otherwise
        error('Sequence.spoilType must be "FID", "Echo" of "bSSFP"')
end

%   --- Initial Magnetization aligned with z axis ---
mx=zeros(numel(x),numel(df));
my=zeros(numel(x),numel(df));
if invPulse
    mz = -1 * ones(numel(x),numel(df));
else
    mz = ones(numel(x),numel(df));
end

%	--- Signal Evolution ---
SignalEvol=zeros(N,numel(df));
% S = zeros(3,N);
for n=1:N
    % t in bloch is either the duration of the intervals, or their end-time
    % (in the latter case, monotonically increasing)
    
    %%%%%% first half of TR %%%%%%
    t = [Trf, gradDur(n)+Trf, TEtrain(n)]; % 3 time segments : RF pulse - spoil - precession
    % here it is the end time
    g1 = [Shim, Shim + gradAmp(n)*sBefore, Shim]; %[Shim Shim] Shim + maybe Spoiler
    b1 = [(RFalphatrain(n)/Trf/gamma/2/pi)*exp(1i*RFphasetrain(n)), 0, 0]; % RF pulse on - off - off [G]
    
    [mx,my,mz] = bloch(b1,g1,t,T1,T2,df,x,0,mx,my,mz); % MEX function
    % Acq
    SignalEvol(n,:) = mean(mx)+1i*mean(my); % In-plane signal at TE
%     S(:,n) = [mx(1), my(1), mz(1)];
    %%%%%% Rest of TR %%%%%%
    %% Acq - Precess - Spoil - (Pulse) %%
%     t2 = [(TRtrain(n)-TEtrain(n))-Tcrush(n) (TRtrain(n)-TEtrain(n))];
%     g2 = [Shim, Shim + Ampcrush(n)*sAfter]; %[Shim Shim] % Shim+Cruhers.

    %% Acq - Spoil - Precess - (Pulse) %%
    t2 = [gradDur(n), TRtrain(n)-TEtrain(n)]; % here it is the end time
    g2 = [Shim + gradAmp(n)*sAfter, Shim];
    
    b1 = [0 0];	% RF Gauss.
    [mx,my,mz] = bloch(b1,g2,t2,T1,T2,df,x,0,mx,my,mz);  
end

