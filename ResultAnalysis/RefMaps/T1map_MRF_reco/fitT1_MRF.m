function [ signal_out ] = fitT1_MRF( TI,B )
%FITB1RELATIF_SANSOFFSET Summary of this function goes here
%   Detailed explanation goes here
global B1
T1=B(1);
S0=B(2);
% cte=B(3);
% signal_out=cte + S0.*abs(1-2.*exp(-TI/T1));
signal_out= S0.*abs(sin(B1*pi/2)*(1-2.*exp(-TI/T1)));

end

