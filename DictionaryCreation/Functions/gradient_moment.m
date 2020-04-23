function [g0,g1] = gradient_moment(g,dt,varargin)
% function [g0,g1] = gradient_moment(g,dt[,t0])
% Calculate first and second order gradient moments from a gradient
% waveform. 
%
% Input parameters:
%   g  -  Vector of gradient values. The units used for g determine the
%         units of the output.
%   dt -  Vector of gradient durations in seconds. Same size as g.
%   t0 -  Time offset (in seconds) from the time origin (time the position
%         of spins has last been updated) to the beginning of the first
%         sample interval. Optional parameter with default value: 0 
%
% Output parameters:
%   g0 -  0-th order gradient moment in gradient units times seconds. If
%         gradient values provided are in mT/m, this is mT.s/m.
%   g1 -  1st order gradient moment in gradient units times square seconds. 
%         If gradient values provided are in mT/m, this is mT.s^2/m.
%
% These gradient moments can then be used to calculate dephasing due to
% gradients.
% phi = integral[omega(t) dt]
%     = integral[gamma*G(t)*x(t) dt]
% x(t) = x0 + t*v, with x0,v constant ->
% phi = gamma*x0*integral[G(t) dt] + gamma*v*integral[G(t)*t dt]
%     = gamma*x0*g0 + gamma*v*g1
%
% x0 is the position of spins at t=0. g1 depends on the time origin and
% needs to be consistent with the spin position used in the phase
% calculations.
%
% Written by Jan Warnking, Grenoble Institut des Neurosciences,
% Centre de Recherche INSERM U1216 - UJF-CEA-CHU, Grenoble, France 
% Last modified - 10/2016

% TODO: Add effect of gradient ramps??

% calculate time offset at the beginning of each sample interval
if nargin>2
    t0 = varargin{1}(1); % this should be a scalar
else
    t0 = 0;
end
t0 = cumsum([t0;dt(:)]);
t0 = reshape(t0(1:end-1),size(dt));

% Assume constant gradients during intervals. No gradient ramps
% Zeroth orer moment
g0 = sum(g.*dt); % as simple as that

% First order moment
% g1 = Integral[G(t)*t dt] from t0 to t0+dt
%    = G * Integral[t dt] from t0 to t0+dt
%    = G * (t0*dt + dt^2/2)
g1 = sum(g .* (t0.*dt + dt.^2/2));

end
