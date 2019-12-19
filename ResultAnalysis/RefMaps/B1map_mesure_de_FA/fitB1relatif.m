function [signal_out] = fitB1relatif(FAth,B)
%FITB1RELATIF sin( facteur*FA_th + offset). FAth et offset en °
%   B(1)=facteur
%   B(2)=offset
facteur=B(1);
offset=B(2);
signal_out=sin((FAth*facteur+offset)*pi/180);

end

