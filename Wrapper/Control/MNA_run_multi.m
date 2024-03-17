function [analysis_variables, CACHE] = MNA_run_multi(varargin)
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
            ...
            ...'subplot', 0);
            'subplot', true);
        
% plotopt.hide_figures_while_plotting();

%% Default options

[~, stimulus, midopt, mechopt] = devopts.defaults(args, 'fun', plotopt);

% mechopt.gain = 0;

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
    'IHC_basolateral_conductance_dependance', 'channel_popen_tonotopic', ...
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
        ...'c_posix', ...
    'evalAtTimePoints', true, ...
    'solveropt', {{ ...
        ...'RelTol', 1e-4, ...
        'RelTol', 1e-9, ...
        ...'normcontrol', true, ...
        }}, ...
    'add_solveropt', struct( ...
        'use_jacobian', true, ...
        'use_jpattern', false), ...
    'samplingFrequency', args.GlobalSamplingFrequency ...
    );


[mnaopt] = devopts.ocelectric_templates(mnaopt, "mna_ver", args.mna_ver);

%% Run options
runopt = runOpt( ...
    ...'purge', 'electrical', ...
    'CodeVersion', codeVersion, ...
    'Debug', false, ... % debug mode will save results as id 0 (possibly replacing previous results)
    'ReconstructResults', true, ...true, ...
    'draw_gui', false, ...
    'save_figures', false, ...
    'figureSaveDir', fullfile(opt.cochleadir, 'Results', 'MNA'), ...
    'waitbarFunctionAvailable', false, ...
    'verbose', 3 );

% verbose levels:   0 ... just matlab errors & warnings
%                   1 ... low verbosity
%                   2 ... normal verbosity
%                   3 ... high verbosity

runopt.clear_lock_files_if_found = true;

runopt.no_create_only_load = args.no_create_only_load;

% default action for do is TRUE
skip_do = { ...
    ...'mech', ...
    ...'oc_mna', ...
    ......'synapse', ...
    ......'nerve', ...
    ......'ant_postprocess' ...
    };

% default action for recalculate is FALSE
do_recalculate = { ...
    ...'mid', ...
    ...'mech', ...
    ...'mech_statistics', ...
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
    ...'oc_mna', ...
    ......'ant', ...
    ......'synapse', ...
    ......'nerve', ...
    ......'ant_postprocess' ...
    };

% update in runopt
runopt.update_struct('do', skip_do, false);
runopt.update_struct('recalculate', do_recalculate, true);
runopt.update_struct('plot', do_plot, true);

%% Plotting options

plotopt.doplot = false;
        
% default action for plotopt.do is FALSE
do_draw = { ...
    ...'MNAsettings' ...
    ...
    ...'FourierTransform', ...
    ...'MaximalCrossection', ...
    ...
    ...'CurrentMesh', ...
    ...'VoltageMesh', ...
    ...
    ...'CurrentSteadyState', ...
    ...'VoltageSteadyState', ...
    ...
    ...'VoltageMesh_HC', ...
    ...'VoltageSteadyState_HC', ...
    ...
    ...'mech_BMx', ...
    ...'mech_profile_BMx', ...
    ...
    ...'BMdispl', ...
    ...'BMdisplProfile', ...
    ...'TMdispl', ...
    ...'TMdisplProfile', ...
    ...
    ...'stimulus', ...
    };

% update in plotopt
plotopt.update_struct('do', do_draw, true, 'oc_electric');

export_flag = false;
% export_flag = true;

%%

if ~isempty(args.do_parts)
    do = args.do_parts;
else
    do = struct( ...
        'analysis', 1 , ...
        'load_analysis', 1, ...
        'plot_phase_lag', 0, ...
        'plot_slice_at_oscillation_max_group_by_amplitude', 1, ...
        'plot_slice_at_oscillation_max_group_by_frequency', 0, ...
        'plot_1', 1, ...
        'plot_2', 0, ... broken
        'plot_3', 0, ... broken
        'plot_4', 0, ... broken
        'plot_5', 0, ... broken
        'plot_6', 0, ... broken
        'io_spl', 1, ...
        'io_spl_checks', 0, ... % check the char frequency of the max oscillation point
        'io_spl_range', 0, ...
        ... 'plot_8', 0, ... deprecated
        'io_spl_rel', 1, ... variable vs loudness in db SPL
        'TWamplitude', 1, ...
        'frequency_selectivity', 0, ...
        'ac_dc_ratio', 0 ...
        );
end

if args.cached_analysis == true
    do.analysis = false;
    do.load_analysis = false;
end
if isempty(args.cache)
    CACHE = struct();
else
    CACHE = args.cache;
end

mech_variables_to_plot = [...
    ..."BMx", ...
    ..."BMv", ...
    ..."TMx", ...
    ..."TMv", ...
    ];

%%

% default_tikz_options = { ...
%     'width', '0.4\textwidth', ...
%     'height', '0.3\textwidth', ...
%     'relativeDataPath', 'img/HairCells/', ...
%     'extraaxisoptions', 'legend style={font=\tiny}', ...
%     'parseStrings', true};

%% ANALYSIS

AMPLITUDE = args.Amplitude;
FREQUENCY = args.Frequency;

% update opts (eg when comparing two setups)
if ~isempty(args.update_opts)
    for i = 1:2:numel(args.update_opts)
        opt_name = args.update_opts{i};
        opt_val = args.update_opts{i+1};
        switch opt_name
            case 'do'
                do = opt_val;
            case 'mechopt'
                mechopt = opt_val;
            case 'mnaopt'
                mnaopt = opt_val;
            otherwise
                error('opt name %s not recognised', opt_name)
        end
    end
end

% override_analysis_start = Time(0);
override_analysis_start = [];

% keys = fields(plotopt.do);
% for i = 1:numel(keys)
%     key = keys{i};
%     plotopt.do.(key) = false;
% end

runopt.plot.oc_mna = true;
% runopt.plot.oc_mna = false;

plotopt.do.VoltageSteadyState_HC = true;

PLOT_FUN = @oc_mna_plot;

sim_groups = args.sim_groups;

if do.analysis
    
    [Configurations, Conf_nums] = ParameterProduct( ...
        args.product_args{:});

    FUN = @MNA;
    % FUN = @oc_mna_statistics;

    %% active
    if any(strcmp('active', sim_groups))
        SIM_OPTS = {midopt, mechopt, mnaopt};
        stats.active = batchGathering(FUN, 1, Configurations, ...
                    stimulus, SIM_OPTS, ...
                    runopt, opt, memopt, paropt, ...
                    'analysis_fun_kwargs', { ...
                        'analyse_signal_kwargs', struct( ...
                        'do_powerSpectrum', true), ...
                        }, ...
                    'skip_configuration_uniqueness_test', false, ...
                    'override_analysis_start', override_analysis_start, ...
                    'fig_save_dir_name_fun', @(conf) fullfile(opt.cochleadir, 'Results', 'MNA'), ...
                    'parfeval_iteration_delay', args.parfeval_iteration_delay, ...
                    'PLOT_FUN', PLOT_FUN, ...
                    'plotopt', plotopt);
    end
    %% passive
    if any(strcmp('passive', sim_groups))
        mechopt_passive = copy(mechopt);
        mechopt_passive.gain = 0;
        % mechopt_passive.lambda = 0;
        % mechopt_passive.nonlinParams = ones(1, mechopt.Numstacks);
        SIM_OPTS = {midopt, mechopt_passive, mnaopt};
        
        stats.passive = batchGathering(FUN, 1, Configurations, ...
                    stimulus, SIM_OPTS, ...
                    runopt, opt, memopt, paropt, ...
                    'analysis_fun_kwargs', { ...
                        'analyse_signal_kwargs', struct( ...
                        'do_powerSpectrum', true), ...
                        }, ...
                    'skip_configuration_uniqueness_test', false, ...
                    'override_analysis_start', override_analysis_start, ...
                    'fig_save_dir_name_fun', @(conf) fullfile(opt.cochleadir, 'Results', 'MNA'), ...
                    'parfeval_iteration_delay', args.parfeval_iteration_delay, ...
                    'PLOT_FUN', PLOT_FUN, ...
                    'plotopt', plotopt);
    end
    %%
    if false
        SIM_OPTS = {midopt, mechopt};
        mech_stats = batchGathering(@MechStatistics, 2, Configurations, ...
                    stimulus, SIM_OPTS, ...
                    runopt, opt, memopt, paropt, ...
                    'skip_configuration_uniqueness_test', true, ...
                    'override_analysis_start', override_analysis_start, ...
                    'fig_save_dir_name_fun', @(Conf) fullfile(opt.cochleadir, 'Results', 'MECH'), ...
                    'parfeval_iteration_delay', args.parfeval_iteration_delay);
        mech_variables = mech_stats(:,1);
        mech_runopt_n = mech_stats(:,2);

        for i = 1:numel(mech_variables_to_plot)
            mech_variable_to_plot = mech_variables_to_plot(i);
            mech_k = find(strcmp(mech_variable_to_plot,{mech_variables{1}.id}));
            mech_var_info{i} = mech_variables{1}(mech_k);
        end
    end
    
    %%
    for k = 1:numel(sim_groups)
        variables.(sim_groups{k}) = cell(numel(AMPLITUDE), numel(FREQUENCY));
        for i = 1:numel(AMPLITUDE)
            for j = 1:numel(FREQUENCY)        
                ind = sub2ind(Conf_nums, i, j);
                variables.(sim_groups{k}){i,j} = stats.(sim_groups{k}){ind};
            end
        end
    end
    
%     p = '/tmp/ondrej/matlab/oneMNAtest/';
%     mkdir(p)
%     save(fullfile(p, 'workspace.mat'), ...
%         'variables');
    CACHE.variables = variables;
else
%     p = '/tmp/ondrej/matlab/oneMNAtest/';
%     load(fullfile(p, 'workspace.mat'), ...
%         'variables');
    variables = CACHE.variables;
end

assert(logical(exist('variables', 'var')), 'Analysis results not present. Check if do.analysis == true')



end