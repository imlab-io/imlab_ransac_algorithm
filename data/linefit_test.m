%% line fit test
clear all, close all, clc;

%% create data samples
DATA_LENGTH = 10;
SLOPE = 0.4;
BIAS = 3;
XRANGE = [-5,5];

X = linspace(XRANGE(1)*2, XRANGE(2)*2, DATA_LENGTH*2);
Y = SLOPE .* X + BIAS;

[XN,YN1] = data_generate(DATA_LENGTH, 0.0, 0.0, SLOPE, BIAS, XRANGE);
[XN,YN2] = data_generate(DATA_LENGTH, 0.1, 0.0, SLOPE, BIAS, XRANGE);
[XN,YN3] = data_generate(DATA_LENGTH, 0.2, 0.2, SLOPE, BIAS, XRANGE);
[XN,YN4] = data_generate(DATA_LENGTH, 0.3, 0.4, SLOPE, BIAS, XRANGE);

% save the data
D1 = reshape([XN',YN1']', 1, []);
D2 = reshape([XN',YN2']', 1, []);
D3 = reshape([XN',YN3']', 1, []);
D4 = reshape([XN',YN4']', 1, []);

csvwrite('sampledata1.csv', D1);
csvwrite('sampledata2.csv', D2);
csvwrite('sampledata3.csv', D3);
csvwrite('sampledata4.csv', D4);
