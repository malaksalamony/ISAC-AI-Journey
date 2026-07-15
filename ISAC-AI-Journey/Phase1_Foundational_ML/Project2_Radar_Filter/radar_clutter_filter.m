%% ISAC Machine Learning Project 2: Radar Target Clutter Filter
% Author: Your Name
% Description: This script implements a binary Classification model using a 
%              Support Vector Machine (SVM). It separates moving "Targets" 
%              (vehicles) from background "Clutter" (trees, buildings) based 
%              on Doppler Shift and Received Signal Strength (RSS).
% GitHub Category: Foundational Machine Learning / Radar Sensing

clear; clc; close all;

%% 1. Generate Synthetic Radar Return Data
disp('--- Generating Synthetic Radar Returns ---');
num_samples_per_class = 500;

% Class 0: Environmental Clutter (low Doppler, varied/high RSS reflections)
% e.g., swaying trees, buildings
doppler_clutter = 0 + 2 * randn(num_samples_per_class, 1); % Centered near 0 Hz
rss_clutter = -50 + 8 * randn(num_samples_per_class, 1);   % Weak to strong returns
label_clutter = zeros(num_samples_per_class, 1);           % Label 0 = Clutter

% Class 1: Valid Targets (moving vehicles with significant Doppler shift)
doppler_target = 35 + 10 * randn(num_samples_per_class, 1); % High velocity shift
rss_target = -35 + 5 * randn(num_samples_per_class, 1);     % Stronger, consistent reflections
label_target = ones(num_samples_per_class, 1);              % Label 1 = Target

% Combine into a single dataset
Doppler = [doppler_clutter; doppler_target];
RSS = [rss_clutter; rss_target];
Label = [label_clutter; label_target];

dataset = table(Doppler, RSS, Label, 'VariableNames', {'Doppler_Hz', 'RSS_dBm', 'Class'});

%% 2. Split Data (80% Train, 20% Test)
cv = cvpartition(height(dataset), 'HoldOut', 0.2);
train_data = dataset(training(cv), :);
test_data  = dataset(test(cv), :);

X_train = train_data{:, {'Doppler_Hz', 'RSS_dBm'}};
Y_train = train_data{:, 'Class'};
X_test  = test_data{:, {'Doppler_Hz', 'RSS_dBm'}};
Y_test  = test_data{:, 'Class'};

%% 3. Train a Support Vector Machine (SVM) Classifier
disp('--- Training Linear Support Vector Machine ---');
% fitcsvm trains a binary SVM optimized for quick laptop execution
svm_model = fitcsvm(X_train, Y_train, 'KernelFunction', 'linear', 'Standardize', true);

%% 4. Evaluate Classifier Performance
Y_predictions = predict(svm_model, X_test);

% Calculate Accuracy and Confusion Matrix
accuracy = sum(Y_predictions == Y_test) / length(Y_test) * 100;
fprintf('Classification Accuracy on Test Data: %.2f%%\n', accuracy);

% Generate Confusion Matrix values
[C, order] = confusionmat(Y_test, Y_predictions);
false_alarms = C(1,2); % Clutter classified as Target
missed_targets = C(2,1); % Target classified as Clutter
fprintf('False Alarms (Clutter flagged as Target): %d\n', false_alarms);
fprintf('Missed Targets (Target ignored as Clutter): %d\n', missed_targets);

%% 5. Visualize Decision Boundary for GitHub Documentation
figure('Position', [100, 100, 900, 450]);

% Plot 1: Test Data Classification Results
subplot(1, 2, 1);
gscatter(X_test(:,1), X_test(:,2), Y_test, ['r', 'b'], ['o', 'x']);
hold on;

% Draw the separating hyperplane (Decision Boundary)
beta = svm_model.Beta;
bias = svm_model.Bias;
% Scale adjustments due to standardization
mu = svm_model.Mu;
sigma = svm_model.Sigma;

x_boundary = linspace(min(Doppler), max(Doppler), 100);
% Boundary equation: beta(1)*((x-mu1)/sigma1) + beta(2)*((y-mu2)/sigma2) + bias = 0
y_boundary = (((-bias - beta(1)*((x_boundary - mu(1))/sigma(1))) / beta(2)) * sigma(2)) + mu(2);

plot(x_boundary, y_boundary, 'k-', 'LineWidth', 2);
xlabel('Doppler Frequency Shift (Hz)');
ylabel('Received Signal Strength (dBm)');
title('Radar Target vs Clutter Separation');
legend('Clutter (Static)', 'Target (Moving Vehicle)', 'SVM Decision Boundary', 'Location', 'Best');
grid on;


% Plot 2: Confusion Matrix Heatmap
subplot(1, 2, 2);
confusionchart(Y_test, Y_predictions, 'Title', 'Radar Classifier Confusion Matrix', ...
    'RowSummary', 'row-normalized', 'ColumnSummary', 'column-normalized');

% Save visualization artifact
saveas(gcf, 'radar_clutter_results.png');
disp('--- Visualization saved as radar_clutter_results.png ---');
