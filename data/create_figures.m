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
DATA_LENGTH = 10;
SLOPE = 0.4;
BIAS = 3;
XRANGE = [-5,5];

X = linspace(XRANGE(1)*2, XRANGE(2)*2, DATA_LENGTH*2);
Y = SLOPE .* X + BIAS;

%% fit to samples
[m1,b1] = fitl([XN;YN1]');
[m2,b2] = fitl([XN;YN2]');
[m3,b3] = fitl([XN;YN3]');
[m4,b4] = fitl([XN;YN4]');

YF1 = m1 .* X + b1;
YF2 = m2 .* X + b2;
YF3 = m3 .* X + b3;
YF4 = m4 .* X + b4;

%% set the colors
LINE_COLOR = [0.3, 0.3, 0.3];
FIT_COLOR = [0.9, 0.5, 0.5];
NOISY_COLOR = [0 0.7 0.7];

%% plot the data 1
figure,
plot(X, Y, 'Color', LINE_COLOR,'LineWidth', 3);
hold on;
plot(X, YF1, 'Color', FIT_COLOR,'LineWidth', 3);
scatter(XN, YN1, 80, 'MarkerEdgeColor',NOISY_COLOR .* 0.8, 'MarkerFaceColor', NOISY_COLOR, 'LineWidth',1.5');

% set the limits
xlim([XRANGE(1)-1, XRANGE(2)+1]);
ylim([floor(min(Y)), ceil(max(Y))]);
set(gca,'xtick',[(XRANGE(1)-1):(XRANGE(2)+1)])
grid on;
axis square
fig2svg('plot1.svg', '', 0, '', 2);

%% plot the data 2
figure,
plot(X, Y, 'Color', LINE_COLOR,'LineWidth', 3);
hold on;
plot(X, YF2, 'Color', FIT_COLOR,'LineWidth', 3);
scatter(XN, YN2, 80, 'MarkerEdgeColor',NOISY_COLOR .* 0.8, 'MarkerFaceColor', NOISY_COLOR, 'LineWidth',1.5');

% set the limits
xlim([XRANGE(1)-1, XRANGE(2)+1]);
ylim([floor(min(Y)), ceil(max(Y))]);
set(gca,'xtick',[(XRANGE(1)-1):(XRANGE(2)+1)])
grid on;
axis square
fig2svg('plot2.svg', '', 0, '', 2);

%% plot the data 3
figure,
plot(X, Y, 'Color', LINE_COLOR,'LineWidth', 3);
hold on;
plot(X, YF3, 'Color', FIT_COLOR,'LineWidth', 3);
scatter(XN, YN3, 80, 'MarkerEdgeColor',NOISY_COLOR .* 0.8, 'MarkerFaceColor', NOISY_COLOR, 'LineWidth',1.5');

% set the limits
xlim([XRANGE(1)-1, XRANGE(2)+1]);
ylim([floor(min(Y)), ceil(max(Y))]);
set(gca,'xtick',[(XRANGE(1)-1):(XRANGE(2)+1)])
grid on;
axis square
fig2svg('plot3.svg', '', 0, '', 2);

%% plot the data 4
figure,
plot(X, Y, 'Color', LINE_COLOR,'LineWidth', 3);
hold on;
plot(X, YF4, 'Color', FIT_COLOR,'LineWidth', 3);
scatter(XN, YN4, 80, 'MarkerEdgeColor',NOISY_COLOR .* 0.8, 'MarkerFaceColor', NOISY_COLOR, 'LineWidth',1.5');

% set the limits
xlim([XRANGE(1)-1, XRANGE(2)+1]);
ylim([floor(min(Y)), ceil(max(Y))]);
set(gca,'xtick',[(XRANGE(1)-1):(XRANGE(2)+1)])
grid on;
axis square
fig2svg('plot4.svg', '', 0, '', 2);