function [ Y ] = fitT1_avecB1( TRlist, B )
%FITT1 Y(TR)=A*(1-exp(-TR/T1))+cte
%   B=[A cte T1];
%   TRlist=liste des TR
global B1rel

A=B(1);
cte=B(2);
T1=B(3);
Y=A*sin(B1rel*pi/2)*(1-exp(-TRlist/T1))./(1-cos(B1rel*pi/2)*exp(-TRlist/T1))+cte;
reshape(Y,[length(TRlist),1]);

end

