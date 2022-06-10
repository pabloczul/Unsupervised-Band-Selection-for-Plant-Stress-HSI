function [selected_bands] = ocf_trc_fdpc(X,bands)
%ocf_trc_fdpc X': HSI data for band selection, 'bands': number of
%spectral bands to select (int)
%   optimal clustering framework with FDPC ranking and TRC
%objective function

% Achieve the ranking values of band via E-FDPC algorithm

X = permute(X,[2,1])

[L, ~] = size(X);
D = E_FDPC_get_D(X');
[~, bnds_rnk_FDPC] = E_FDPC(D, L);

% Construct a similarity graph
S_FG = get_graph(X);

% Get the map f in Eq. (16)
F_TRC_FDPC = get_F_TRC(S_FG, bnds_rnk_FDPC);

% Set the parameters of OCF, to indicate the objective function is TRC
para_TRC_FDPC.bnds_rnk = bnds_rnk_FDPC;
para_TRC_FDPC.F = F_TRC_FDPC;
para_TRC_FDPC.is_maximize = 0; % TRC should be minimized
para_TRC_FDPC.X = X; 
para_TRC_FDPC.operator_name = 'max'; % use 'max' operator for Eq. (8)

% Selection
selected_bands = sort(ocf(para_TRC_FDPC, bands));
        
end