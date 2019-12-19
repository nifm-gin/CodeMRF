function [maxval,matchout]=templatematch_v2(dict,sig)

if nargin<2 
    disp('Error - 2 inputs are required!'); 
    return 
end

% First normalize the dictionary and signal 
for i=1:size(dict(:,:),1) 
    dict(i,:)=dict(i,:)./norm(dict(i,:)); 
end
for i=1:size(sig(:,:),1) 
    sig(i,:)=sig(i,:)./norm(sig(i,:));
end
% Calculate inner product 
innerproduct=dict(:,:)*conj(sig(:,:))';
% Take the maximum value and return the index 
[maxval,matchout]=max(abs(innerproduct));

end