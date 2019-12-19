function [ Y ] = fitT1( TRlist, B )
%FITT1 Y(TR)=A*(1-exp(-TR/T1))+cte
%   B=[A cte T1];
%   TRlist=liste des TR

A=B(1);
cte=B(2);
T1=B(3);

Y=A*(1-exp(-TRlist/T1))+cte;
reshape(Y,[length(TRlist),1]);

end

