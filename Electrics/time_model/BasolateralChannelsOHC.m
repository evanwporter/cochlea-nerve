function [channels] = BasolateralChannelsOHC()

% Not really for OHC -> just to test

% Parameters from Lopez-Poveda and Eustaquio-Martin 2006

% OHC mechanical conductance parameters
% Gl = 0.33e-9;                  % Apical leakege conductance
% gmax = 9.45e-9;                % Apical conductance with all channels fully open (to determine the apical mechanical conductance) [S]
% s0 = [63.1 12.7].*1e-9;        % Displacement sensitivity (1/m)
% u0 = [52.7 29.4].*1e-9;        % Displacement offset (m)

% Et = 100e-3;       		     % Endococlear potential [V] (Kros and Crawford value)
% Ekf = -78e-3;				     % Revelsal potential [V]
% Eks = -75e-3;				     % Revelsal potential [V]

% Ca = 0.895e-12;	             % Apical capacitante
% Cb = 8e-12;                    % Basal conductance

% Rp = 0.01;                     % Shamma epithelium resistance
% Rt = 0.24;                     % Shamma epithelium resistance

FAC = 1;

V_offset = 0;
% V_offset = -15e-3; % to be more like Johnson2011


fast_channel = struct( ...
    'version', 'LopezPoveda_2006', ...
    'name', 'OHC_fast', ...
    'var_name', 'popen_OHC_fast', ...
    'index', NaN, ...
    'order', 2, ...                % order of the ODE
    'voltage', 'OHC', ...
    ...
    'parameters', struct( ...
                'G',    FAC*30.7262e-9, ...	   % Maximum conductance of fast channel
                'V1',  V_offset + -43.2029e-3, ...        % Half-activation setpoint of fast channel
                'S1',   11.9939e-3, ...	       % Voltage sensitivity constant of fast channel
                'V2',  V_offset + -64.4e-3, ...           % Half-activation setpoint of fast channel
                'S2',    9.6e-3, ...		   % Voltage sensitivity constant of fast channel
                ...
                'T1min', 0.10e-3, ...
                'T1max', 0.33e-3, ...
                'aT1',  31.25e-3, ...
                'bT1',   5.42e-3, ...
                ...
                'T2min', 0.09e-3, ...
                'T2max', 0.10e-3, ...
                'aT2',   1e-3, ...
                'bT2',   1e-3));
    


slow_channel = struct( ...
    'version', 'LopezPoveda_2006', ...
    'name', 'OHC_slow', ...
    'var_name', 'popen_OHC_slow', ...
    'index', NaN, ...
    'order', 2, ...                % order of the ODE
    'voltage', 'OHC', ...
    ...
    'parameters', struct( ...
                'G',    FAC*28.7102e-9, ...        % Maximum conductance of slow channel
                'V1',  V_offset + -52.2228e-3, ...        % Half-activation setpoint of slow channel
                'S1',   12.6626e-3, ...        % Voltage sensitivity constant of slow channel
                'V2',  V_offset + -85.2228e-3, ...        % Half-activation setpoint of slow channel
                'S2',   16.9e-3, ...		   % Voltage sensitivity constant of slow channel
                ...
                'T1min', 1.30e-3, ...
                'T1max', 9.90e-3, ...
                'aT1',  15.27e-3, ...
                'bT1',   7.27e-3, ...
                ...
                'T2min', 0.01e-3, ...
                'T2max', 4.27e-3, ...
                'aT2',  48.20e-3, ...
                'bT2',   8.72e-3));

fast_channel_A = struct( ...
    'version', 'LopezPoveda_2006', ...
    'name', 'OHC_A', ...
    'var_name', 'popen_OHC_A', ...
    'index', NaN, ...
    'order', 2, ...                % order of the ODE
    'voltage', 'OHC', ...
    ...
    'parameters', struct( ...
                'G',    FAC*30.7262e-9, ...	   % Maximum conductance of fast channel
                'V1',  -10e-3 + -43.2029e-3, ...        % Half-activation setpoint of fast channel
                'S1',   11.9939e-3, ...	       % Voltage sensitivity constant of fast channel
                'V2',  -10e-3 + -64.4e-3, ...           % Half-activation setpoint of fast channel
                'S2',    9.6e-3, ...		   % Voltage sensitivity constant of fast channel
                ...
                'T1min', 0.10e-3, ...
                'T1max', 0.33e-3, ...
                'aT1',  31.25e-3, ...
                'bT1',   5.42e-3, ...
                ...
                'T2min', 0.09e-3, ...
                'T2max', 0.10e-3, ...
                'aT2',   1e-3, ...
                'bT2',   1e-3));

fast_channel_B = struct( ...
    'version', 'LopezPoveda_2006', ...
    'name', 'OHC_B', ...
    'var_name', 'popen_OHC_B', ...
    'index', NaN, ...
    'order', 2, ...                % order of the ODE
    'voltage', 'OHC', ...
    ...
    'parameters', struct( ...
                'G',    FAC*30.7262e-9, ...	   % Maximum conductance of fast channel
                'V1',  -25e-3 + -43.2029e-3, ...        % Half-activation setpoint of fast channel
                'S1',   11.9939e-3, ...	       % Voltage sensitivity constant of fast channel
                'V2',  -25e-3 + -64.4e-3, ...           % Half-activation setpoint of fast channel
                'S2',    9.6e-3, ...		   % Voltage sensitivity constant of fast channel
                ...
                'T1min', 0.10e-3, ...
                'T1max', 0.33e-3, ...
                'aT1',  31.25e-3, ...
                'bT1',   5.42e-3, ...
                ...
                'T2min', 0.09e-3, ...
                'T2max', 0.10e-3, ...
                'aT2',   1e-3, ...
                'bT2',   1e-3));

fast_channel_C = struct( ...
    'version', 'LopezPoveda_2006', ...
    'name', 'OHC_C', ...
    'var_name', 'popen_OHC_C', ...
    'index', NaN, ...
    'order', 2, ...                % order of the ODE
    'voltage', 'OHC', ...
    ...
    'parameters', struct( ...
                'G',    FAC*30.7262e-9, ...	   % Maximum conductance of fast channel
                'V1',  -20e-3 + -43.2029e-3, ...        % Half-activation setpoint of fast channel
                'S1',   10e-3 + 11.9939e-3, ...	       % Voltage sensitivity constant of fast channel
                'V2',  -20e-3 + -64.4e-3, ...           % Half-activation setpoint of fast channel
                'S2',    10e-3 + 9.6e-3, ...		   % Voltage sensitivity constant of fast channel
                ...
                'T1min', 0.10e-3, ...
                'T1max', 0.33e-3, ...
                'aT1',  31.25e-3, ...
                'bT1',   5.42e-3, ...
                ...
                'T2min', 0.09e-3, ...
                'T2max', 0.10e-3, ...
                'aT2',   1e-3, ...
                'bT2',   1e-3));

% channels = [ fast_channel ];
channels = [ fast_channel_A, fast_channel_B, fast_channel_C ];
% channels = [ fast_channel, fast_channel_2 ];
% channels = [ fast_channel, slow_channel ];

if false
    tc = {'T1max', 'T1min', 'T2max', 'T2min', ...
        'aT1', 'bT1', 'aT2', 'bT2'};
    
    for i = 1:numel(channels)
        for j = 1:numel(tc)
            channels(i).parameters.(tc{j}) = channels(i).parameters.(tc{j})*0.01;
        end
    end
end
end