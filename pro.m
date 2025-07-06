clc; clear; close all;

%% ================== Initialize Simulation Model ==================
model = 'FaultDetectionSim';  % Ensure this matches your Simulink model name

% Check if the Simulink model exists and open it
if exist([model, '.slx'], 'file')
    load_system(model);
else
    error('❌ Error: Simulink model "%s" not found. Ensure it is in the correct path.', model);
end

% Define Fault Types
fault_types = {'NoFault', 'AG', 'BG', 'CG', 'AB', 'BC', 'CA', ...
               'ABG', 'BCG', 'CAG', 'ABC', 'ABCG'};

%% ================== Choose Data Source ==================
choice = menu('Select Data Source:', ...
              'Run New Fault Simulations', ...
              'Use Existing Fault Data');

if choice == 2
    % ============= Load Existing Fault Data =============
    disp('✅ Loading previously saved fault data...');
    
    for i = 1:length(fault_types)
        file_name = sprintf('FaultData_%s.mat', fault_types{i});
        
        if exist(file_name, 'file')
            fprintf('✅ Loaded: %s\n', file_name);
        else
            warning('⚠️ Missing file: %s', file_name);
        end
    end
    
    disp('✅ All available fault data checked.');
    return;

elseif choice == 0
    disp('❌ Operation canceled by the user.');
    return;
end

%% ================== Fresh Simulation Mode ==================
disp('🔄 Running New Fault Simulations...');
fault_block_path = strcat(model, '/Three-Phase Fault');
remaining_faults = fault_types;  % Copy of available faults

while ~isempty(remaining_faults)
    % ================== Choose Fault Type ==================
    fault_idx = menu('Select Fault Type:', remaining_faults);
    
    if fault_idx == 0
        disp('❌ Simulation canceled by the user.');
        return;
    end
    
    fault_name = remaining_faults{fault_idx};
    safe_fault_name = strrep(fault_name, ' ', '_');  % Safe variable name
    
    fprintf('\n⚡ Simulating Fault: %s...\n', fault_name);
    
    % ================== User Input for Fault Timing ==================
    fault_start_time = input('Enter the fault start time (in sec): ');
    fault_end_time = input('Enter the fault end time (in sec): ');

    % Set Fault Timing in Simulink
    set_param(fault_block_path, 'SwitchTimes', mat2str([fault_start_time, fault_end_time]));

    % Reset all faults before applying a new one
    set_param(fault_block_path, 'FaultA', 'off', 'FaultB', 'off', 'FaultC', 'off', 'GroundFault', 'off');

    % ================== Apply Selected Fault Configuration ==================
    fault_map = containers.Map(... 
        {'AG', 'BG', 'CG', 'AB', 'BC', 'CA', 'ABG', 'BCG', 'CAG', 'ABC', 'ABCG'}, ...
        {{'FaultA', 'GroundFault'}, {'FaultB', 'GroundFault'}, {'FaultC', 'GroundFault'}, ... % ✅ Fixed LG faults
         {'FaultA', 'FaultB'}, {'FaultB', 'FaultC'}, {'FaultC', 'FaultA'}, ...
         {'FaultA', 'FaultB', 'GroundFault'}, {'FaultB', 'FaultC', 'GroundFault'}, {'FaultC', 'FaultA', 'GroundFault'}, ...
         {'FaultA', 'FaultB', 'FaultC'}, {'FaultA', 'FaultB', 'FaultC', 'GroundFault'}});

    if isKey(fault_map, fault_name)
        fault_params = fault_map(fault_name);
        for j = 1:length(fault_params)
            set_param(fault_block_path, fault_params{j}, 'on');
        end
    end

    % ================== Run Simulation ==================
    simOut = sim(model);
    
    % Extract Data
    time = simOut.tout;
    
    try
        % ✅ Extracting Signals
        I1 = simOut.I1.Data;
        I2 = simOut.I2.Data;
        I3 = simOut.I3.Data;
        Vab = simOut.Vab.Data;
        Vbc = simOut.Vbc.Data;
        Vca = simOut.Vca.Data;
    catch
        error('❌ Error: Signal names in Simulink model do not match expected variables (I1, I2, I3, Vab, Vbc, Vca).');
    end

    % ================== Save Data ==================
    fault_data = struct('Time', time, 'I1', I1, 'I2', I2, 'I3', I3, 'Vab', Vab, 'Vbc', Vbc, 'Vca', Vca);
    file_name = sprintf('FaultData_%s.mat', safe_fault_name);
    save(file_name, '-struct', 'fault_data');

    fprintf('✅ %s saved\n', file_name);

    % ✅ Displaying Sample Data (3500:3510) in Command Window
    range = 3500:3510; 
    if length(time) >= max(range)  % Ensure we have enough data points
        fprintf('\n📊 Selected Samples for Fault: %s\n', fault_name);
        disp(table(time(range), I1(range), I2(range), I3(range), ...
                   Vab(range), Vbc(range), Vca(range), ...
                   'VariableNames', {'Time', 'I1', 'I2', 'I3', 'Vab', 'Vbc', 'Vca'}));
    else
        warning('⚠️ Not enough data points for display. Consider adjusting the range.');
    end

    % Remove performed fault from menu
    remaining_faults(fault_idx) = [];

    % Check if any faults remain
    if isempty(remaining_faults)
        break;
    end
    
    % Ask if user wants to run another simulation
    another_sim = menu('Do you want to run another fault simulation?', 'Yes', 'No');
    if another_sim == 2
        break;
    end
end

disp('✅ All fault cases completed. All .mat files saved.');

