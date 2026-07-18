%% ISAC Deep Learning Project 3: Micro-Modulation Classifier
% Author: Malak ElSalamouny
% Description: This script builds a Multi-Layer Perceptron (MLP) Neural Network
%              to classify noisy signal samples as either BPSK or QPSK.
% GitHub Category: Deep Learning Foundations / Signal Intelligence

clear; clc; close all;

%% 1. Generate Raw Noisy I/Q Signal Data
disp('--- Generating Noisy Symbol Datasets ---');
num_symbols = 1000;
snr_db = 6; % Add high noise (Low SNR) to make it a challenge for the network

% --- Generate BPSK (2 States: 1, -1) ---
bpsk_bits = randi([0 1], num_symbols, 1);
bpsk_symbols = 1 - 2*bpsk_bits; 
bpsk_noisy = awgn(bpsk_symbols, snr_db, 'measured');
% Separate into flat real/imaginary array features [I, Q]
X_bpsk = [real(bpsk_noisy), imag(bpsk_noisy)];
Y_bpsk = categorical(repmat({'BPSK'}, num_symbols, 1));

% --- Generate QPSK (4 States: combinations of +/-0.707 +/-0.707i) ---
qpsk_bits = randi([0 3], num_symbols, 1);
qpsk_symbols = exp(1j * (qpsk_bits * pi/2 + pi/4));
qpsk_noisy = awgn(qpsk_symbols, snr_db, 'measured');
X_qpsk = [real(qpsk_noisy), imag(qpsk_noisy)];
Y_qpsk = categorical(repmat({'QPSK'}, num_symbols, 1));

% Combine Datasets
X_all = [X_bpsk; X_qpsk];
Y_all = [Y_bpsk; Y_qpsk];

%% 2. Partition into Train and Test Sets
cv = cvpartition(length(Y_all), 'HoldOut', 0.2);
X_train = X_all(training(cv), :);
Y_train = Y_all(training(cv), :);
X_test  = X_all(test(cv), :);
Y_test  = Y_all(test(cv), :);

%% 3. Define the Deep Learning Neural Network Architecture
% We define an explicit array of layer blocks spanning inputs to a Softmax probability output.
layers = [
    featureInputLayer(2, 'Name', 'Input_IQ_Samples') % Input: 2 dimensions (I and Q)
    
    fullyConnectedLayer(16, 'Name', 'Hidden_Layer_1') % 16 Neurons
    reluLayer('Name', 'ReLU_Activation_1')           % Non-linear activation
    
    fullyConnectedLayer(8, 'Name', 'Hidden_Layer_2')  % 8 Neurons
    reluLayer('Name', 'ReLU_Activation_2')
    
    fullyConnectedLayer(2, 'Name', 'Output_Layer')    % 2 Neurons (BPSK vs QPSK)
    softmaxLayer('Name', 'Probability_Softmax')       % Converts outputs to probabilities
    classificationLayer('Name', 'Classification_Output')];

%% 4. Configure Training Parameters (Optimized for Laptop CPU)
options = trainingOptions('adam', ...            % Adam optimizer
    'MaxEpochs', 30, ...                        % Pass through data 30 times
    'MiniBatchSize', 64, ...                    % Process 64 samples at a time
    'Shuffle', 'every-epoch', ...
    'ValidationData', {X_test, Y_test}, ...
    'ValidationFrequency', 20, ...
    'Verbose', false, ...
    'Plots', 'training-progress');              % Opens MATLAB's live training dashboard

%% 5. Train the Deep Neural Network
disp('--- Training Neural Network Classifier ---');
trained_net = trainNetwork(X_train, Y_train, layers, options);

%% 6. Evaluate and Visualize Performance
Y_predictions = classify(trained_net, X_test);
accuracy = sum(Y_predictions == Y_test) / length(Y_test) * 100;
fprintf('\nDeep Learning Classification Accuracy: %.2f%%\n', accuracy);

% Save an evaluation snapshot
figure('Position', [100, 100, 500, 400]);
confusionchart(Y_test, Y_predictions, 'Title', 'Deep Learning Modulation Confusion Matrix', ...
    'RowSummary', 'row-normalized', 'ColumnSummary', 'column-normalized');
saveas(gcf, 'modulation_results.png');
