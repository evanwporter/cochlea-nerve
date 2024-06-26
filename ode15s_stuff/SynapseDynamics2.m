function SynapseDynamics2()
    % Voltage step to simulate
    Vt = -.01; % Voltage in mV
    voltage_steps = linspace(-.07, -.005, 20);
    
    % Initialize options
    opts = SynapseOptions2();
    
    % Set simulation time parameters
    % tspan = opts.tspan(1):opts.dt:opts.tspan(end);

    % Initialize state
    initial_state = initialize_synapse_state(opts);

    % Define solver options
    % solveropt = solverOpt('TimeStep', opts.dt);

    % Set steady state voltage
    V_steady_state = -70; % Example value in mV

    % Simulation using odeEuler with TransductionRHS_v5
    [t_out, y_out] = ode15s(@(t, y) Trans2(t, y, opts, V_steady_state, Vt), [0 1e-3], initial_state);

    calc_q_released(t_out, y_out, opts);

    % For debugging: Display output (y_out, t_out)
    disp("Simulation complete.");
    plot(t_out, decompose_z(y_out, 'NT_free', opts.size_info));
    xlabel('Time (s)');
    ylabel('State Variables');
    title('Synapse Dynamics Simulation');
end

% Helper function to initialize the state vector
function initial_state = initialize_synapse_state(opts)
    m_initial = 0;    
    Ca_blocked_initial = 0;    
    I_initial = 0;    
    C_vesicles_initial = opts.C_initial * ones(opts.num_vesicles, 1);
    q_initial = ones(opts.num_vesicles, 1);
    c_initial = 0;    
    w_initial = 0;
    c_proton_initial = 0;

    initial_state = [m_initial; Ca_blocked_initial; I_initial; C_vesicles_initial; ...
                     q_initial; c_initial; w_initial; c_proton_initial];
end


function total_release = calc_q_released(t, z_array, opts)
    % Find index range for q in the state vector
    q_start = opts.size_info.NT_free.start;
    q_end = opts.size_info.NT_free.end;

    % Extract q values
    q_values = z_array(:, q_start:q_end);

    % Calculate total release by summing the decreases in q
    total_release = 0;
    for i = 2:length(t)
        release_this_step = q_values(:, i-1) - q_values(:, i);
        total_release = total_release + sum(release_this_step(release_this_step > 0));
    end

    % Display total amount released
    disp("Total neurotransmitter released: " + total_release);
end

function v = decompose_z(z, variable, size_info)

si = size_info.(variable);
v = z(:, si.start : si.end);

end