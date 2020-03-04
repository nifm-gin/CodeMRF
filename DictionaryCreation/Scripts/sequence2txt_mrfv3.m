function [] = sequence2txt_mrfv3(rootDir, name, Sequence)
% %% Creation of the directory
% dossier=strcat('D:\MATLAB\MRF_v2\Data\S�quences_et_dicos\',date);
% mkdir(dossier);
% cd(dossier);

%% Creation of the text file
fid = fopen(strcat(rootDir, 'SequencesAndProperties/TextSequences/', name,'.txt'),'w');


% Writing the sequence
fprintf(fid,'%d\n',Sequence.nPulses);

if Sequence.m0(3)==1
    fprintf(fid,'%d\n',0);
elseif Sequence.m0(3)==-1
    fprintf(fid,'%d\n',1);
end

fprintf(fid,'%d\n',Sequence.Ncycles);

% if length(Sequence.TE)==1
%     Sequence.TE=Sequence.TE*ones(nPulses,1);
% end

for k=1:Sequence.nPulses
    fprintf(fid,'%+f %f %f\n',(Sequence.FA(k))*180/pi,Sequence.TR(k),Sequence.TE(k)); % Car FA en rad dans cette simu et a priori alternance +/- mais pas �crit dans le vecteur FA
    
    
end


fclose(fid);

clear dossier fid k ans
end