function oneMNAjob(varargin)
arguments (Repeating)
    varargin
end
arguments
end

args = struct();

[args, opt, memopt, paropt] = common_opts(args, varargin{:});

%% Plotting options

plotopt = plotOpt('MNA', ...
            ...
            'default_plt_action', false, ...
            'interactive_selection', true, ...
            ...
            ...'subplot', 0);
            'subplot', true);

%% Default options

if ~isempty(args.stimulus) && ~isempty(args.topt)
    [topt, stimulus, midopt, mechopt] = devopts.defaults(args, 'defined', plotopt);
else
    [topt, stimulus, midopt, mechopt] = devopts.defaults(args, 'single', plotopt);
end

% plot(stimulus);
% play(stimulus);

% mechopt.user_settings.experiments.fixed_BM = true;

%% MNA options
mnaopt = mnaOpt( ...
    ...'capacitance_state_dependence', 'none', ...
    ...'capacitance_state_dependence', 'weak', ...
    'capacitance_state_dependence', 'strong', ...
    ...
    ...'zero_capacitance_test', true, ...
    ...
    ...'IHC_basolateral_conductance_dependance', 'none', ...
    ...'IHC_basolateral_conductance_dependance', 'vihc', ...
    ...'IHC_basolateral_conductance_dependance', 'vihc_ss', ...
    ...'IHC_basolateral_conductance_dependance', 'channel_popen', ...
    'IHC_basolateral_conductance_dependance', 'channel_popen_Dierich_2020', ...
    ...
    ...'OHC_basolateral_conductance_dependance', 'none', ...
    ...'OHC_basolateral_conductance_dependance', 'vohc', ...
    ...'OHC_basolateral_conductance_dependance', 'vohc_ss', ...
    'OHC_basolateral_conductance_dependance', 'channel_popen', ...
    ...
    'IHC_MET_dependence', 'BM', ...
    'OHC_MET_dependence', 'cilia', ...
    ...
    'Numstacks', args.Numstacks, ...
    'NumDiv', 'auto', ...
    'solver', 'ode15s', ...
    'fallback_solver', 'ode23t', ...
    'save_method', ...
        'matlab_matfile', ...
        ...'c_posix', ..
    'evalAtTimePoints', true, ...
    'solveropt', {{ ...
        ...'RelTol', 5e-2, ...
        ...'RelTol', 1e-6, ...
        ...'RelTol', 1e-6, ...
        ...'RelTol', 1e-9, ...
        'RelTol', 1e-11, ...
        ...'normcontrol', true, ...
        }}, ...
    'add_solveropt', struct( ...
        'use_jacobian', true, ...
        'use_jpattern', false), ...
        ...'use_jacobian', false, ...
        ...'use_jpattern', true), ...
    'samplingFrequency', args.GlobalSamplingFrequency ...
    );

[mnaopt] = devopts.ocelectric_templates(mnaopt, "mna_ver", args.mna_ver);

%% Run options

% analysis_start = stimulus.default_analysis_start_time;
analysis_start = Time(0);

runopt = runOpt( ...
    'CodeVersion', codeVersion, ...
    'Debug', false, ... % debug mode will save results as id 0 (possibly replacing previous results)
    'ReconstructResults', true, ...true, ...
    'draw_gui', true && canplot(), ...
    'save_figures', false, ...
    'figureSaveDir', fullfile(opt.cochleadir, 'Results', 'MNA'), ...
    'waitbarFunctionAvailable', false, ...
    'analysisStart', analysis_start, ...
    ...'analysisStart', Time(0), ...
    'verbose', 3 );

% verbose levels:   0 ... just matlab errors & warnings
%                   1 ... low verbosity
%                   2 ... normal verbosity
%                   3 ... high verbosity

if args.purge == true
    runopt.purge = 'electrical';
end


% default action for do is TRUE
skip_do = { ...
    ...'mech', ...
    ...'oc_mna', ...
    ...'oc_mna_analysis', ...
    ......'synapse', ...
    ......'nerve', ...
    ......'ant_postprocess' ...
    };

% default action for recalculate is FALSE
do_recalculate = { ...
    ...'mid', ...
    ...'mech', ...
    ...'mech_statistics', ...
    ...'oc_mna_circuit_ic', ...
    ...'oc_mna_dae_ic', ...
    ...'oc_mna', ...
    ...'oc_mna_statistics', ...
    ......'synapse', ...
    ......'nerve', ...
    ......'replications', ...
    ......'ant_postprocess', ...
    };
    
% default action for plot is FALSE
do_plot = { ...
    ...'mech', ...
    'oc_mna', ...
    ......'ant', ...
    ......'synapse', ...
    ......'nerve', ...
    ......'ant_postprocess' ...
    };

% update in runopt
runopt.update_struct('do', skip_do, false);
runopt.update_struct('recalculate', do_recalculate, true);
if canplot()
    runopt.update_struct('plot', do_plot, true);
end

if args.recalculate == true
    runopt.update_struct('recalculate', {'oc_mna'}, true);
end

%% Plotting options

% default action for plotopt.do is FALSE
do_draw = { ...
    'MNAsettings' ...
    ...
    ...'FourierTransform', ...
    'MaximalCrossection', ...
    ...
    ...'CurrentMesh', ...
    ...'VoltageMesh', ...
    ...
    'CurrentSteadyState', ...
    'VoltageSteadyState', ...
    ...
    'VoltageMesh_HC', ...
    'VoltageSteadyState_HC', ...
    ...
    ...'BMdispl', ...
    ...'BMdisplProfile', ...
    ...'TMdispl', ...
    ...'TMdisplProfile', ...
    ...
    ...'stimulus', ...
    };

% update in plotopt
plotopt.update_struct('do', do_draw, true);

% plotopt.hide_figures_while_plotting();

%% Check parameter consistency

optConsistency( 'MNA', ...
                stimulus, ...
                mechopt, ...   % physical parameters (timespan, number of cross-sections, ...)
                mnaopt, ...
                runopt, ...    % runtime parameters (runID, debug, verbosity, ...)
                opt, ...       % global parameters (result folders, ...)
                plotopt, ...   % plotting parameters
                memopt, ...    % memory control parameters
                paropt ...
               );


%% Run similation

if (paropt.licenceAvailable == 1) && ...
   (paropt.useparalleltoolbox && paropt.submitAsBatchJob)

    % submit MNA as batch job
    batch(@MNA, 0, {stimulus, topt, midopt, mechopt, mnaopt, runopt, opt, memopt, paropt}, ...
            'AdditionalPaths', CochleaNervePath( opt.cochleadir ));

else
    % run MNA function
    MNA( stimulus, ...
         topt, ...
         midopt, ...
         mechopt, ...   % physical parameters (timespan, number of cross-sections, ...)
         mnaopt, ...
         runopt, ...    % runtime parameters (runID, debug, verbosity, ...)
         opt, ...       % global parameters (result folders, ...)
         memopt, ...    % memory control parameters
         paropt ...
        );

    oc_mna_plot(plotopt, stimulus, topt, midopt, mechopt, mnaopt, [], [], runopt, opt, memopt, paropt, [])
    
end
end
