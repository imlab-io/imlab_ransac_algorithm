function [m,b] = fitl(sdata)

    % create temp variables
    samplesize = size(sdata, 1);
    xsum = 0;
    ysum = 0;
    xxsum = 0;
    xysum = 0;

    for s = 1:samplesize
        x = sdata(s,1);
        y = sdata(s,2);

        % compute the necessary variables for fitting
        xsum = xsum + x;
        ysum = ysum + y;
        xysum = xysum + x*y;
        xxsum = xxsum + x*x;
    end

    % use the line fit formulation and compute the line parameters
    m = (samplesize * xysum - xsum * ysum) / (samplesize * xxsum - xsum * xsum);
    b = (ysum - m * xsum) / samplesize;

end