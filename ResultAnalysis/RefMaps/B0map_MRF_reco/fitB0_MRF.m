function [ signal_out ] = fitB0_MRF( TE, df )
%FITB0 Summary of this function goes here
%   Detailed explanation goes here
signal_out=unwrap(mod(2*pi*df*TE+pi,2*pi)-pi );
%  signal_out=2*pi*df*TE/1000 ;
end

