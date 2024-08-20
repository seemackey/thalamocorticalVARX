clear 
% load  continuous electrophysiological data and trigger times
load('H:\data\jiggle\simultaneous\rb023imported_nojit.mat'); % assuming this loads variables data1, data2, trigtimes


%selected channels by user, not working yet, selecting 1:21
selchans1 = 1:21; % medial genic.
selchans2 = 1:21; % cortex
% truncate chans
LFP1 = LFP1(selchans1,:);
CSD2 = CSD2(selchans2,:);


% transpose the data
LFP1 = LFP1'; % Transposed to [154886, 21]
CSD2 = CSD2'; % Transposed to [154886, 21]

% Combine the recordings from the two brain regions
y = [LFP1, CSD2]; % Combine into one matrix [154886, 42]
%yname = [repmat({'MGB_Channel'}, 1, 21), repmat({'A1_Channel'}, 1, 21)];
%Create unique channel names for each channel
yname = [strcat('MGB_', arrayfun(@num2str, selchans1, 'UniformOutput', false)), ...
         strcat('A1_', arrayfun(@num2str, selchans2, 'UniformOutput', false))];

% Create exogenous input matrix x based on trigtimes
x = zeros(size(y, 1), 1); % Initialize x with zeros, size(x) should now be [154886, 1]

% Mark the stimulus as "on" for 25 ms (25 samples) after each trigger time
for i = 1:length(trigtimes)
    onset = trigtimes(i);
    offset = min(onset + 24, size(x, 1)); % Ensure we don't exceed the length of x
    x(onset:offset) = 1; % Mark stimulus as "on" for 25 ms
end
xname = {'Stimulus'};

% Define the FIR filter h (e.g., a Gaussian or a simple moving average)
% Example: Moving average filter
h = ones(5, 1) / 5; % A simple moving average filter over 5 samples (5 ms)
xlags = length(h); % The length of the filter

% Apply the filter using filterMIMO
[filtered_x, H] = filterMIMO(h, x, xlags);

% Check dimensions to ensure consistency
disp(size(y)); % e.g [154886, 42]
disp(size(filtered_x)); % e.g. [154886, 1]

% Define the VARX model parameters
na = 10; % Order of autoregression
nb = 20; % Number of lags for the exogenous input
lambda = 0; % Regularization parameter

% Fit the VARX model using the filtered exogenous input
model = varx(y, na, filtered_x, nb, lambda);

% Simulate the output using the model
yest = varx_simulate(model.B, model.A, filtered_x, y);

% Visualization of the original and estimated outputs
figure(1);
show_prediction(filtered_x, y, yest);

% Display the VARX model
figure(2);
varx_display(model, 'xname', xname, 'yname', yname, 'duration', nb, 'plottype', 'Graph');

% ----------------- result display function --------------------------
function show_prediction(x,y,yest)

clf
ydim = size(y,2);
xdim = size(x,2);
for i=1:ydim
    subplot(2,2,1); plot(x); title('External Inputs');
    subplot(2,2,2); plot(y); title('Recursive Input');
    subplot(2,ydim,ydim*1+i);
    plot([y(:,i) yest(:,i)]) % compare original to estimated output
    title(['Target and estimated output ' num2str(i)])
end

end