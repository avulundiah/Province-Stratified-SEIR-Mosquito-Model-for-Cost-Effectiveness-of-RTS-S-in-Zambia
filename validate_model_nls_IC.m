function validate_model_nls_IC()
clc; close all;
    % MALARIA_MODEL_VALIDATION_WITH_CI:
    % AVULUNDIAH PHIRI| 2ND JULY 2025
    % Empirical data (cases per 1000 population for years 2015-2023):
    obs = [218.94, 203.98, 188.00, 186.47, 182.14, 179.45, 180.33, 179.05, 176.74];
    years = 2015:2023;
    t_years = 0:(length(obs)-1);  % 0..8 for interpolation
    
    % Base parameter means (from your model)
    mean_beta  = 0.195;    % Transmission rate
    mean_sigma = 1/12;     % Incubation rate
    mean_gamma = 1/15;     % Recovery rate
    % Vaccine scenario base:
    mean_epsilon_A = 0.75; % Vaccine efficacy
    mean_nu_A      = 0.05;  % Vaccination rate
    
    % Uncertainty assumptions (adjust as appropriate):
    sd_beta  = 0.01;       % e.g., ~10% relative uncertainty
    sd_sigma = 0.0001;      % adjust based on plausible incubation uncertainty
    sd_gamma = 0.002;      % adjust based on plausible infectious-period uncertainty
    sd_epsilon = 0.02;     % vaccine efficacy uncertainty
    sd_nu = 0.05;           % vaccination rate uncertainty
    
    % Empirical data uncertainty: assume ±5% (normal) around each observed value
    obs_sd = 0.02 * obs;   % standard deviation for empirical error bars
    
    % Monte Carlo settings
    Nsim = 1000;
    
    % Pre-allocate arrays: each row = one simulation run, columns for each year
    IA_runs = nan(Nsim, length(t_years));  % with vaccine
    IB_runs = nan(Nsim, length(t_years));  % no vaccine
    
    % Population scaling (per 1000)
    Npop = 1000;
    % Initial conditions per 1000:
    I0 = obs(1);
    E0 = 0;
    R0 = 0;
    S0 = Npop - (I0 + E0 + R0);
    y0 = [S0; E0; I0; R0];
    
    % Time span for ODE (in years)
    tspan = [0, t_years(end)];
    
    % Run Monte Carlo
    rng('default');  % for reproducibility
    for k = 1:Nsim
        % Sample parameters (truncate if needed)
        beta_samp = normrnd(mean_beta, sd_beta);
        beta_samp = max(beta_samp, 0);
        
        sigma_samp = normrnd(mean_sigma, sd_sigma);
        sigma_samp = max(sigma_samp, eps);
        
        gamma_samp = normrnd(mean_gamma, sd_gamma);
        gamma_samp = max(gamma_samp, eps);
        
        % Vaccine scenario
        epsilon_A_samp = 0.06 + 75 * rand;
        epsilon_A_samp = min(max(epsilon_A_samp, 0), 1);
        nu_A_samp = 0;%0.6 + 0.15 * rand;
        nu_A_samp = max(nu_A_samp, 0);
        
        % No-vaccine scenario: epsilon_B=0, nu_B=0
        epsilon_B_samp = 0;
        nu_B_samp = 0;
        
        % Simulate with vaccine
        try
            [tA, YA] = ode45(@(t,y) seir_vaccine(t, y, beta_samp, sigma_samp, gamma_samp, nu_A_samp, epsilon_A_samp), tspan, y0);
        catch
            % In case solver fails, skip this run
            continue;
        end
        IA = interp1(tA, YA(:,3), t_years);
        IA_runs(k, :) = IA;
        
        % Simulate no-vaccine
        try
            [tB, YB] = ode45(@(t,y) seir_vaccine(t, y, beta_samp, sigma_samp, gamma_samp, nu_B_samp, epsilon_B_samp), tspan, y0);
        catch
            continue;
        end
        IB = interp1(tB, YB(:,3), t_years);
        IB_runs(k, :) = IB;
    end
    
    % Remove any rows with NaNs (failed runs)
    validA = all(~isnan(IA_runs), 2);
    IA_runs = IA_runs(validA, :);
    validB = all(~isnan(IB_runs), 2);
    IB_runs = IB_runs(validB, :);

    
    
    % Compute percentiles for confidence bounds
    p_lower = 2.5; p_upper = 97.5;
    IA_lower = prctile(IA_runs, p_lower, 1);
    IA_median = prctile(IA_runs, 100, 1);
    IA_upper = prctile(IA_runs, p_upper, 1);
    
    IB_lower = prctile(IB_runs, p_lower, 1);
    IB_median = prctile(IB_runs, 50, 1);
    IB_upper = prctile(IB_runs, p_upper, 1);
    
    % Compute RMSE and R^2 for median curves vs observed
    [rmseB, r2B] = fit_metrics(obs, IB_median);
    fprintf('No Vaccine (median):     RMSE = %.2f, R^2 = %.3f\n', rmseB, r2B);
    
    % Plotting
    figure; hold on;
    % Shaded confidence for with vaccine
    fill_x = [years, fliplr(years)];
    % Shaded confidence for no vaccine
    fill_yB = [IB_upper, fliplr(IB_lower)];
    hB = fill(fill_x, fill_yB, colorAlpha([1.0 0.9 0.7], 0.2), 'EdgeColor', 'none');
    plot(years, IB_median, 'r', 'Color', [1.0 .1 .1], 'LineWidth', 2.5);
    % Plot observed data with error bars (±1.96*sd)
   
    plot(years, obs,'.b',MarkerSize=30)
    
    xlabel('Year'); ylabel('Infectious cases per 1000', 'FontSize',12);
    title('Model Validation: Empirical vs Predicted Time Series', 'FontSize',14);
   
    legend('Model prediction with vaccine', ...
                      'Emperical data');
   
    grid on;   
    box on;

end

% SEIR model with vaccine
function dydt = seir_vaccine(~, y, beta, sigma, gamma, nu, epsilon)
    S = y(1); E = y(2); I = y(3); R = y(4);
    N = S + E + I + R;
    beta_eff = beta * (1 - epsilon);
    dS = -beta_eff * S * I / N - nu * S;
    dE =  beta_eff * S * I / N - sigma * E;
    dI = sigma * E - gamma * I;
    dR = gamma * I + nu * S;
    dydt = [dS; dE; dI; dR];
end

% Compute RMSE and R²
function [rmse, R2] = fit_metrics(obs, pred)
    residuals = obs - pred;
    rmse = sqrt(mean(residuals.^2));
    SSE = sum(residuals.^2);
    SST = sum((obs - mean(obs)).^2);
    R2 = 1 - SSE / SST;
end

% Utility: return color with alpha for fill (requires patch-like behavior)
function c = colorAlpha(rgb, alpha)
    % For fill patches: MATLAB uses the same rgb vector, set FaceAlpha separately:
    c = rgb;
end
