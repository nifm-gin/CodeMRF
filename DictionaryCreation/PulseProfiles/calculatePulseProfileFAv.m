function [ Rot, FAlist, positions_mm, SliceThickness_th_mm, p0 ] = calculatePulseProfileFAv(pulseshape, FA, flow_velocity, df )
    % PULSEPROFILEFAV Calculates rotation matrices for different positions in 
    % the slice corresponding to a 'pulseshape' pulse
    % for a given list of flip angles(�) and a given transverse velocity(mm/s)
    % based on the pulse shape stored in Bruker method files.
    % More accurate than a complex slice profile because the theoretical
    % rotation axis is not exactly in the xy plane.

    % Adapted by Sandra Brunel from a program written by Jan Warnking
    if nargin<4
        df=0;
    end

    load(strcat('/media/aurelien/QQCHSE/MRF_v3_SliceProfile_flux/Création de dictionnaire/Pulse Profiles/Profils/',num2str(pulseshape),'.mat'))
    FAlist=unique(FA); % Flip angle list in � 

    pulse_duration = p0; % duration of RF pulse in s
    gamma = 2*pi*42.58e6; % gamma in rad/T.s
    n_rf_samples = L;
    sample_time = T;
    rf_amplitude_integral = sum(pulseshape)*sample_time;

    grad = (GradCalConst/(gamma/2*pi))*SliceGrad*1e4; % (Hz/mm.1)/(Hz/T)*(%/100%)*1e4Gauss/T*10mm/cm --> Gauss/cm % slice sel. gradient amplitude

    dReph=281e-6;  % Duration of refocalisation gradient in s
    n_samples_refoc = round(dReph*n_rf_samples/pulse_duration); % refocNbPoints =  totalNbPoints * (refocDuration/totalDuration)  --> nb of samples for refocusing (aurelien)
    grad_refocvalue = grad*n_rf_samples/(2*n_samples_refoc); % <=> grad_refoc * refocNbPoints = 0.5*grad*nbTotalPoints % half the area of sl. sel. grad (aurelien)

    grad_refoc = [-grad_refocvalue*ones(n_samples_refoc,1); grad*ones(n_rf_samples,1); -grad_refocvalue*ones(n_samples_refoc,1)]; % refoc + slice selection?

    T1 = Inf;
    T2 = Inf;
    % x_mm = f/(GradCalConst*SliceGrad/100);
%     x_mm=[-3:6/1740:3]; %--------------------------------------------------------------------------------------------------------------------------
    x_mm = 0;
% center = find(abs(x_mm) == min(abs(x_mm)),1);
    plot_limits = 3;
    idx_plot = find(abs(x_mm)<plot_limits);
    positions_mm=x_mm(idx_plot);
    n_pos=length(positions_mm);

    O = zeros(1,length(positions_mm));
    l = ones (1,length(positions_mm));
    Mx = [l;O;O];
    My = [O;l;O];
    Mz = [O;O;l];
    Rot=zeros(3,3,n_pos,length(FAlist));

    for kFA=1:length(FAlist)
        pulseshape_T = pulseshape*(FAlist(kFA)*pi/180)/(gamma*rf_amplitude_integral); % RF pulse in T
        pulseshape_gauss = pulseshape_T * 1e4;
        pulseshape_gauss_refoc = [zeros(n_samples_refoc,1);pulseshape_gauss;zeros(n_samples_refoc,1)];

        % [Mx5,My5,Mz5] = sliceprofile5(pulseshape_gauss_refoc,grad_refoc,t_refoc,T1,T2,x_mm,0,flow_velocity);
        if flow_velocity==0
        [Mxx,Myx,Mzx] = sliceprofile(pulseshape_gauss_refoc,grad_refoc,sample_time,T1,T2,positions_mm,df,Mx);
        [Mxy,Myy,Mzy] = sliceprofile(pulseshape_gauss_refoc,grad_refoc,sample_time,T1,T2,positions_mm,df,My);
        [Mxz,Myz,Mzz] = sliceprofile(pulseshape_gauss_refoc,grad_refoc,sample_time,T1,T2,positions_mm,df,Mz);
        else
        [Mxx,Myx,Mzx] = sliceprofile_v(pulseshape_gauss_refoc,grad_refoc,sample_time,T1,T2,positions_mm,df,flow_velocity,Mx);
        [Mxy,Myy,Mzy] = sliceprofile_v(pulseshape_gauss_refoc,grad_refoc,sample_time,T1,T2,positions_mm,df,flow_velocity,My);
        [Mxz,Myz,Mzz] = sliceprofile_v(pulseshape_gauss_refoc,grad_refoc,sample_time,T1,T2,positions_mm,df,flow_velocity,Mz);
        end

        % Matrice de rotation
        Rot(1,1,1:n_pos,kFA)=Mxx;
        Rot(2,1,1:n_pos,kFA)=Myx;
        Rot(3,1,1:n_pos,kFA)=Mzx;

        Rot(1,2,1:n_pos,kFA)=Mxy;
        Rot(2,2,1:n_pos,kFA)=Myy;
        Rot(3,2,1:n_pos,kFA)=Mzy;

        Rot(1,3,1:n_pos,kFA)=Mxz;
        Rot(2,3,1:n_pos,kFA)=Myz;
        Rot(3,3,1:n_pos,kFA)=Mzz;

    end
    % size(Rot)
    % clear acqp ans f Fs L method n_rf_samples NFFT phi_refox plot_limits pulse_duration pulseshape pulseshape_gauss pulseshape_gauss_refoc pulseshape_T rf_amplitude_integral sample_time Slice_profile_mm 
    % clear Slice_profile_mm_centered SliceProfile SP_quanta t T T1 T2 t_refoc texte_acqp texte_method SliceGrad
    % clear x_mm phi_refoc fa_phase fa_profile gamma grad GradCalConst idx_plot
    % clear FA Mx My Mz Mxx Mxy Mxz Myx Myy Myz Mzx Mzy Mzz center h k O l

end

