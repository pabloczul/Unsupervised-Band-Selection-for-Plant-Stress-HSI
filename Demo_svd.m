%{ 
    Author:      Pablo Carmona
%}

% Load indian
%Pines = double(importdata('Indian_pines_corrected.mat'));
%X = permute(Pines, [3, 1, 2]);

%Load Kennedy space center
KSC = double(importdata('C:\Datasets\KennedySpaceCenter\KSC.mat'));
X = permute(KSC, [3, 1, 2]);

%%
% Here X can be linearly normalized to [0, 1], or just keep unchanged.
X = X(:, :);

X = permute(X, [2,1]);

%% Experiment on usage of similarity_sbs

bands = similarity_sbs(X, 8);

%% Experiment on usage of svd_sbs
bands_svdsbs = svd_sbs(X, 8);

%% Load CornData Firms

%ligtFirm = double(importdata('C:\Users\marat\Documents\GitHub\svd_sbs\testFirm.mat'));

%Complete databe 447 spectral firms
CornData = double(importdata('C:\Users\marat\Documents\GitHub\CornAnalisis\CornData.mat'));

%Mean per nitrogen treatment (4) of Corn database
%CornData = double(importdata('C:\Users\marat\Documents\GitHub\CornAnalisis\SelectedCornData.mat'));

if isa(CornData, 'struct')
    fns = fieldnames(CornData);
    X = CornData;
else  
    %CornData = permute(CornData, [2,1]);
    X.data = CornData;
    fns = fieldnames(X);
end

%% Load Bean Data
%Complete databe 376 spectral firms
BeanData = double(importdata('C:\Datasets\Bean2021\19-11-2021\DataFiltered.mat'));

if isa(BeanData, 'struct')
    fns = fieldnames(BeanData);
    X = BeanData;
else  
    %CornData = permute(CornData, [2,1]);
    X.data = BeanData;
    fns = fieldnames(X);
end
%%

iterations = 4;
factor = 8;
sections = length(fns);

bands_simil = zeros([iterations,iterations*factor]);
bands_svd = zeros([iterations,iterations*factor]);
prior_bands = 0;

for j = 1 : sections
    
    X.(fns{j}) = permute(X.(fns{j}), [2,1]);

    data_size = size(X.(fns{j}));
    
    %To use different # of target bands
    for i = 1 : iterations

        selected_bands = similarity_sbs(X.(fns{j}), (factor/sections)*i);
        bands_simil(i,((factor/sections)*i*(j-1)+1):(factor/sections)*i*j) = selected_bands + prior_bands;
                
        selected_bands = svd_sbs(double(X.(fns{j})), (factor/sections)*i);
        bands_svd(i,((factor/sections)*i*(j-1)+1):(factor/sections)*i*j) = selected_bands + prior_bands;
        
        %band_set = sort(band_set)
    end
    prior_bands = prior_bands + data_size(2)
end
%%
%Indian Pines
%save('SelectedSBS.mat','bands_simil','bands_svd');
%Kennedy Space Center
%save('SelectedSBS_KSC.mat','bands_simil','bands_svd');

%Spectrometer firm
save('BEAN_SVD.mat','bands_svd');