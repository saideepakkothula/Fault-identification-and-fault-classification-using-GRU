clc; clear; close all;

%% ================ Define Fault Types ====================
fault_types = {'NoFault', 'AG', 'BG', 'CG', 'AB', 'BC', 'CA', ...
               'ABG', 'BCG', 'CAG', 'ABC', 'ABCG'};

num_samples = 18000;  % Number of data samples
num_faults = length(fault_types); % Total 12 faults including No Fault
num_features_per_fault = 6;  % Features per fault (I1, I2, I3, Vab, Vbc, Vca)

%% ================ Initialize Feature Matrix ================
% Matrix of size (18000 x 72) for features
feature_matrix = strings(num_samples, num_faults * num_features_per_fault);

for i = 1:num_faults
    fault_name = fault_types{i};
    file_name = sprintf('FaultData_%s.mat', fault_name);

    if exist(file_name, 'file')
        fprintf('✅ Loading: %s\n', file_name);
        
        % Load fault data
        data = load(file_name);

        % Validate required fields exist
        required_fields = {'I1', 'I2', 'I3', 'Vab', 'Vbc', 'Vca'};
        if all(isfield(data, required_fields))
            
            % Extract first 18000 samples and place them in the correct column range
            feature_matrix(:, (i-1)*num_features_per_fault + (1:num_features_per_fault)) = ...
                [string(data.I1(1:num_samples)), string(data.I2(1:num_samples)), string(data.I3(1:num_samples)), ...
                 string(data.Vab(1:num_samples)), string(data.Vbc(1:num_samples)), string(data.Vca(1:num_samples))];
        else
            warning('⚠️ Missing required fields in %s', file_name);
        end
    else
        warning('⚠️ File missing: %s', file_name);
    end
end

%% ================ Append GCBA Encoding Row (String Format) ================
gcba_encoding = [ ...
    "0000","0000","0000","0000","0000","0000", ...
    "1001","1001","1001","1001","1001","1001", ...
    "1010","1010","1010","1010","1010","1010", ...
    "1100","1100","1100","1100","1100","1100", ...
    "0011","0011","0011","0011","0011","0011", ...
    "0110","0110","0110","0110","0110","0110", ...
    "1010","1010","1010","1010","1010","1010", ...
    "1101","1101","1101","1101","1101","1101", ...
    "1110","1110","1110","1110","1110","1110", ...
    "1011","1011","1011","1011","1011","1011", ...
    "0111","0111","0111","0111","0111","0111", ...
    "1111","1111","1111","1111","1111","1111" ...
];

% Append GCBA encoding row (Final matrix size: 18001x72, all strings)
feature_matrix = [feature_matrix; gcba_encoding];

fprintf('✅ Matrix Construction Completed. Size: [%d x %d]\n', size(feature_matrix,1), size(feature_matrix,2));

%% ================ Save Feature Matrix ====================
save('FeatureMatrix.mat', 'feature_matrix');
fprintf('✅ Feature Matrix saved as FeatureMatrix.mat\n');
