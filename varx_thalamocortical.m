 % load  continuous electrophysiological data and trigger times
%load('your_data.mat'); % assuming this loads variables data1, data2, trigtimes

% Combine the recordings from the two brain regions
% Assuming data1 and data2 are [T, 21] matrices
y = [CSD1, CSD2]; % Combine into one matrix [T, 42]
yname = [repmat({'MGB_Channel'}, 1, 21), repmat({'A1_Channel'}, 1, 21)];

% Create exogenous input matrix x based on trigtimes
% This is a simple example where we create a binary vector indicating stimulus onsets
x = zeros(size(y, 1), 1); % Initialize x
x(trigtimes) = 1; % Mark stimulus times with 1
xname = {'Stimulus'};

% Define the VARX model parameters
na = 10; % Order of autoregression
nb = 20; % Number of lags for the exogenous input
lambda = 0; % Regularization parameter

% Fit the VARX model
model = varx(y, na, x, nb, lambda);

% Simulate the output using the model
yest = varx_simulate(model.B, model.A, x, y);

% Visualization of the original and estimated outputs
figure(1);
show_prediction(x, y, yest);

% Display the VARX model
figure(2);
varx_display(model, xname=xname, yname=yname, duration=nb, plottype='Graph');
