% Based on "Unsupervised feature extraction and band subset selection techniques 
% based on relative entropy criteria for hyperspectral data analysis" 2003
% https://doi.org/10.1117/12.485942

function [spectral_band] = svd_sbs(hsi,n_selected_bands)
C = cov(hsi); 
p=n_selected_bands;
[V,D] = eigs(C,p);
Vi =V(:,1:p);
[Q,R,P] = qr(Vi');
[I,J]=find(P(:,1:p)==1);
spectral_band=I;
%X = hsi*P;
%X = X(:,1:p);


