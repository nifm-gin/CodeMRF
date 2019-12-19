clear all

flow_velocities=[0:10:200];

load(strcat('D:\MATLAB\MRF_v3_SliceProfile_flux\Création de dictionnaire\Pulse Profiles\Pulse d''inversion\pulseshape_InvPulse.mat'))
FA=180; % Flip angle in ° 
% pulseshape=pulseshape/100;
pulse_duration = p1; % duration of RF pulse in s
gamma = 2*pi*42.58e6; % gamma in rad/T.s
n_rf_samples = length(pulseshape);
sample_time = p1/n_rf_samples;
rf_amplitude_integral = sum(pulseshape)*sample_time;

grad = (GradCalConst/(gamma/2*pi))*SliceGrad*1e4; % (Hz/mm.1)/(Hz/T)*(%/100%)*1e4Gauss/T*10mm/cm --> Gauss/cm
grad = grad*ones(n_rf_samples,1);

T1 = Inf;
T2 = Inf;
% x_mm = f/(GradCalConst*SliceGrad/100);
x_mm=[-3:6/1740:3]; %--------------------------------------------------------------------------------------------------------------------------
% center = find(abs(x_mm) == min(abs(x_mm)),1);
plot_limits = 3;
idx_plot = find(abs(x_mm)<plot_limits);
positions_mm=x_mm(idx_plot);
n_pos=length(positions_mm);

    O = zeros(1,length(positions_mm));
    l = ones (1,length(positions_mm));
    Mx = [l;O;O];
    My = [O;l;O];
    Mz = [O;O;l];
% Rot=zeros(3,3,n_pos);

pulseshape_T = pulseshape*(FA*pi/180)/(gamma*rf_amplitude_integral); % RF pulse in T
pulseshape_gauss = pulseshape_T * 1e4;

for kv=1:length(flow_velocities)
    flow_velocity=flow_velocities(kv);
    kv
if flow_velocity==0
% [Mxx,Myx,Mzx] = sliceprofile(pulseshape_gauss,grad,sample_time,T1,T2,positions_mm,0,Mx);
% [Mxy,Myy,Mzy] = sliceprofile(pulseshape_gauss,grad,sample_time,T1,T2,positions_mm,0,My);
[Mxz,Myz,Mzz] = sliceprofile(pulseshape_gauss,grad,sample_time,T1,T2,positions_mm,0,Mz);
else
% [Mxx,Myx,Mzx] = sliceprofile_v(pulseshape_gauss,grad,sample_time,T1,T2,positions_mm,0,flow_velocity,Mx);
% [Mxy,Myy,Mzy] = sliceprofile_v(pulseshape_gauss,grad,sample_time,T1,T2,positions_mm,0,flow_velocity,My);
[Mxz,Myz,Mzz] = sliceprofile_v(pulseshape_gauss,grad,sample_time,T1,T2,positions_mm,0,flow_velocity,Mz);
end

% Matrice de rotation
% Rot(1,1,1:n_pos,kv)=Mxx;
% Rot(2,1,1:n_pos,kv)=Myx;
% Rot(3,1,1:n_pos,kv)=Mzx;
% 
% Rot(1,2,1:n_pos,kv)=Mxy;
% Rot(2,2,1:n_pos,kv)=Myy;
% Rot(3,2,1:n_pos,kv)=Mzy;
% 
% Rot(1,3,1:n_pos,kv)=Mxz;
% Rot(2,3,1:n_pos,kv)=Myz;
% Rot(3,3,1:n_pos,kv)=Mzz;

M0(:,:,kv)=[Mxz Myz Mzz]';
end
