function [ dictionary ] = calculdico_1v_gradmom1(Parameters, Properties,PulseProfile, Sequence,InvPulseProfile) % parameters, Npulses, T1list, T2list, dflist, B1rellist, vlist, m0, SliceProfile,Mz )

dictionary=zeros(length(Properties.dflist),Sequence.Npulses);

h=waitbar(0,'Calcul en cours...');
% nBlocks = numel(Parameters);

Rot_svg=PulseProfile.Rot;
for zz=1:length(Properties.dflist)
    this_pos = Parameters.pos;
    indicedf=find(abs(PulseProfile.dflist(:)-Properties.dflist(zz))==min(abs(PulseProfile.dflist(:)-Properties.dflist(zz))));
    %PulseProfile.Rot=squeeze(Rot_svg(:,:,:,:,:,indicedf)); Aurelien :
    %Comment this to keep Rot shape
    PulseProfile.Rot=Rot_svg(:,:,:,:,:,indicedf);
    % Dim : 3*3*Npos*NFA*Nv*Ndf
    % Goes from 6D to 4D if Nv=1
    
    % Initialisation
    if nargin<5
        M=(Sequence.m0')*ones(1,length(Parameters.pos));
    else
        M=InvPulseProfile.M0;
    end
    
    
    % Calculate signal evolution during each of the sequence blocks
    %     iSignal = 0;
    %     for iBlock = 1:nBlocks
    %         p = Parameters(iBlock);
    
    [Signal] = sm_sliceprofile_flow_gradmom1_mrfv3(Sequence, PulseProfile, ...
        Parameters, Properties.T1list(zz)/1000, Properties.T2list(zz)/1000, Properties.dflist(zz), Properties.B1rellist(zz), Properties.vlist(1), this_pos, M); 
    %  B1rel*parameters.rfrot, parameters.Gpre0, parameters.Gpre1, parameters.Gpost0, parameters.Gpost1, parameters.TE, parameters.TR,T1,T2, this_pos,parameters.min_pos_init, 
    %       parameters.max_pos_init, df, v, M, SliceProfile);
    
    %[Signal,M,this_pos]
    % store complex signal for this block
    nSignals = numel(Signal);
    dictionary(zz,(1:nSignals))=Signal(:)';
    %         dictionary(zz,iSignal+(1:nSignals))=Signal(:)';
    %         iSignal = iSignal + nSignals;
    waitbar(zz/length(Properties.dflist),h);
end
PulseProfile.Rot=Rot_svg;
close(h);
end

