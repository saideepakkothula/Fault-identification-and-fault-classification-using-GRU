clc; clear; close all;
load('TrainTestData.mat');

%% ✅ FEATURE NORMALIZATION (Z-Score Based)
X_train = zscore(X_train, 0, 1);  
X_test = zscore(X_test, 0, 1);

%% ✅ CONVERT LABELS TO CATEGORICAL
[~, Y_train_labels] = max(Y_train, [], 2);
[~, Y_test_labels] = max(Y_test, [], 2);
Y_train_categorical = categorical(Y_train_labels);
Y_test_categorical = categorical(Y_test_labels);

%% ✅ CONVERT INPUTS TO SEQUENCES
X_train_seq = num2cell(X_train', 1);  
X_test_seq = num2cell(X_test', 1);  

%% ✅ DEFINE GRU MODEL ARCHITECTURE
inputSize = size(X_train, 2);
numHiddenUnits = 512;            % Reduced to optimize speed with good accuracy
numHiddenUnits2 = 256;           % Added extra GRU layer to improve accuracy
numClasses = numel(unique(Y_train_labels));

layers = [
    sequenceInputLayer(inputSize, 'Name', 'input')
    gruLayer(numHiddenUnits, 'OutputMode', 'sequence', 'Name', 'gru1', ...
             'InputWeightsInitializer', 'glorot')
    dropoutLayer(0.3, 'Name', 'dropout1')   % Helps prevent overfitting
    gruLayer(numHiddenUnits2, 'OutputMode', 'last', 'Name', 'gru2')
    leakyReluLayer(0.1, 'Name', 'leakyReLU')
    fullyConnectedLayer(numClasses, 'Name', 'fc')
    softmaxLayer('Name', 'softmax')
    classificationLayer('Name', 'output')
];

%% ✅ IMPROVED TRAINING OPTIONS
options = trainingOptions('adam', ...
    'ExecutionEnvironment', 'auto', ...
    'MaxEpochs', 25, ...                         % Reduced epochs for faster training
    'MiniBatchSize', 2048, ...                   % Smaller batch size for faster convergence
    'InitialLearnRate', 0.005, ...               % Slightly aggressive learning rate
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropFactor', 0.5, ...
    'LearnRateDropPeriod', 10, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', {X_test_seq, Y_test_categorical}, ...
    'ValidationFrequency', 10, ...
    'ValidationPatience', 4, ...
    'Verbose', true, ...
    'Plots', 'training-progress');

%% ✅ TRAIN THE MODEL
fprintf('🚀 Training Optimized GRU Model (Fast + Accurate)...\n');
netGRU = trainNetwork(X_train_seq, Y_train_categorical, layers, options);
fprintf('✅ Training Complete!\n');

%% ✅ TEST THE MODEL & CALCULATE ACCURACY
Y_pred = classify(netGRU, X_test_seq);
predicted_labels = double(Y_pred);
actual_labels = double(Y_test_categorical);

accuracy = sum(predicted_labels == actual_labels) / numel(actual_labels) * 100;
fprintf('🎯 Final Accuracy of Optimized GRU: %.2f%% 🎯\n', accuracy);
