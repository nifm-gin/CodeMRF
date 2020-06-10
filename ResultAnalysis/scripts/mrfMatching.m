function [score,idxMatch] = mrfMatching(dict,sig)
% Function for MRF matching by dot-product
% -------------------------------------------------------------------------
% - sig: acquired signals, shaped as [X, Y, Z, time], already normalized
% - dict: dictionary shaped as [nEntries, time], already normalized
%
% - score: best dot-product in each space point [X, Y, Z]
% - idxMatch: index of dico entry corresponding to score, [X, Y, Z]
% -------------------------------------------------------------------------

if nargin<2 
    disp('Error - 2 inputs are required!'); 
    return 
end

S = size(sig);
spaceDimProd = prod(S(1:end-1)); % Product of spatial dimensions = number of voxels in the image

score        = zeros(spaceDimProd, 1);
idxMatch     = zeros(spaceDimProd, 1);

maxSize = 5 * 1e4;

if size(dict, 1) > maxSize

    chunkSize = maxSize;
    I = floor(size(dict,1) / chunkSize);
    sig = reshape(sig, spaceDimProd, S(end)); % Reshape only once
    
    for i = 1 : I
        % Match signal with ith chunk of dico
        [localScore, localIdx] = max(sig * dict((i-1)*chunkSize+1 : i*chunkSize, :)', [], 2) ;
        
        % replace final points in final results where local result is
        % better
        idxMatch(localScore > score) = localIdx(localScore > score) + (i-1)*chunkSize;
        score(localScore > score) = localScore(localScore > score);
    end
    % Take care of what was not in a chunk
    if mod(size(dict,1), chunkSize) ~= 0
        [localScore, localIdx] = max(sig * dict(I * chunkSize+1 : end, :)', [], 2) ;
        idxMatch(localScore > score) = localIdx(localScore > score) + I * chunkSize;
        score(localScore > score) = localScore(localScore > score);
    end
    
else % Perform all matching at once
    % reshape sig to be [spaceDimProd, nPulses]
    % dot product with dico
    [localScore,localIdx] = max(reshape(sig, spaceDimProd, S(end)) * dict', [], 2, 'omitnan') ;
    idxMatch(localScore > score) = localIdx(localScore > score);
    score(localScore > score) = localScore(localScore > score);
end
    % Reshape results to original image dimensions
    if numel(S) > 2
        score = reshape(score, S(1:end-1));
        idxMatch = reshape(idxMatch, S(1:end-1));       
    end
    
    % ensure same result where there is no signal
    idxMatch(score == 0) = nan;
    score(score == 0) = nan;    
end