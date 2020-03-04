function [seqOut] = genSeq(seqIn)
% This function generates FA, TR and TE patterns based on the following parameters
% found in the seqIn structure :

% Sequence.nPulses if the number of pulses
% Sequence.type is the type of pattern ("FISP" or TO BE IMPLEMENTED)
% Sequence.nLobes is the number of lobes to place
% Sequence.FAmin is the min FA in degree
% Sequence.FAmax is the max FA in degree
% Sequence.FAnoise controls the noise added in degree: noise = FAnoise*rand -FAnoise/2 
% Sequence.lobeShape is a text array containing the shape of the lobes, can be {"cos", "sin", "triangle", "rampUp", "rampDown", "const", "rand"}
% must have 1, or nLobes elements (all lobes have the same shape in case 1
% Sequence.skipTR determines the number of pulses with FA = 0 between
% lobes, can be 0
% Sequence.phases controls the phase increment of the FA, 
% 0: no alternance, 2: pi increments, (4: pi/2 increments NOT IMPLEMENTED YET)


%% %%%%%%% Flip Angle
if numel(seqIn.lobeShape) == 1
    seqIn.lobeShape = repmat(seqIn.lobeShape, [1, seqIn.nLobes]);
else
    assert(numel(seqIn.lobeShape) == seqIn.nLobes, "The number of lobe shapes provided does not match the number of lobes. Use only one lobe shape if you want all lobes to have the same shape.");
end
if ~nnz(find(seqIn.phases == [0, 2, 4]))
    warning("Sequence.phases should be 0, 2 or 4. Treated as 0.")
    seqIn.phases = 0;
end
% compute length of each lobe
nPtsLobe = round((seqIn.nPulses - (seqIn.nLobes-1)*seqIn.skipTR) / seqIn.nLobes);
FA = zeros(1, seqIn.nPulses);
% prepare bool vec of lobes
isLobe = zeros(1, seqIn.nPulses);
% loop on lobes
for lobe = 1:seqIn.nLobes
    % get first point of current lobe
    lobeStart = (lobe-1) * (nPtsLobe + seqIn.skipTR);
    % mark lobe in bool vec
    isLobe(lobeStart+1:lobeStart+nPtsLobe)=1;
    % assign values from this point to the end of the lobe
    switch seqIn.lobeShape{lobe}
        case 'sin'
            FA(lobeStart+1:lobeStart+nPtsLobe)= seqIn.FAmin + sin([0:nPtsLobe-1]*pi/nPtsLobe)*seqIn.FAmax + seqIn.FAnoise*rand(1, nPtsLobe)-seqIn.FAnoise/2;
        case 'cos'
            FA(lobeStart+1:lobeStart+nPtsLobe)= seqIn.FAmin + abs(cos([0:nPtsLobe-1]*pi/nPtsLobe))*seqIn.FAmax + seqIn.FAnoise*rand(1, nPtsLobe)-seqIn.FAnoise/2;
        case 'rampUp'
            FA(lobeStart+1:lobeStart+nPtsLobe)= linspace(seqIn.FAmin, seqIn.FAmax, nPtsLobe) + seqIn.FAnoise*rand(1, nPtsLobe)-seqIn.FAnoise/2;
        case 'rampDown'
            FA(lobeStart+1:lobeStart+nPtsLobe)= linspace(seqIn.FAmax, seqIn.FAmin, nPtsLobe) + seqIn.FAnoise*rand(1, nPtsLobe)-seqIn.FAnoise/2;
        case 'triangle'
            if ~mod(nPtsLobe,2) %if nPtsLobe is even
                FA(lobeStart+1:lobeStart+nPtsLobe)= [linspace(seqIn.FAmin, seqIn.FAmax, nPtsLobe/2), linspace(seqIn.FAmax, seqIn.FAmin, nPtsLobe/2)] + seqIn.FAnoise*rand(1, nPtsLobe)-seqIn.FAnoise/2;
            else
                FA(lobeStart+1:lobeStart+nPtsLobe)= [linspace(seqIn.FAmin, seqIn.FAmax, round(nPtsLobe/2)), linspace(seqIn.FAmax, seqIn.FAmin, round(nPtsLobe)/2)] + seqIn.FAnoise*rand(1, nPtsLobe)-seqIn.FAnoise/2;
            end
        case 'const' 
            FA(lobeStart+1:lobeStart+nPtsLobe) = ones(1,nPtsLobe)*seqIn.FAmax + seqIn.FAnoise*rand(1, nPtsLobe)-seqIn.FAnoise/2;
        case 'rand'
            FA(lobeStart+1:lobeStart+nPtsLobe) = seqIn.FAmin + (seqIn.FAmax - seqIn.FAmin)*rand(1, nPtsLobe) + seqIn.FAnoise*rand(1, nPtsLobe)-seqIn.FAnoise/2;
    end
    phaseMult = ones(1,nPtsLobe);
    switch seqIn.phases
        case 2
            phaseMult(2:2:end) = -1;
        case 4
            error('Not implemented yet')
    end
    FA(lobeStart+1:lobeStart+nPtsLobe) = FA(lobeStart+1:lobeStart+nPtsLobe).*phaseMult;
end

%% 
%    FA=90*perlin_mrfv3(nPulses/20,20); % ---------------------------------- A VIRER APRES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FA = round(FA);
FA=FA(1:seqIn.nPulses)*pi/180;
% FA(2:2:end)=-FA(2:2:end);

%   FA(2:4:end)=-FA(2:4:end);
%   FA(3:4:end)=1i*FA(3:4:end);
%   FA(4:4:end)=-1i*FA(4:4:end);


%% TR
TR=15+15*perlin_mrfv3(seqIn.nPulses/50,50);
%   TR(2*(Nrf+waittime)+(1:Nrf))=50;

% TR(1:Nrf)=15+15*perlin_mrfv3(Nrf/20,20);
% TR((Nrf+1):2*Nrf)=15+250*perlin_mrfv3(Nrf/20,20);
% TR((2*Nrf+1):3*Nrf)=15+15*perlin_mrfv3(Nrf/20,20);
% TR((3*Nrf+1):4*Nrf)=15+250*perlin_mrfv3(Nrf/20,20);
% TR((4*Nrf+1):5*Nrf)=15+15*perlin_mrfv3(Nrf/20,20);
TR=TR';
%% TE
%   TE=10*ones(size(TR)) ;
%     TE=8+5*perlin_mrfv3(nPulses/50,50);
TE=TR/2;
%     TE=min(TR/2,7.5+10*perlin_mrfv3(nPulses/20,20));

seqOut = seqIn;
seqOut.FA = FA;
seqOut.TE = TE;
seqOut.TR = TR;



end

