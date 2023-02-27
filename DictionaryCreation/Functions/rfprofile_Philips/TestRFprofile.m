
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

%% Generate Gaussian sinc unit pulse
close all
clear all
dt=.004;
tip=45;
tc=5;
t = -tc : dt : tc; 
tplot = t;

[y1,yq,ye] = gauspuls(t,3,0.8); 

plot(t,y1); hold on
[y2,yq,ye] = gauspuls(t,0.7,5); 
plot(t,y2);hold on

signal = (y1+y2)/2;
plot(t, (y1+y2)/2);hold on
plot(t, ones(1,2501)*0.07, 'b'); hold on
plot(t, ones(1,2501)*-0.14, 'b'); hold on
legend("s1", 's2', 'mean', '0.07', '-0.14')
grid
% 
rf = signal;
rf = rf/(sum(rf)*dt)*(tip/360)/42.58;	% scale for desired flip.

rfp = fftshift(fft(fftshift(rf)))*dt*42.58;		% RF profile, scaled
f = ([1:length(rfp)]-length(rfp)/2)/length(rfp)/dt;	% kHz

figure(1);		% Plot the RF and profile.
subplot(2,1,1);
plot(tplot,rf); xlabel('time(ms)'); ylabel('B1 (mT)');
subplot(2,1,2);
freqplot = find(abs(f)<5);			% Plot only range of freqs.
plot(f,abs(rfp)*360);	
title('Small Tip Approximation'); ylabel('Flip (deg)'); xlabel('Freq (kHz)');
%% Generate Gaussian sinc unit pulse
close all
clear all
dt=1e-8;
tip=45;
tc=0.25e-5;
t = -tc : dt : tc; 
tplot =t;
[y1,yq,ye] = gauspuls(t,2500e3,0.8); 

% plot(t,y1); hold on
[y2,yq,ye] = gauspuls(t,550e3,5); 
% plot(t,y2);hold on

signal = (y1+y2)/2;
plot(t, (y1+y2)/2);hold on
plot(t, ones(1,501)*0.07, 'b'); hold on
plot(t, ones(1,501)*-0.14, 'b'); hold on
legend('mean', '0.07', '-0.14')
grid


% 
rf = signal;
rf = rf/(sum(rf)*dt)*(tip/360)/42.58;	% scale for desired flip.

rfp = fftshift(fft(fftshift(rf)))*dt*42.58;		% RF profile, scaled
f = ([1:length(rfp)]-length(rfp)/2)/length(rfp)/dt;	% kHz

figure(1);		% Plot the RF and profile.
subplot(2,1,1);
plot(tplot,rf); xlabel('time(ms)'); ylabel('B1 (mT)');
subplot(2,1,2);
freqplot = find(abs(f)<5);			% Plot only range of freqs.
plot(f,abs(rfp)*360);	
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
% ms = snc.*(0.54+0.46*cos(pi*x));
ms = snc*gausswin(n,m);
ms = ms*4*m/(n);
end
