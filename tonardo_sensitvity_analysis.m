%% Tornado Plot for Sensitivity Analysis of R0
clear; clc;
syms omega mu epsilon sigma

% --- Baseline Parameters (From Table 2) ---
params = struct(...
    'beta_mh', 0.195, ...    % Mosquito-to-human transmission
    'beta_hm', 1.0, ...       % Human-to-mosquito transmission
    'epsilon', 0.5, ...       % Vaccine efficacy
    'omega', 0.5, ...         % Vaccination rate
    'mu', 0.000042, ...       % Human death rate
    'gamma', 0.006, ...       % Human recovery rate
    'sigma', 0.009, ...       % Human progression rate
    'sigma_m', 0.00098, ...   % Mosquito progression rate
    'mu_m', 0.04 ...          % Mosquito death rate
);

% --- Parameter Variation Settings ---
variation = 0.25;  % ±25% variation for all parameters
param_names = fieldnames(params);
num_params = length(param_names);
R0_baseline = calculate_R0(params);  % Baseline R0

% --- Perform Sensitivity Analysis ---
sensitivity = zeros(num_params, 2); % [min_deviation, max_deviation]

for i = 1:num_params
    % Create modified parameter sets
    param_low = params;
    param_high = params;
    
    % Apply ± variation
    current_value = params.(param_names{i});
    param_low.(param_names{i}) = current_value * (1 - variation);
    param_high.(param_names{i}) = current_value * (1 + variation);
    
    % Calculate R0 for variations
    R0_low = calculate_R0(param_low);
    R0_high = calculate_R0(param_high);
    
    % Store deviations from baseline
    sensitivity(i,1) = R0_low - R0_baseline;
    sensitivity(i,2) = R0_high - R0_baseline;
end

% --- Prepare for Tornado Plot ---
% Calculate impact range for sorting
impact_range = max(sensitivity,[],2) - min(sensitivity,[],2);
[~, sort_idx] = sort(impact_range, 'descend');

sorted_names = param_names(sort_idx);
sorted_sensitivity = sensitivity(sort_idx, :);
y_pos = 1:num_params;

% --- Create Tornado Plot ---
figure;
hold on;

% Plot bars for each parameter
for i = 1:num_params
    % Determine colors based on direction of effect
    low_color = [0.2 0.4 0.8];  % Blue for negative effects
    high_color = [0.8 0.2 0.2]; % Red for positive effects
    
    % Plot low variation effect
    if sorted_sensitivity(i,1) < 0
        barh(y_pos(i), sorted_sensitivity(i,1), 'FaceColor', low_color, 'EdgeColor', 'none');
    else
        barh(y_pos(i), sorted_sensitivity(i,1), 'FaceColor', high_color, 'EdgeColor', 'none');
    end
    
    % Plot high variation effect
    if sorted_sensitivity(i,2) < 0
        barh(y_pos(i), sorted_sensitivity(i,2), 'FaceColor', low_color, 'EdgeColor', 'none');
    else
        barh(y_pos(i), sorted_sensitivity(i,2), 'FaceColor', high_color, 'EdgeColor', 'none');
    end
end

% Add zero reference line
xline(0, 'k-', 'LineWidth', 1.5, 'Color', [0 0 0]);

% Format plot
set(gca, 'YTick', y_pos, 'YTickLabel', sorted_names, 'YDir', 'reverse');
xlabel('\Delta R_0 from Baseline');
title('Tornado Plot: R_0 Sensitivity Analysis');
grid on;
box on
yticklabels({'\mu_m','\gamma','\beta_{mh}','\beta_{mh}', '\epsilon','\sigma_m','\mu','\sigma','\omega'});
% Add legend
h = zeros(2,1);
h(1) = bar(NaN, NaN, 'FaceColor', [0.2 0.4 0.8]);
h(2) = bar(NaN, NaN, 'FaceColor', [0.8 0.2 0.2]);
legend(h, {'-25% Variation', '+25% Variation'}, 'Location', 'southeast');

% Add baseline value annotation
text(0.05, 0.95, sprintf('Baseline R_0 = %.2f', R0_baseline), ...
    'Units', 'normalized', 'BackgroundColor', 'white', 'FontSize', 12);

hold off;

% --- R0 Calculation Function ---
function R0 = calculate_R0(p)
    % R0 formula from the model
    term1 = (p.beta_hm * p.beta_mh * p.mu) / ((p.omega + p.mu) * (p.gamma + p.mu) * p.mu_m);
    term2 = 1 + ((1 - p.epsilon) * p.omega) / p.mu;
    term3 = p.sigma / (p.sigma + p.mu);
    term4 = p.sigma_m / (p.sigma_m + p.mu_m);
    
    R0 = sqrt(term1 * term2 * term3 * term4);
end