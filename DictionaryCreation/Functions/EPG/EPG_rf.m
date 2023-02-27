%
%function [FpFmZ,RR] = epg_rf(FpFmZ,alpha,phi)
%	Propagate EPG states through an RF rotation of 
%	alpha, with phase phi (both radians).
%	
%	INPUT:
%		FpFmZ = 3xN vector of F+, F- and Z states.
%
%       OUTPUT:
%               FpFmZ = Updated FpFmZ state.
%		RR = RF rotation matrix (3x3).
%
%	SEE ALSO:
%		epg_grad, epg_grelax
%
%	B.Hargreaves.
%
function [FpFmZ,RR] = EPG_rf(FpFmZ,alpha,phi)

% -- From Weigel at al, JMR 205(2010)276-285, Eq. 8.

if (abs(alpha)>2*pi) warning('epg_rf:  Flip angle should be in radians!'); end

if (nargin < 3) warning('Rotation axis not specified - assuming -My'); 
	phi=-pi/2; 
end

sinAlpha = sin(alpha);
sinHalfAlpha = sin(alpha/2);
cosHalfAlpha = cos(alpha/2);

RR = [cosHalfAlpha^2,                   exp(2*1i*phi)*sinHalfAlpha^2,   -1i*exp(1i*phi)*sinAlpha;
      exp(-2*1i*phi)*sinHalfAlpha^2,     cosHalfAlpha^2,                1i*exp(-1i*phi)*sinAlpha;
      -1i/2*exp(-1i*phi)*sinAlpha,        1i/2*exp(1i*phi)*sinAlpha,       cos(alpha)];

FpFmZ = RR * FpFmZ;


