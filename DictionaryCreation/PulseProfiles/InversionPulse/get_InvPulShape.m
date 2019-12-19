[~, pathname] = uigetfile('*.*', 'Choisir le fichier method contenant la forme de pulse souhaitée'); clear filename

method=fopen(strcat(pathname,'method'),'r','ieee-le');
texte_method=char(fread(method,[inf],'int8'));
fclose(method);
texte_method=texte_method(:)';
SliceGrad=scan_acqp('##$SliceGrad=',texte_method,1);
p1=scan_acqp('##$RefPul=(',texte_method,1); p1=p1(1)/1000;
clear ans filename method

pulseshape=scan_acqp('##$RefPulShape=',texte_method,1);
pulseshape=pulseshape(1:2:end).*exp(1i*pulseshape(2:2:end)*pi/180);
  clear texte_method
   
subplot(2,1,1)
plot(abs(pulseshape))
subplot(2,1,2)
plot(angle(pulseshape))
% 
% subplot(2,1,1)
% plot(real(pulseshape))
% subplot(2,1,2)
% plot(imag(pulseshape))