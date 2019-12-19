figure('Name','Dictionary variations','units','normalized','outerposition',[0 0 1 1])
set(gcf,'Color','w')

indicev=find(Properties.vlist==VariablesAff.vaff);

subplot(2,3,1)
indices=find(Properties.T2list(:)==VariablesAff.T2aff & Properties.B1rellist(:)==VariablesAff.B1relaff & Properties.dflist(:)==VariablesAff.dfaff);
for k=1:length(indices)
    plot(abs(dico_flux(indices(k),:,indicev))/norm(abs(dico_flux(indices(k),:,indicev))))
    hold on
end
title('Variation de la fingerprint avec T1')

subplot(2,3,2)
indices=find(Properties.T1list(:)==VariablesAff.T1aff & Properties.B1rellist(:)==VariablesAff.B1relaff & Properties.dflist(:)==VariablesAff.dfaff);
for k=1:length(indices)
    plot(abs(dico_flux(indices(k),:,indicev))/norm(abs(dico_flux(indices(k),:,indicev))))
    hold on
end
title('Variation de la fingerprint avec T2')

subplot(2,3,3)
indices=find(Properties.T1list(:)==VariablesAff.T1aff &Properties.T2list(:)==VariablesAff.T2aff & Properties.dflist(:)==VariablesAff.dfaff);
for k=1:length(indices)
    plot(abs(dico_flux(indices(k),:,indicev))/norm(abs(dico_flux(indices(k),:,indicev))))
    hold on
end
title('Variation de la fingerprint avec B1rel')

subplot(2,3,4)
indices=find(Properties.T1list(:)==VariablesAff.T1aff &Properties.T2list(:)==VariablesAff.T2aff & Properties.B1rellist(:)==VariablesAff.B1relaff);
for k=1:length(indices)
    plot(abs(dico_flux(indices(k),:,indicev))/norm(abs(dico_flux(indices(k),:,indicev))))
    hold on
end
title('Variation de la fingerprint avec df')

subplot(2,3,5)
indices=find(Properties.T1list(:)==VariablesAff.T1aff & Properties.T2list(:)==VariablesAff.T2aff & Properties.B1rellist(:)==VariablesAff.B1relaff & Properties.dflist(:)==VariablesAff.dfaff);
for k=1:length(Properties.vlist)
    plot(abs(dico_flux(indices,:,k))/norm(abs(dico_flux(indices,:,k))))
    hold on
end
title('Variation de la fingerprint avec v')


