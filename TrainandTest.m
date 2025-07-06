%% Load Feature Matrix and Labels
load('FeatureMatrix.mat');  % Ensure 'feature_matrix' is loaded

% Define number of fault cases and relevant row range
num_fault_cases = 12; 
start_row = 2706;  % Fault data starts from this row
end_row = 18000;   % Last row of dataset

% Extract only fault-related rows
faulty_data = feature_matrix(start_row:end_row, :);  
num_samples = size(faulty_data, 1); % Number of rows with fault data

% Prepare storage for X and Y
X_total = zeros(num_samples * num_fault_cases, 6);  
Y_total = zeros(num_samples * num_fault_cases, num_fault_cases);  

% Extract each fault case
for i = 1:num_samples
    row_idx = (i - 1) * num_fault_cases;  % Compute base row index

    for fault = 1:num_fault_cases
        % Get correct columns for this fault type
        col_start = (fault - 1) * 6 + 1;
        col_end = col_start + 5;
        
        % Store feature data (I1, I2, I3, Vab, Vbc, Vca)
        X_total(row_idx + fault, :) = faulty_data(i, col_start:col_end);

        % Assign one-hot encoded label
        Y_total(row_idx + fault, fault) = 1;
    end
end

% Shuffle dataset (to ensure randomness in train-test split)
rand_idx = randperm(size(X_total, 1));
X_total = X_total(rand_idx, :);
Y_total = Y_total(rand_idx, :);

% Split into training (80%) and testing (20%)
train_size = floor(0.8 * size(X_total, 1));

X_train = X_total(1:train_size, :);
Y_train = Y_total(1:train_size, :);

X_test = X_total(train_size+1:end, :);
Y_test = Y_total(train_size+1:end, :);

% Verify correct splitting
disp('Sum of Y_train column-wise:'); disp(sum(Y_train, 1));
disp('Sum of Y_test column-wise:'); disp(sum(Y_test, 1));

