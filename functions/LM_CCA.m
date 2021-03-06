function [Ax,Ay,Q] = LM_CCA(x,y,opt)
%
% LM_CCA
% Part of the Linear Model (LM) package.
% Author: Octave Etard
%
% Implement CCA between x and y with regularisation options as specified in
% opt.
%
% Inputs x and y are not be normalised in this function.
%
%
if nargin < 3
    opt.x = [];
    opt.y = [];
end
if ~isfield(opt,'x')
    opt.x = [];
end
if ~isfield(opt,'y')
    opt.y = [];
end


%% regularised PCA
[V,S] = LM_regEigen(x, false, opt.x);
[N,O] = LM_regEigen(y, false, opt.y);


%%
S = 1 ./ sqrt(S);
O = 1 ./ sqrt(O);

% C = diag(O) * N' * y' * x * V * diag(S);
[P,Q,R] = svd( O .* (N' * (y' * x) * V) .* S','econ');
% returning a vector
Q = diag(Q); % already sorted

Ax = V * (S .* R);
Ay = N * (O .* P);


end
%
%