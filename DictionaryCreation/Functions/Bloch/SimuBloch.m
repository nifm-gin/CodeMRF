function SignalEvol=SimuBloch(RFalphatrain ,RFphasetrain ,TRtrain ,TEtrain, T1, T2, df, gradDur, gradAmp, Shim, spoilType, invPulse)
% Simulate fast GRE sequence with options of gradients and custom RF shapes
% alpha in rad, TR in sec, T1 and T2 in sec, df in Hz (can be [-200:200]), Tcrush in s, Ampcrush in Gauss

% tic
%	--- Setup parameters ---
N=numel(RFalphatrain);
% Trf = 0.00001; % 10 us "hard" RF pulse.
% Trf = 10 * 1e-6;
Trf = 1e-3; %as in MRVox
gamma = 4258; % Hz/G.
x =-2:.04:2; % isochromats so we can simulate effects of gradients x =-2:.02:2
% x = 0;
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
for n=1:N
    %%%%%% first half of TR %%%%%%
    t = [Trf, gradDur(n)+Trf, TEtrain(n)]; % 3 time segments : RF pulse - spoil - precession
    g1 = [Shim, Shim + gradAmp(n)*sBefore, Shim]; %[Shim Shim] Shim + maybe Spoiler
    b1 = [(RFalphatrain(n)/Trf/gamma/2/pi)*exp(1i*RFphasetrain(n)), 0, 0]; % RF pulse on - off - off [G]
    
    [mx,my,mz] = bloch(b1,g1,t,T1,T2,df,x,0,mx,my,mz); % MEX function
    % Acq
    SignalEvol(n,:) = mean(mx)+1i*mean(my); % In-plane signal at TE
    
    %%%%%% Rest of TR %%%%%%
    %% Acq - Precess - Spoil - (Pulse) %%
%     t2 = [(TRtrain(n)-TEtrain(n))-Tcrush(n) (TRtrain(n)-TEtrain(n))];
%     g2 = [Shim, Shim + Ampcrush(n)*sAfter]; %[Shim Shim] % Shim+Cruhers.

    %% Acq - Spoil - Precess - (Pulse) %%
    t2 = [gradDur(n), TRtrain(n)-TEtrain(n)];
    g2 = [Shim + gradAmp(n)*sAfter, Shim];
    
    b1 = [0 0];	% RF Gauss.
    [mx,my,mz] = bloch(b1,g2,t2,T1,T2,df,x,0,mx,my,mz);  
end

