dataPath = '/home/aurelien/Data/IRM/20200611_091212_crane_1_1/36';
dicoPath = '/home/aurelien/Installations/CodeMRF/DictionaryCreation/Results/JiangInv2';

[I, R] = MRFv3_Reconstruction(dataPath, dicoPath, 0);

figure; imagesc(R.T1Map); title('T1'); c = colorbar; set(get(c, 'title'), 'string', 'ms')
figure; imagesc(R.T2Map); title('T2'); c = colorbar; set(get(c, 'title'), 'string', 'ms')

%%
close all
figure; imagesc(R.T1Map);
mskT1 = roipoly;
%%
T1 = mean(R.T1Map(mskT1));
fprintf('T1 = %f ms \n', T1)
%%
close all
figure; imagesc(R.T2Map);
mskT2 = roipoly;
%%
T2 = mean(R.T2Map(mskT2));
fprintf('T2 = %f ms \n', T2)