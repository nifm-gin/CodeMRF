function [ signal_out ] = fitB1relatif_sansoffset( FA,facteur )
%FITB1RELATIF_SANSOFFSET Summary of this function goes here
%   Detailed explanation goes here

signal_out=sin((FA*facteur)*pi/180);

end

