% clear all
% pulseshape='Calculated';
% % FA=[-90:0.1:-0.1 0.1:0.1:90]; % deg
% FA=[-90:0.1:-0.1 0.1:0.1:90]; % deg
% % FA=[-90:10:90];
% flow_velocities=[0:10:200]; % mm/s

% kdf=1;
% [ Rot(:,:,:,:,kv), FAlist, positions_mm, SliceThickness_th_mm, p0 ] = calculatePulseProfileFAv(pulseshape, FA, flow_velocities(kv));
% 
% parfor kdf=2:length(flow_velocities)
%     disp(kv)
% %     tic
%     [ Rot(:,:,:,:,kv), FAlist, positions_mm, SliceThickness_th_mm, p0 ] = calculatePulseProfileFAv(pulseshape, FA, flow_velocities(kv));
% %     toc
% 
% end
% clear Rottmp
% % save dictionary_SliceProfiles_FAv_Calculated -v7.3
% save dico_vnegposx10_tenthdeg -v7.3 

%% 
kdf=1;
[ Rot(:,:,:,:,:,kdf), FAlist, positions_mm, SliceThickness_th_mm, p0 ] = calculatePulseProfileFAv(PulseProfile.PulseShape, Sequence.FA, Properties.vlist, Properties.df(kdf));
for kdf=2:length(Properties.df)
    disp(kdf)
%     tic
    [ Rot(:,:,:,:,:,kdf), FAlist, positions_mm, SliceThickness_th_mm, p0 ] = calculatePulseProfileFAv(PulseProfile.PulseShape, Sequence.FA, Properties.vlist, Properties.df(kdf));
%     toc
end
FA = Sequence.FA;
dflist = Properties.df;
flow_velocities = Properties.vlist;
Nspins = length(positions_mm);
save('/media/aurelien/QQCHSE/MRF_v3_SliceProfile_flux/Création de dictionnaire/Pulse Profiles/Dictionnaire/dico_Test_18_12_2019.mat', ...
    'Rot', 'FAlist', 'positions_mm', 'SliceThickness_th_mm', 'p0', 'FA', 'dflist', 'flow_velocities')
%%
% dflist=[0:10:200];
% flow_velocities=[0:10:200];
% Rot=zeros(3,3,length(positions_mm),length(FA),length(flow_velocities),5);
load dico_spinsx10_df_full_part16to21;
kdf=3
df=dflist(kdf+15);
parfor kv=11:length(flow_velocities);
        [ Rot(:,:,:,:,kv,kdf), FAlist, positions_mm, SliceThickness_th_mm, p0 ] = calculatePulseProfileFAv(pulseshape, FA, flow_velocities(kv),df);
        disp(strcat(num2str(kdf),',  ',num2str(kv)))
end
save dico_spinsx10_df_full_part16to21 -v7.3

for kdf=4:6;%length(dflist)
    df=dflist(kdf+15);
     [ Rot(:,:,:,:,1,kdf), FAlist, positions_mm, SliceThickness_th_mm, p0 ] = calculatePulseProfileFAv(pulseshape, FA, flow_velocities(1),df);
     disp(strcat(num2str(kdf),',  ',num2str(1)))
    parfor kv=2:10 %length(flow_velocities);
        [ Rot(:,:,:,:,kv,kdf), FAlist, positions_mm, SliceThickness_th_mm, p0 ] = calculatePulseProfileFAv(pulseshape, FA, flow_velocities(kv),df);
        disp(strcat(num2str(kdf),',  ',num2str(kv)))
    end
    save dico_spinsx10_df_full_part16to21 -v7.3
    parfor kv=11:length(flow_velocities);
        [ Rot(:,:,:,:,kv,kdf), FAlist, positions_mm, SliceThickness_th_mm, p0 ] = calculatePulseProfileFAv(pulseshape, FA, flow_velocities(kv),df);
        disp(strcat(num2str(kdf),',  ',num2str(kv)))
    end
    save dico_spinsx10_df_full_part16to21 -v7.3
end
clear kv


%% A FAIRE QUAND TOUTES LES MATRICES ROT AURONT ETE CALCULEES, CORRECTION DU DEPHASAGE DU A DF PENDANT LE PULSE, ACTUELLEMENT COMPTE 2 FOIS
% Partie 1
clear all
load dico_spinsx10_df_full.mat
for kdf=1:5%length(dflist)
    for kv=1:length(flow_velocities);
    phi=2*pi*dflist(kdf)*p0;
    
    M=zeros(3);
    M(1,1)=cos(phi);
    M(1,2)=sin(phi);
    M(2,1)=-sin(phi);
    M(2,2)=cos(phi);
    M(3,3)=1;
    
    for kspin=1:length(positions_mm)
        for kFA=1:length(FAlist)
            Rotcorr(:,:,kspin,kFA,kv,kdf)=M*Rot(:,:,kspin,kFA,kv,kdf);
        end
    end
    end
end
clear M phi kspin kdf kFA k kv Rot
save dico_spinsx10_df_full_corr -v7.3

% Partie 2
clear all
load dico_spinsx10_df_full_part6to10.mat
for kdf=1:5%length(dflist)
    for kv=1:length(flow_velocities);
    phi=2*pi*dflist(kdf+5)*p0;
    
    M=zeros(3);
    M(1,1)=cos(phi);
    M(1,2)=sin(phi);
    M(2,1)=-sin(phi);
    M(2,2)=cos(phi);
    M(3,3)=1;
    
    for kspin=1:length(positions_mm)
        for kFA=1:length(FAlist)
            Rotcorr(:,:,kspin,kFA,kv,kdf)=M*Rot(:,:,kspin,kFA,kv,kdf);
        end
    end
    end
end
clear M phi kspin kdf kFA k kv Rot
save dico_spinsx10_df_full_part6to10_corr -v7.3

% Partie 3
clear all
load dico_spinsx10_df_full_part6to10.mat
for kdf=1:5%length(dflist)
    for kv=1:length(flow_velocities);
    phi=2*pi*dflist(kdf+10)*p0;
    
    M=zeros(3);
    M(1,1)=cos(phi);
    M(1,2)=sin(phi);
    M(2,1)=-sin(phi);
    M(2,2)=cos(phi);
    M(3,3)=1;
    
    for kspin=1:length(positions_mm)
        for kFA=1:length(FAlist)
            Rotcorr(:,:,kspin,kFA,kv,kdf)=M*Rot(:,:,kspin,kFA,kv,kdf);
        end
    end
    end
end
clear M phi kspin kdf kFA k kv Rot
save dico_spinsx10_df_full_part11to15_corr -v7.3

% Partie 4
clear all
load dico_spinsx10_df_full_part16to21.mat
for kdf=1:6%length(dflist)
    for kv=1:length(flow_velocities);
    phi=2*pi*dflist(kdf+15)*p0;
    
    M=zeros(3);
    M(1,1)=cos(phi);
    M(1,2)=sin(phi);
    M(2,1)=-sin(phi);
    M(2,2)=cos(phi);
    M(3,3)=1;
    
    for kspin=1:length(positions_mm)
        for kFA=1:length(FAlist)
            Rotcorr(:,:,kspin,kFA,kv,kdf)=M*Rot(:,:,kspin,kFA,kv,kdf);
        end
    end
    end
end
clear M phi kspin kdf kFA k kv Rot
save dico_spinsx10_df_full_part16to21_corr -v7.3