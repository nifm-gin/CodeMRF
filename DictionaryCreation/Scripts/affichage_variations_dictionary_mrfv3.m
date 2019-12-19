figure('Name','Dictionary variations','units','normalized','outerposition',[0 0 1 1])

subplot(2,2,1)
indices=find(Properties.T2list(:)==VariablesAff.T2aff & Properties.B1rellist(:)==VariablesAff.B1relaff & Properties.dflist(:)==VariablesAff.dfaff);
for k=1:length(indices)
    plot(abs(dictionary(indices(k),:))/norm(abs(dictionary(indices(k),:))))
    hold on
end
title('Variation de la fingerprint avec T1')

subplot(2,2,2)
indices=find(Properties.T1list(:)==VariablesAff.T1aff & Properties.B1rellist(:)==VariablesAff.B1relaff & Properties.dflist(:)==VariablesAff.dfaff);
for k=1:length(indices)
    plot(abs(dictionary(indices(k),:))/norm(abs(dictionary(indices(k),:))))
    hold on
end
title('Variation de la fingerprint avec T2')

subplot(2,2,3)
indices=find(Properties.T1list(:)==VariablesAff.T1aff &Properties.T2list(:)==VariablesAff.T2aff & Properties.dflist(:)==VariablesAff.dfaff);
for k=1:length(indices)
    plot(abs(dictionary(indices(k),:))/norm(abs(dictionary(indices(k),:))))
    hold on
end
title('Variation de la fingerprint avec B1rel')

subplot(2,2,4)
indices=find(Properties.T1list(:)==VariablesAff.T1aff &Properties.T2list(:)==VariablesAff.T2aff & Properties.B1rellist(:)==VariablesAff.B1relaff);
for k=1:length(indices)
    plot(abs(dictionary(indices(k),:))/norm(abs(dictionary(indices(k),:))))
    hold on
end
title('Variation de la fingerprint avec df')


set(gcf,'Color','w')