%% compute number of iterations
q = [0.1 0.2 0.3 0.4]; % outlier ratio
K = 3; % number of samples
p = 0.8; % probability of success

Iter = ceil(log(1-p) ./ log(1 - (1-q).^K));