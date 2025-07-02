function plot_ICER_distributions()
    % Simulated Monte Carlo results (replace with actual data)
    % AVULUNDIAH PHIRI| 22 JUNE 2025
    num_sims = 5000;
    efficacies = [50, 70, 90]; % Vaccine efficacy levels
    
    % Generate synthetic ICER data (lognormal distribution)
    rng(42); % For reproducibility
    ICER_data = cell(1,3);
    ICER_data{1} = 300 + 100*randn(num_sims,1); % 50% efficacy
    ICER_data{2} = 200 + 80*randn(num_sims,1);  % 70% efficacy
    ICER_data{3} = 150 + 60*randn(num_sims,1);  % 90% efficacy
    
    % Create violin plots
    figure('Position', [100 100 800 600])
    violinplot(ICER_data, efficacies, 'ShowMean', true);
    
    % Formatting
    title('Violin Plot of ICER Distributions by Vaccine Efficacy', 'FontSize', 16)
    xlabel('Vaccine Efficacy (%)', 'FontSize', 14)
    ylabel('ICER ($/DALY saved)', 'FontSize', 14)
    ylim([0 600])
    grid on
    
    % Policy thresholds
    hold on
    line(xlim, [500 500], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 2)
    text(1.5, 520, 'Zambia WTP Threshold ($500/DALY)', 'Color', 'k', 'FontSize', 12)
    
    % Annotations
    annotation('textbox', [0.15 0.15 0.3 0.06], 'String', ...
        sprintf('High-efficacy vaccines show\nlower ICER variability'), ...
        'EdgeColor', 'none', 'FontSize', 12, 'BackgroundColor', [1 1 1 0.7])
end

% Custom violin plot function (simplified)
function violinplot(data, labels, varargin)
    positions = 1:length(data);
    colors = [0.9 0.6 0.5; 0.5 0.8 0.7; 0.4 0.6 0.9]; % Warm-to-cool palette
    
    for i = 1:length(data)
        % Kernel density estimation
        [f, xi] = ksdensity(data{i});
        
        % Normalize density
        f = f/max(f)*0.3;
        
        % Plot left violin
        fill(positions(i) - f, xi, colors(i,:), 'EdgeColor', 'none', 'FaceAlpha', 0.7)
        hold on
        
        % Plot right violin
        fill(positions(i) + f, xi, colors(i,:), 'EdgeColor', 'none', 'FaceAlpha', 0.7)
        
        % Plot mean line
        mean_val = mean(data{i});
        line([positions(i)-0.35 positions(i)+0.35], [mean_val mean_val], ...
             'Color', 'k', 'LineWidth', 2)
    end
    
    set(gca, 'XTick', positions, 'XTickLabel', labels)
    box on
end