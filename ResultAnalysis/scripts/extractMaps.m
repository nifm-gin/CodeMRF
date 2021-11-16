function Reconstruction = extractMaps(Reconstruction, Images, Properties, dictionary, normDictionary)

    % find points that have no value
    Reconstruction.toSkip = isnan(Reconstruction.idxMatch);
    
    % make PD map
    Reconstruction.PDmap = nan(Images.nX, Images.nY, Images.nZ);
    Reconstruction.PDmap(~Reconstruction.toSkip) = Images.norme_dicom(~Reconstruction.toSkip) ./ normDictionary(Reconstruction.idxMatch(~Reconstruction.toSkip));
    
    % make maps for all 'list' properties 
    propList = fieldnames(Properties);
    propList = propList(contains(propList, 'list'));
    for f = 1:numel(propList)
        if numel(Properties.(propList{f})) == 1
            Reconstruction.([propList{f}(1:end-4) 'Map']) = nan(Images.nX, Images.nY, Images.nZ);
            Reconstruction.([propList{f}(1:end-4) 'Map'])(~Reconstruction.toSkip) = Properties.(propList{f});
        else
            Reconstruction.([propList{f}(1:end-4) 'Map']) = nan(Images.nX, Images.nY, Images.nZ);
            Reconstruction.([propList{f}(1:end-4) 'Map'])(~Reconstruction.toSkip) = Properties.(propList{f})(Reconstruction.idxMatch(~Reconstruction.toSkip));
        end
    end
    
    % create matched signals cell
    Reconstruction.sigMatch = nan(Images.nX, Images.nY, Images.nZ, Images.nImages);
    for x = 1:Images.nX
        for y = 1:Images.nY
            for z = 1:Images.nZ
                if Reconstruction.toSkip(x,y,z)
                    continue
                else
                    Reconstruction.sigMatch(x,y,z,:) = dictionary(Reconstruction.idxMatch(x,y,z), :);
                end
            end
        end
    end
    
%     if numel(size(Reconstruction.toSkip)) == 2
%         toKeep = repmat(~Reconstruction.toSkip, [1,1,size(dictionary, 2)]);
%     else
%         toKeep = ~Reconstruction.toSkip;
%     end
%     for z = 1 : Images.nZ
%         Reconstruction.sigMatch{z} = nan(Images.nX, Images.nY, Images.nImages);
% %         Reconstruction.sigMatch{z}(toKeep(:,:,z,:)) = dictionary(Reconstruction.idxMatch(toKeep(:,:,z)),:);
%     end
end