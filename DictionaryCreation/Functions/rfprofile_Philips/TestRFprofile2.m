
%% Generate RF profile form sinc pulse
clear;

dt = .004;		% ms, sample spacing
tip = 45;		% desired tip angle
t = [-5:dt:5];		% extended time period to get 100 Hz spectral res.
tplot = find(abs(t)<=1); % only work on central 2 ms
rf=0*t;			% allocate RF
rf(tplot) = msinc(length(tplot),3);	% put RF pulse in central part.
rf = rf/(sum(rf)*dt)*(tip/360)/42.58;	% scale for desired flip.

rfp = fftshift(fft(fftshift(rf)))*dt*42.58;		% RF profile, scaled
f = ([1:length(rfp)]-length(rfp)/2)/length(rfp)/dt;	% kHz

figure(1);		% Plot the RF and profile.
subplot(2,1,1);
plot(t(tplot),rf(tplot)); xlabel('time(ms)'); ylabel('B1 (mT)');
subplot(2,1,2);
freqplot = find(abs(f)<5);			% Plot only range of freqs.
plot(f(freqplot),abs(rfp(freqplot))*360);	
title('Small Tip Approximation'); ylabel('Flip (deg)'); xlabel('Freq (kHz)');

%% Generate sinc hamming unit pulse

% h = msinc(n,m)
%
%  Returns a hamming windowed sinc of length n, with m sinc-cycles,
%  which means a time-bandwidth of 4*m
%

%  written by John Pauly, 1992
%  (c) Board of Trustees, Leland Stanford Junior University

function ms = msinc(n,m)

x = [-n/2:(n-1)/2]/(n/2);
snc = sin(m*2*pi*x+0.00001)./(m*2*pi*x+0.00001);
ms = snc.*(0.54+0.46*cos(pi*x));
ms = ms*4*m/(n);

%% Generate Gaussian sinc unit pulse
tc=0.25e-5;
t = -tc : 1e-8 : tc; 
[yi,yq,ye] = gauspuls(t,1800e3,1.2); 

plot(t,yi)
legend('Inphase','Quadrature','Envelope')
