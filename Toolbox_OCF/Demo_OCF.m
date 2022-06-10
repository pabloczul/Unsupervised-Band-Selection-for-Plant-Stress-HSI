%{ 
    Author:      Fahong Zhang
    Reference:   Q. Wang, F. Zhang, and X. Li, ¡°Optimal Clustering Framework 
                 for Hyperspectral Band Selection,¡± IEEE Transactions on Geoscience 
                 and Remote Sensing (T-GRS), DOI: 10.1109/TGRS.2018.2828161, 2018.
    Function:    A demo of using OCF to conduct TRC-OC-FDPC, NC-OC-MVPCA and 
                 NC-OC-IE. 
    Instruction: This file shows how to use OCF to do band selection,
                 Indian Pines data set is used as an example.
%}

% Load indian
Pines = double(importdata('Indian_pines_corrected.mat'));
X = permute(Pines, [3, 1, 2]);

%Load Kennedy space center
%KSC = double(importdata('C:\Datasets\KennedySpaceCenter\KSC.mat'));
%X = permute(KSC, [3, 1, 2]);

% Here X can be linearly normalized to [0, 1], or just keep unchanged.
X = X(:, :);

%% Load CornData Firms

%ligtFirm = double(importdata('C:\Users\marat\Documents\GitHub\svd_sbs\testFirm.mat'));

%Complete databe 447 spectral firms
CornData = double(importdata('C:\Users\marat\Documents\GitHub\CornAnalisis\CornData.mat'));

%Mean per nitrogen treatment (4) of Corn database
%CornData = importdata('C:\Users\marat\Documents\GitHub\CornAnalisis\SectionsCornData.mat');

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
BeanData = transpose(double(importdata('C:\Datasets\Bean2021\19-11-2021\DataFiltered.mat')));

if isa(BeanData, 'struct')
    fns = fieldnames(BeanData);
    X = BeanData;
else  
    %CornData = permute(CornData, [2,1]);
    X.data = BeanData;
    fns = fieldnames(X);
end
%%
% Number of bands

iterations = 4;
factor = 8;

sections = length(fns);

%% An example to conduct TRC-OC-FDPC:

band_FDPC = zeros([iterations,iterations*factor]);
prior_bands = 0;

for j = 1 : sections
    data_size = size(X.(fns{j}));
    % Achieve the ranking values of band via E-FDPC algorithm
    [L, ~] = size(X.(fns{j}));
    D = E_FDPC_get_D(X.(fns{j})');
    [~, bnds_rnk_FDPC] = E_FDPC(D, L);

    % Construct a similarity graph
    S_FG = get_graph(X.(fns{j}));

    % Get the map f in Eq. (16)
    F_TRC_FDPC = get_F_TRC(S_FG, bnds_rnk_FDPC);

    % Set the parameters of OCF, to indicate the objective function is TRC
    para_TRC_FDPC.bnds_rnk = bnds_rnk_FDPC;
    para_TRC_FDPC.F = F_TRC_FDPC;
    para_TRC_FDPC.is_maximize = 0; % TRC should be minimized
    para_TRC_FDPC.X = X.(fns{j}); 
    para_TRC_FDPC.operator_name = 'max'; % use 'max' operator for Eq. (8)

    for i = 1 : iterations
        % Selection
        selected_bands = sort(ocf(para_TRC_FDPC, (factor/sections)*i));
        band_FDPC(i,((factor/sections)*i*(j-1)+1):(factor/sections)*i*j) = selected_bands + prior_bands;
        %band_set = ocf(para_TRC_FDPC, k);

        
        
        %band_set = sort(band_set)
    end
    prior_bands = prior_bands + data_size([1])
end 
%Indian Pines
%save('SelectedSBS.mat','band_FDPC');
%Kennedy Space Center
%save('SelectedBandsOCF_KSC.mat','band_FDPC');

%% Saving band data
%Spectrometer firm
save('BEAN_OCF.mat','band_FDPC');
%% An example to conduct NC-OC-MVPCA:

% Achieve the ranking values of band via MVPCA algorithm
[para_NC_PCA.bnds_rnk, ~ ] = MVPCA(X);

% Construct a similarity graph
S_FG = get_graph(X);

% Get the map f in Eq. (16)
F_NC_FG = get_F_NC(S_FG);

% Set the parameters of OCF, to indicate the objective function is NC
para_NC_PCA.F = F_NC_FG;
para_NC_PCA.is_maximize = 1; % NC should be maximized
para_NC_PCA.X = X; 
para_NC_PCA.operator_name = 'sum'; % use 'sum' operator for Eq. (8)

band_NC_PCA = zeros([4,32]);

for i = 1 : 4
    % Selection
    
    band_NC_PCA(i,1:i*8) = ocf(para_NC_PCA, 8*i);
    
%band_set = ocf(para_NC_PCA, k);
%sort(band_set)
end
%% An example to conduct NC-OC-IE:

% Achieve the ranking values of band via MVPCA algorithm
[para_NC_IE.bnds_rnk, ~] = Entrop(X);

% Construct a similarity graph
S_FG = get_graph(X);

% Set the parameters of OCF, to indicate the objective function is NC
para_NC_IE.F = F_NC_FG; 
para_NC_IE.is_maximize = 1; % NC should be maximized
para_NC_IE.X = X; 
para_NC_IE.operator_name = 'sum'; % use 'sum' operator for Eq. (8)

band_NC_IE = zeros([4,32]);

for i = 1 : 4
    % Selection
    
    band_NC_IE(i,1:i*8) = ocf(para_NC_IE, 8*i);
    
%band_set = ocf(para_NC_IE, k);
%sort(band_set)
end


