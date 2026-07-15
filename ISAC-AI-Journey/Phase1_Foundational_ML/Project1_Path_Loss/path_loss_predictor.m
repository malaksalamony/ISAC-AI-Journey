%% ISAC Machine Learning: Signal Path Loss Predictor
% Author: Malak ElSalamouny
% Description: This project transitions from a traditional empirical wireless model to a 
%              data-driven Machine Learning approach. It synthetizes 
%              path loss data to train the model. Then a Regression Tree model is used to predict 
%              path loss based on distance and carrier frequency.
% GitHub Category: Foundational Machine Learning / Wireless ISAC Systems

clear; clc; close all;

%% 1. Generate Synthetic ISAC Data
disp('--- Generating Synthetic Dataset ---');
num_samples = 1000;

% Random distances between 10 meters and 500 meters
dist_min = 10;
dist_max = 500;
distance = dist_min + (dist_max-dist_min) * rand(num_samples, 1); 

% Random carrier frequencies between 2 GHz (Sub-6) and 28 GHz (mmWave)
frequency = 2 + (28-2) * rand(num_samples, 1); 
frequency_Hz = frequency*1e9;

% Standard Log-Distance Path Loss Model + Shadowing Noise (Gaussian)
% PL = 20*log10(d) + 20*log10(f) + Constant + Noise
c = 3e8; % Speed of light
shadowing_std = 3; % 3 dB standard deviation noise
noise = shadowing_std * randn(num_samples, 1);

% True physical path loss formula (Theoritical Value)
true_path_loss = 20*log10(distance) + 20*log10(frequency_Hz) - 147.55 + noise;

% Generate the training set table for ML training
dataset = table(distance, frequency, true_path_loss, ...
    'VariableNames', {'Distance_m', 'Frequency_GHz', 'PathLoss_dB'});

head(dataset) % Display first few rows

%% 2. Split Data into Training and Testing Sets
disp('--- Splitting Data (80% Train, 20% Test) ---');
cv = cvpartition(num_samples, 'HoldOut', 0.2); %Cross-validation partition
train_data = dataset(training(cv), :);
test_data  = dataset(test(cv), :);

% Extract predictors (X) and response (Y)
X_train = train_data{:, {'Distance_m', 'Frequency_GHz'}};
Y_train = train_data{:, 'PathLoss_dB'};
X_test  = test_data{:, {'Distance_m', 'Frequency_GHz'}};
Y_test  = test_data{:, 'PathLoss_dB'};

%% 3. Train Machine Learning Model (Regression Tree)
disp('--- Training Regression Tree Model ---');
% Using a simple, fast regression tree optimized for laptop CPUs
%If you do not limit MaxNumSplits, MATLAB will let the tree grow indefinitely 
% until it memorizes every single noisy data point.By capping the splits at 20, 
% we force the tree to learn the overall physical trend (distance and frequency impacts) 
% while ignoring the random channel noise (Overfitting prevention).

ml_model = fitrtree(X_train, Y_train, 'MaxNumSplits', 20);

%% 4. Evaluate Model Performance
disp('--- Evaluating Model on Test Data ---');
Y_predictions = predict(ml_model, X_test);

% Calculate Performance Metrics
rmse = sqrt(mean((Y_test - Y_predictions).^2));
mae = mean(abs(Y_test - Y_predictions));
fprintf('Root Mean Squared Error (RMSE): %.2f dB\n', rmse);
fprintf('Mean Absolute Error (MAE): %.2f dB\n', mae);

%% 5. Visualize Results
figure('Position', [100, 100, 900, 400]);

% Plot 1: True vs Predicted Path Loss
subplot(1, 2, 1);
scatter(Y_test, Y_predictions, 25, 'b', 'filled', 'MarkerFaceAlpha', 0.5);
hold on;
plot([min(Y_test) max(Y_test)], [min(Y_test) max(Y_test)], 'r--', 'LineWidth', 2);
xlabel('True Path Loss (dB)');
ylabel('Predicted Path Loss (dB)');
title('Model Accuracy Evaluation');
grid on;
legend('Predicted Points', 'Perfect Prediction Line', 'Location', 'NorthWest');

% Plot 2: 3D Learned Decision Surface
subplot(1, 2, 2);
[d_mesh, f_mesh] = meshgrid(10:10:500, 2:1:28);
X_grid = [d_mesh(:), f_mesh(:)];
Y_grid = predict(ml_model, X_grid);
pl_mesh = reshape(Y_grid, size(d_mesh));

surf(d_mesh, f_mesh, pl_mesh, 'EdgeColor', 'none');
xlabel('Distance (m)');
ylabel('Frequency (GHz)');
zlabel('Predicted Path Loss (dB)');
title('Learned Path Loss Decision Surface');
colorbar;
view(-45, 30);

% Save figure for GitHub README
saveas(gcf, 'path_loss_results.png');
disp('--- Figure saved as path_loss_results.png ---');
