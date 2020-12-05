%% line fit test
clear all, close all, clc;

% load the noisy data
D1 = csvread('sampledata1.csv');
D2 = csvread('sampledata2.csv');
D3 = csvread('sampledata3.csv');
D4 = csvread('sampledata4.csv');

% create X,Y
XN = D1(1:2:end);
YN1 = D1(2:2:end);
YN2 = D2(2:2:end);
YN3 = D3(2:2:end);
YN4 = D4(2:2:end);

%% create data samples
DATA_LENGTH = 100;
SLOPE = 0.4;
BIAS = 3;
XRANGE = [-5,5];
DISTANCE = 0.5;

X = linspace(XRANGE(1)*2, XRANGE(2)*2, DATA_LENGTH*2);
Y = SLOPE .* X + BIAS;

% get the y to new variable
S = 4;
YN = YN4;
% [XN,YN] = data_generate(DATA_LENGTH, 0.2, 0.4, SLOPE, BIAS, XRANGE);

SelectedIDX = [1 3 5; 1 8 9; 3 5 4; 1 8 10]; %randi(DATA_LENGTH-1, [1,20])+1;

%% set the colors
LINE_COLOR = [0.3, 0.3, 0.3];
FIT_COLOR = [0.9, 0.5, 0.5];
NOISY_COLOR = [0 0.7 0.7];
SELECTED_COLOR = [0.7 0.9 0.5];
DISTANCE_COLOR = [0.9 0.1 0.1];

for i = 1:size(SelectedIDX,1)
    
    % fit to samples
    [m,b] = fitl([XN(SelectedIDX(i,:));YN(SelectedIDX(i,:))]');
    YF = m .* X + b;
    YFp = YF + DISTANCE / cos(atan(m));
    YFn = YF - DISTANCE / cos(atan(m));

    %% plot the data 1
    figHandle = figure;
    hold on;
    patch([X fliplr(X)], [YFp fliplr(YFn)], DISTANCE_COLOR, 'FaceAlpha', 0.1);

    plot(X, Y, 'Color', LINE_COLOR,'LineWidth', 3);
    plot(X, YFp, 'Color', DISTANCE_COLOR,'LineWidth', 1, 'LineStyle', '-.');
    plot(X, YFn, 'Color', DISTANCE_COLOR,'LineWidth', 1, 'LineStyle', '-.');
    
    plot(X, YF, 'Color', FIT_COLOR,'LineWidth', 3);
    scatter(XN, YN, 80, 'MarkerEdgeColor',NOISY_COLOR .* 0.8, 'MarkerFaceColor', NOISY_COLOR, 'LineWidth',1.5');
    scatter(XN(SelectedIDX(i,:)), YN(SelectedIDX(i,:)), 80, 'MarkerEdgeColor',SELECTED_COLOR .* 0.8, 'MarkerFaceColor', SELECTED_COLOR, 'LineWidth',1.5');

    % set the limits
    xlim([XRANGE(1)-1, XRANGE(2)+1]);
    ylim([floor(min(Y)), ceil(max(Y))]);
    set(gca,'xtick',[(XRANGE(1)-1):(XRANGE(2)+1)])
    grid on;
    axis square
    
    fig2svg(sprintf('ransac_example_%d%d.svg', S, i), '', 0, '', 2);
end