%% ISAC Generative AI Project 4: Synthetic Channel Condition Generator
% Author: Your Name
% Description: This script implements a Generative Autoencoder Neural Network.
%              It learns the underlying statistical distribution of 2x2 MIMO 
%              channel matrices (H) and generates synthetic channel profiles.
% GitHub Category: Generative AI / Wireless Channel Modeling

clear; clc; close all;

%% 1. Generate Synthetic 2x2 MIMO Channel Matrices (Training Data)
disp('--- Generating Base Channel Matrices (Rayleigh Fading) ---');
num_channels = 2000;

% Generate random complex 2x2 MIMO channels (Real and Imaginary parts)
% H = [h11, h12; h21, h22] -> 4 complex coefficients = 8 real dimensions
H_real = (randn(num_channels, 2, 2) + 1j*randn(num_channels, 2, 2)) / sqrt(2);

% Flatten the 2x2 complex matrices into 8 real scalar features for the network
% [Real(h11), Imag(h11), Real(h12), Imag(h12), ...]
X_data = zeros(num_channels, 8);
for i = 1:num_channels
    matrix = H_real(i, :, :);
    X_data(i, :) = [real(matrix(1)), imag(matrix(1)), real(matrix(2)), imag(matrix(2)), ...
                    real(matrix(3)), imag(matrix(3)), real(matrix(4)), imag(matrix(4))];
end

%% 2. Define and Train the Generative Autoencoder
disp('--- Training Autoencoder Layer Network ---');

% Define network dimensions
input_dim = 8;
latent_dim = 3; % Compression bottleneck (Latent Space)

% Train the Autoencoder using the Deep Learning / Stats Toolbox
% Autoencoders try to reconstruct their own input: Input -> Latent -> Output
% Train the Autoencoder using the Deep Learning / Stats Toolbox
autoenc = trainAutoencoder(X_data', latent_dim, ...
    'MaxEpochs', 200, ...
    'L2WeightRegularization', 0.001, ...
    'SparsityRegularization', 4, ...
    'SparsityProportion', 0.05, ... % <--- FIXED PARAMETER NAME
    'DecoderTransferFunction', 'purelin', ...
    'ScaleData', false, ...
    'ShowProgressWindow', false);

%% 3. Generate Brand New Channel Profiles (The Generative Phase)
disp('--- Generating Brand New Synthetic Channels ---');
num_generated = 500;

% Sample random vectors from the learned latent space distribution
% We find the standard deviation of the true data's latent representation
latent_features = encode(autoenc, X_data');
latent_std = std(latent_features, 0, 2);

% Generate new random latent codes
random_latent = randn(latent_dim, num_generated) .* latent_std;

% Decode the random latent codes back into the original 8-dimensional space
X_generated = decode(autoenc, random_latent)';

%% 4. Visualize and Contrast Real vs. Generated Data Distributions
figure('Position', [100, 100, 950, 450]);

% Plot 1: Distribution of the first channel coefficient (h11 Real Part)
subplot(1, 2, 1);
histogram(X_data(:, 1), 'Normalization', 'pdf', 'FaceColor', 'b', 'FaceAlpha', 0.5);
hold on;
histogram(X_generated(:, 1), 'Normalization', 'pdf', 'FaceColor', 'r', 'FaceAlpha', 0.5);
xlabel('Amplitude Value');
ylabel('Probability Density');
title('Real vs Generated Distribution (h11 Real)');
legend('Original Rayleigh Data', 'Generative AI Synthetic Data');
grid on;

% Plot 2: Scatter plot of h11 vs h12 (Checking correlation mapping)
subplot(1, 2, 2);
scatter(X_data(1:500, 1), X_data(1:500, 3), 20, 'b', 'filled', 'MarkerFaceAlpha', 0.4);
hold on;
scatter(X_generated(:, 1), X_generated(:, 3), 20, 'r', 'x', 'MarkerFaceAlpha', 0.6);
xlabel('h11 (Real Component)');
ylabel('h12 (Real Component)');
title('Spatial Covariance Mapping');
legend('Original Channels', 'AI-Generated Channels');
grid on;

% Save asset for GitHub documentation
saveas(gcf, 'generative_channel_results.png');
disp('--- Graphic saved as generative_channel_results.png ---');
