function [ Robustness ] = testrobustness_mrfv3( SNR,dico,T1list,T2list,dflist,v,B1rellist,Parameters, Ndivide )
%TESTROBUSTNESS_MRFV3 Summary of this function goes here

if nargin<9
    Ndivide=50; % Pour éviter de créer des matrices trop grandes pour Matlab lorsque le dico est énorme, on divise le dictionnaire en Ndivide parties qu'on traite une par une. Il faut donc un Ndivide assez grand pour limiter la taille des matrices, mais assez petit pour ne pas trop ralentir le code vu qu'on boucle dessus.
end

Robustness=struct;
[Nsets,Npoints,Nv]=size(dico);

% Concaténation du dico
dictionary=dico(:,:,1);
vlist=v(1)*ones(Nsets,1);
if Nv>1
    for kv=2:Nv
        dictionary=cat(1,dictionary,dico(:,:,kv));
        vlist=cat(1,vlist,v(kv)*ones(Nsets,1));
    end
    Nsets=Nsets*Nv;
    T1list=repmat(T1list,[Nv 1]);
    T2list=repmat(T2list,[Nv 1]);
    dflist=repmat(dflist,[Nv 1]);
    B1rellist=repmat(B1rellist,[Nv 1]);
else
    vlist=v*ones(Nsets,1);
end

% Création des signaux bruités
ProtonDensity_th=(rand(Nsets,1).*10^5)*ones(1,Npoints); % Proton density
Moyennes=mean(abs(dictionary),2);%sqrt(mean(dictionary.^2,2))/sqrt(Npoints);
Noisy_signals=(abs(dictionary)+randn(Nsets,Npoints).*(Moyennes*ones(1,Npoints))./SNR).*ProtonDensity_th;



    if Ndivide<1
        [resultats,innerproduct]=templatematch_MRFv3(abs(dictionary),abs(Noisy_signals));
    else
        if Nsets/Ndivide~=round(Nsets/Ndivide)
            disp('Ndivide n est pas un diviseur de Nfingerprints, Ndivide recalculé:');
            facteurs=factor(Nsets);
            Ndivide=facteurs(end);
            display(Ndivide)
            clear facteur
        end
       if Ndivide >20, h=waitbar(0,'Test de robustesse en cours'); end
        innerproduct=zeros(Nsets,1);
        resultats=zeros(Nsets,1);
        for kd=1:Ndivide
            [innerproduct((1:Nsets/Ndivide)+(Nsets/Ndivide)*(kd-1)),resultats((1:Nsets/Ndivide)+(Nsets/Ndivide)*(kd-1))]=templatematch_MRFv3(abs(dictionary),abs(Noisy_signals((1:Nsets/Ndivide)+(Nsets/Ndivide)*(kd-1),:)));
            if Ndivide >20, waitbar(kd/Ndivide,h); end
        end
        if Ndivide >20, close(h); end
    end
    PD_exp=mean(abs(Noisy_signals),2)./mean(abs(dictionary(resultats,:)),2);
    
    
    Robustness.ErrorT1_rel=mean(abs(T1list(resultats)-T1list)./T1list);
    Robustness.ErrorT2_rel=mean(abs(T2list(resultats)-T2list)./T2list);
    Robustness.Errordf_abs=mean(abs(dflist(resultats)-dflist));
    Robustness.ErrorPD_rel=mean(abs(PD_exp-ProtonDensity_th(:,1))./ProtonDensity_th(:,1));
    Robustness.Errorv_abs=mean(abs(vlist(resultats)-vlist));
    Robustness.ErrorB1_rel=mean(abs(B1rellist(resultats)-B1rellist)./B1rellist);
%     ErrorPD=mean(abs(PD_exp-Moyennes)./Moyennes);


 figure('Name','Test de justesse','units','normalized','outerposition',[1/6 1/6 2/3 2/3])
    subplot(2,3,1)
    plot(T1list,T1list(resultats),'r.')
    title('T1_{trouvé} VS T1_{th}')
    xlabel('T1 théorique (ms)')
    ylabel('T1 trouvé (ms)')
    
    subplot(2,3,2)
    plot(T2list,T2list(resultats),'b.')
    title('T2_{trouvé} VS T2_{th}')
    xlabel('T2 théorique (ms)')
    ylabel('T2 trouvé (ms)')
    
    subplot(2,3,3)
    plot(dflist,dflist(resultats),'g.')
    title('df_{trouvé} VS df_{th}')
    xlabel('df théorique (Hz)')
    ylabel('df trouvé (Hz)')
    
    subplot(2,3,4)
    plot(B1rellist,B1rellist(resultats),'k.')
    title('B1_{trouvé} VS B1_{th}')
    xlabel('B1 théorique')
    ylabel('B1 trouvé')
    
    subplot(2,3,5)
    plot(vlist,vlist(resultats),'g.')
    title('v_{trouvé} VS v_{th}')
    xlabel('v théorique (mm/s)')
    ylabel('v trouvé (mm/s)')
    
    subplot(2,3,6)
    plot(resultats,'k.')
    title('#fingerprint_{trouvé} VS #fingerprint_{th}')
    xlabel('n° de signature théorique')
    ylabel('n° de signature trouvé')
    
    set(gcf,'Color','w')
    

