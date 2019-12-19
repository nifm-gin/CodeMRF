function [ FA, TE, TR, m0, Ncycles ] = gensequence( Npulses )

%     %% FA
%     a1=abs((15+65*rand));
%     a2=abs((15+65*rand));
%     a3=abs((15+65*rand));
%     a4=abs((15+65*rand));
%     a5=abs((15+65*rand));
%     a6=abs((15+65*rand));
%     a7=abs((15+65*rand));
%     a8=abs((15+65*rand));
%     a9=abs((15+65*rand));
%     a10=abs((15+65*rand));
a1=55;
a2=25;
a3=55;
a4=25;
a5=55;
a6=25;


    
%     Nrf=floor(Npulses/5);
Nrf=250;
    waittime=50;
    
%     FA=ones(1,Npulses+4*waittime);
FA=ones(1,Npulses);
    for k=1:Nrf
%         FA(k)=(k)/Nrf*a1;%sin(k*pi/Nrf)*a1;
%         FA(Nrf+waittime+k)=abs(sin((k)*pi/(Nrf+10)))*a2;
%         FA(2*(Nrf+waittime)+k)=abs(cos(k*pi/(Nrf+10)))*a3; 
%         FA(3*(Nrf+waittime)+k)=abs(sin((k)*pi/(Nrf+10)))*a4;
%         FA(4*(Nrf+waittime)+k)=(k)/Nrf*a5;%sin(k*pi/Nrf)*a5;
%         FA(5*(Nrf+waittime)+k)=abs(sin((k)*pi/(Nrf+10)))*a6;
%         FA(6*(Nrf+waittime)+k)=abs(cos((k)*pi/(Nrf+10)))*a7;
        FA(k)=sin(k*pi/Nrf)*a1+10+5*rand;
        FA(Nrf+waittime+k)=sin(k*pi/Nrf)*a2+10+5*rand;
        FA(2*(Nrf+waittime)+k)=sin(k*pi/Nrf)*a3+10+5*rand; 
        FA(3*(Nrf+waittime)+k)=sin(k*pi/Nrf)*a4+10+5*rand;
        FA(4*(Nrf+waittime)+k)=sin(k*pi/Nrf)*a5+10+5*rand;
        FA(5*(Nrf+waittime)+k)=sin(k*pi/Nrf)*a6+10+5*rand;
%         FA(6*(Nrf+waittime)+k)=sin(k*pi/Nrf)*a7;
    end
    for k=1:waittime
        FA(Nrf+k)=0;
        FA(2*Nrf+waittime+k)=0;
        FA(3*Nrf+2*waittime+k)=0;
        FA(4*Nrf+3*waittime+k)=0;
        FA(5*Nrf+4*waittime+k)=0;
        FA(6*Nrf+5*waittime+k)=0;
    end
    
%    FA=90*perlin_mrfv3(Npulses/20,20); % ---------------------------------- A VIRER APRES
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    FA = round(FA);
    FA=FA(1:Npulses)*pi/180;
  FA(2:2:end)=-FA(2:2:end);
  
%   FA(2:4:end)=-FA(2:4:end);
%   FA(3:4:end)=1i*FA(3:4:end);
%   FA(4:4:end)=-1i*FA(4:4:end);
    clear a1 a2 a3 a4 a5 a6 a7 k
    
    
   
    
    %% TR
    TR=15+15*perlin_mrfv3(Npulses/50,50);
%   TR(2*(Nrf+waittime)+(1:Nrf))=50;    

% TR(1:Nrf)=15+15*perlin_mrfv3(Nrf/20,20);
% TR((Nrf+1):2*Nrf)=15+250*perlin_mrfv3(Nrf/20,20);
% TR((2*Nrf+1):3*Nrf)=15+15*perlin_mrfv3(Nrf/20,20);
% TR((3*Nrf+1):4*Nrf)=15+250*perlin_mrfv3(Nrf/20,20);
% TR((4*Nrf+1):5*Nrf)=15+15*perlin_mrfv3(Nrf/20,20);
TR=TR';
    %% TE
%   TE=10*ones(size(TR)) ;
%     TE=8+5*perlin_mrfv3(Npulses/50,50);
TE=TR/2;
%     TE=min(TR/2,7.5+10*perlin_mrfv3(Npulses/20,20));

    clear Nrf waittime
    
    %% Dephasing
    Ncycles=4;
    
    
    %% Preparation
    m0=[0 0 1];


figure('Name','MRI Sequence','units','normalized','outerposition',[0 1/2 1/2 1/2])

subplot(2,1,1)
plot(FA*180/pi);
title('Flip angles')
% xlabel('TR index')
ylabel('Flip angle (�)')

subplot(2,1,2)
plot(TR);
hold on
plot(TE)
title('Repetition times and echo times')
% xlabel('TR index')
ylabel('TR (blue) and TE (red) (ms)')

set(gcf,'color','w')


end

