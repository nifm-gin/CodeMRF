function [] = sequence2txt_mrfv3(Dir, name, Sequence)
% %% Creation of the directory
% dossier=strcat('D:\MATLAB\MRF_v2\Data\S�quences_et_dicos\',date);
% mkdir(dossier);
% cd(dossier);

%% Creation of the text file
fid = fopen(strcat(Dir, name,'.txt'),'w');
if fid > 0
    % Writing the sequence
    fprintf(fid,'%d\n',Sequence.nPulses);

    if Sequence.m0(3)==1
        fprintf(fid,'%d\n',0);
    elseif Sequence.m0(3)==-1
        fprintf(fid,'%d\n',1);
    end

    fprintf(fid,'%d\n',Sequence.Ncycles);

    for k=1:Sequence.nPulses
        fprintf(fid,'%+f %f %f %f\n',(Sequence.FA(k))*180/pi,Sequence.TR(k),Sequence.TE(k), Sequence.Phi(k)*180/pi); 
        % Car FA en rad dans cette simu et a priori alternance +/- mais pas �crit dans le vecteur FA
    end

    fclose(fid);
else
    error('Could not open file %s to save PV6 txt sequence', strcat(Dir, name,'.txt'))
end