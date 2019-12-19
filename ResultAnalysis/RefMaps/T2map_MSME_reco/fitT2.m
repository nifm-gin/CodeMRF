function [ Y ] = fitT2( TElist, B )
%FITT1 Y(TR)=A*exp(-TE/T2)+cte
%   B=[A cte T2];
%   TElist=liste des TE

A=B(1);
cte=B(2);
T2=B(3);

Y=A*exp(-TElist/T2)+cte;
reshape(Y,[length(TElist),1]);

end

