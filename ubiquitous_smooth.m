%% smooth before relpow plot
% Apply Gaussian smoothing to relpow
sigma = 1; % Standard deviation for Gaussian kernel
relpow = imgaussfilt(relpow, sigma);