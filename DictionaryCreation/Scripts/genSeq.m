function [seqOut] = genSeq(seqIn)
% This function generates FA, TR and TE patterns based on the following parameters
% found in the seqIn structure :

% Sequence.nPulses if the number of pulses
% Sequence.type is the type of pattern ("FISP" or TO BE IMPLEMENTED)
% Sequence.nLobes is the number of lobes to place
% Sequence.FAmin is the min FA in degree, 1 or nLobes elements
% Sequence.FAmax is the max FA in degree, 1 or nLobes elements
% Sequence.FAnoise controls the noise added in degree: noise = FAnoise*rand -FAnoise/2 
% Sequence.lobeShape is a text array containing the shape of the lobes, can be {"cos", "sin", "triangle", "rampUp", "rampDown", "const", "rand"}
% must have 1, or nLobes elements (all lobes have the same shape in case 1
% Sequence.skipTR determines the number of pulses with FA = 0 between
% lobes, can be 0
% Sequence.phases controls the phase increment of the FA, 
% 0: no alternance, 2: pi increments, (4: pi/2 increments NOT IMPLEMENTED YET)

%% Check input
% check lobeShape size
if numel(seqIn.lobeShape) == 1
    seqIn.lobeShape = repmat(seqIn.lobeShape, [1, seqIn.nLobes]);
else
    assert(numel(seqIn.lobeShape) == seqIn.nLobes, "The number of lobe shapes provided does not match the number of lobes. Use only one lobe shape if you want all lobes to have the same shape.");
end
% check FAmin size
if numel(seqIn.FAmin) == 1
    seqIn.FAmin = repmat(seqIn.FAmin, [1, seqIn.nLobes]);
else
    assert(numel(seqIn.FAmin) == seqIn.nLobes, "The number of FAmin provided does not match the number of lobes. Use only one FAmin to set it to all lobes.");
end
% check FAmax size
if numel(seqIn.FAmax) == 1
    seqIn.FAmax = repmat(seqIn.FAmax, [1, seqIn.nLobes]);
else
    assert(numel(seqIn.FAmax) == seqIn.nLobes, "The number of FAmax provided does not match the number of lobes. Use only one FAmax to set it to all lobes.");
end
if ~nnz(find(seqIn.phases == [0, 2, 4]))
    warning("Sequence.phases should be 0, 2 or 4. Treated as 0.")
    seqIn.phases = 0;
end
% TR
if numel(seqIn.TR)==1
    TR = repmat(seqIn.TR, [1, seqIn.nPulses]);
    genTR = 0;
    
elseif numel(seqIn.TR)==2
    genTR = 1;
    
elseif numel(seqIn.TR)== seqIn.nPulses
    TR = seqIn.TR;
    genTR = 0;
else
    error('Invalid TR provided: 1 element for constant, 2 elements for range, nPulses for pre-made vector')
end
%TE
if isempty(seqIn.TE)
    genTE = 1;
    
elseif numel(seqIn.TE)==1
    TE = repmat(seqIn.TE, [1, seqIn.nPulses]);
    genTE = 0;
    
elseif numel(seqIn.TE)==2
    genTE = 1;
    
elseif numel(seqIn.TR)== seqIn.nPulses
    TE = seqIn.TE;
    genTE = 0;
    
else
    error('Invalid TE provided: empty for TR/2, 1 element for constant, 2 elements for range, nPulses for pre-made vector')
end
%% %%%%%%% Flip Angle
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
            FA(lobeStart+1:lobeStart+nPtsLobe)= seqIn.FAmin(lobe) + sin([0:nPtsLobe-1]*pi/nPtsLobe)*seqIn.FAmax(lobe) + seqIn.FAnoise*rand(1, nPtsLobe)-seqIn.FAnoise/2;
        case 'cos'
            FA(lobeStart+1:lobeStart+nPtsLobe)= seqIn.FAmin(lobe) + abs(cos([0:nPtsLobe-1]*pi/nPtsLobe))*seqIn.FAmax(lobe) + seqIn.FAnoise*rand(1, nPtsLobe)-seqIn.FAnoise/2;
        case 'rampUp'
            FA(lobeStart+1:lobeStart+nPtsLobe)= linspace(seqIn.FAmin(lobe), seqIn.FAmax(lobe), nPtsLobe) + seqIn.FAnoise*rand(1, nPtsLobe)-seqIn.FAnoise/2;
        case 'rampDown'
            FA(lobeStart+1:lobeStart+nPtsLobe)= linspace(seqIn.FAmax(lobe), seqIn.FAmin(lobe), nPtsLobe) + seqIn.FAnoise*rand(1, nPtsLobe)-seqIn.FAnoise/2;
        case 'triangle'
            if ~mod(nPtsLobe,2) %if nPtsLobe is even
                FA(lobeStart+1:lobeStart+nPtsLobe)= [linspace(seqIn.FAmin(lobe), seqIn.FAmax(lobe), nPtsLobe/2), linspace(seqIn.FAmax(lobe), seqIn.FAmin(lobe), nPtsLobe/2)] + seqIn.FAnoise*rand(1, nPtsLobe)-seqIn.FAnoise/2;
            else
                FA(lobeStart+1:lobeStart+nPtsLobe)= [linspace(seqIn.FAmin(lobe), seqIn.FAmax(lobe), round(nPtsLobe/2)), linspace(seqIn.FAmax(lobe), seqIn.FAmin(lobe), round(nPtsLobe)/2)] + seqIn.FAnoise*rand(1, nPtsLobe)-seqIn.FAnoise/2;
            end
        case 'const' 
            FA(lobeStart+1:lobeStart+nPtsLobe) = ones(1,nPtsLobe)*seqIn.FAmax(lobe) + seqIn.FAnoise*rand(1, nPtsLobe)-seqIn.FAnoise/2;
        case 'rand'
            FA(lobeStart+1:lobeStart+nPtsLobe) = seqIn.FAmin(lobe) + (seqIn.FAmax(lobe) - seqIn.FAmin(lobe))*rand(1, nPtsLobe) + seqIn.FAnoise*rand(1, nPtsLobe)-seqIn.FAnoise/2;
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
if genTR == 1
    perlin = perlin_mrfv3(seqIn.nPulses/50,50);
    perlin = perlin - min(perlin);
    perlin = perlin/max(perlin); % normalize to 1

    TR = seqIn.TR(1) + (seqIn.TR(2)-seqIn.TR(1))*perlin;
    TR=TR';
end
% TR=15+15*perlin_mrfv3(seqIn.nPulses/50,50);
%   TR(2*(Nrf+waittime)+(1:Nrf))=50;

% TR(1:Nrf)=15+15*perlin_mrfv3(Nrf/20,20);
% TR((Nrf+1):2*Nrf)=15+250*perlin_mrfv3(Nrf/20,20);
% TR((2*Nrf+1):3*Nrf)=15+15*perlin_mrfv3(Nrf/20,20);
% TR((3*Nrf+1):4*Nrf)=15+250*perlin_mrfv3(Nrf/20,20);
% TR((4*Nrf+1):5*Nrf)=15+15*perlin_mrfv3(Nrf/20,20);

%% TE
if genTE == 1
    if isempty(seqIn.TE)
%   TE=10*ones(size(TR)) ;
%     TE=8+5*perlin_mrfv3(nPulses/50,50);
        TE=TR/2;
    else
        perlin = perlin_mrfv3(seqIn.nPulses/50,50);
        perlin = perlin - min(perlin);
        perlin = perlin/max(perlin); % normalize to 1
        TE = seqIn.TE(1) + (seqIn.TE(2)-seqIn.TE(1))*perlin;
        TE=TE';
    end
end

seqOut = seqIn;
seqOut.FA = FA;
seqOut.TE = TE;
seqOut.TR = TR;



end

