function [ parameters ] = prepdico_v9_gradmom1( Sequence, PulseProfile) % FA, TE, TR, Ncycles, Npulses, Nspins, SliceThickness_th,pos,p0)
%PREPDICO Summary of this function goes here
%   Detailed explanation goes here

%% Units
% Try to work (almost) entirely in SI units
%  - distances in mm
%  - field strength in T
%  - time in s
%  - gamma in rad/(s.T)
%  - gradients in T/mm (!)

%% Param�tres de s�quence/IRM
% Param�tres IRM
parameters=struct('gamma',2*pi*42.5764e6); % rad/(s.T)
parameters.PVM_GradCalConst=28933.3; % Hz/mm

parameters.Nspins=PulseProfile.Nspins;
parameters.SliceThickness=PulseProfile.SliceThickness_th_mm;
parameters.pos=PulseProfile.positions_mm;

% Dur�es PV
parameters.dReph=281e-6;  % s
parameters.dAmp=25e-6;    % s
parameters.p0=PulseProfile.p0; % s
parameters.dRise=140e-6;  % s
parameters.dRamp=110e-6;  % s

% Convert TE and TR to seconds
TE = Sequence.TE/1000;
TR = Sequence.TR/1000;

%     parameters.TEDelay=TE-2*parameters.dReph-parameters.dAmp-parameters.p0;
parameters.TEDelay=TE-parameters.dReph-parameters.p0/2; % ------------------------------------------------------------------------------------------

% Gradients PV
parameters.grad_percent=2*pi*parameters.PVM_GradCalConst/parameters.gamma/100 ; % T/(mm.%)

% Calculate gradient amplitudes, depending on spoiler strength, slice
% thickness, time-bandwidth product of the RF pulse etc.
% Temporarily use units of % gradient strength for consistency with PPG
TBP = 4; % ??  % time-bandwidth product of RF pulse
Gs = 2*pi*TBP/(parameters.grad_percent*parameters.p0*parameters.gamma*parameters.SliceThickness);
% Gs = 0; % = 13.92;   % gradient amplitude in '%'
parameters.g0 = +Gs; % 3.46 % gradient amplitude in '%'
parameters.g1 = -Gs*(parameters.p0/2+parameters.dAmp)/parameters.dReph; % -13.92; % de(re-)phasing gradient. Half the integral of slice-select gradient
parameters.g2 = 2*pi*Sequence.Ncycles/(parameters.grad_percent*parameters.dReph*parameters.gamma*parameters.SliceThickness);%+ -Gs*(parameters.p0/2)/parameters.dReph PRIS EN COMPTE DANS LE SLICEPROFILE

%% D�finition de la s�quence de gradients/RF/dt
Gpre0  = zeros(1,Sequence.Npulses);
Gpre1  = zeros(1,Sequence.Npulses);
Gpost0 = zeros(1,Sequence.Npulses);
Gpost1 = zeros(1,Sequence.Npulses);

for k=1:Sequence.Npulses
    % Gradients between RF and acquisition
    grad    =  0;%parameters.g0*parameters.grad_percent; % second half of RF with Gs PRIS EN COMPTE DANS LE SLICEPROFILE 
    grad(2) =  parameters.g2*parameters.grad_percent; % spoiler (sans slice rephase car pris en compte dans le slice profile)
    dt      =  parameters.p0/2;
    dt(2)   =  parameters.dReph;
    % no need to add zero gradients until TE, they don't impact phase
    [Gpre0(k),Gpre1(k)] = gradient_moment(grad,dt,0); % calculate gradient moments with zero time-offset
    
    % Gradients between acquisition and next RF
    grad    =  0;                                     % fill time to get to TR. Need to include this for first-order moment
    grad(2) =  0;%parameters.g1*parameters.grad_percent; % slice dephasing PRIS EN COMPTE DANS LE SLICEPROFILE
    grad(3) =  0;%parameters.g0*parameters.grad_percent; % dAmp + first half of RF with Gs PRIS EN COMPTE DANS LE SLICEPROFILE
    dt      =  (TR(k)-TE(k))-parameters.dReph-parameters.dAmp-parameters.p0/2;
    dt(2)   =  parameters.dReph;
    dt(3)   =  parameters.p0/2+parameters.dAmp;
    % calculate gradient moments with time-offset of TE
%     [Gpost0(k),Gpost1(k)] = gradient_moment(grad,dt,TE(k));  CA FAIT ZERO DU COUP MAIS A GARDER CAR DANS LA v10 CE N'EST PAS NUL !
end

parameters.Gpre0=Gpre0; clear Gpre0
parameters.Gpre1=Gpre1; clear Gpre1
parameters.Gpost0=Gpost0; clear Gpost0
parameters.Gpost1=Gpost1; clear Gpost1
parameters.TE=TE; %clear TE ===================== J'ai besoin de TE, TR, FA, Ncycles, Npulses dans beaucoup d'autres de mes codes donc je veux bien les garder si possible
parameters.TR=TR; %clear TR

%% AJOUT 31/08/2016 %%
parameters.n_positions  = numel(parameters.pos);
parameters.pos          = reshape(parameters.pos,[1 parameters.n_positions]);
parameters.rfrot        = reshape(Sequence.FA,[1,numel(Sequence.FA)]);
parameters.min_pos_init = min(parameters.pos);
parameters.max_pos_init = max(parameters.pos);

end


