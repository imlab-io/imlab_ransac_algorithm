function [X,YN] = data_generate(DATA_LENGTH, NOISE, OUTLIER_RATIO, SLOPE, BIAS, XRANGE)
    
    % create data
    X = linspace(XRANGE(1), XRANGE(2), DATA_LENGTH);
    Y = SLOPE * X + BIAS;
    YN = Y + NOISE * randn(size(Y));

    % create some outliers
    for i = 1:(OUTLIER_RATIO * DATA_LENGTH)
        s = round((DATA_LENGTH-1) * rand() + 1);
        % create random sample in Y range
        YN(s) = (max(Y) - min(Y)) * rand() + min(Y);
    end
end

