function plot_CEAC()
    % WTP thresholds ($/DALY)
    % AVULUNDIAH PHIRI| 23 JUNE 2025
    wtp_thresholds = 0:10:1000;
    
    % Simulated probability data (replace with actual calculations)
    prob_50 = 1 - normcdf(wtp_thresholds, 600, 150); % 50% efficacy
    prob_70 = 1 - normcdf(wtp_thresholds, 320, 80);  % 70% efficacy
    prob_90 = 1 - normcdf(wtp_thresholds, 200, 50);  % 90% efficacy
    
    % Create plot
    figure('Position', [100 100 900 600])
    plot(wtp_thresholds, prob_50*100, 'LineWidth', 3, 'Color', [0.2 0.6 0.8])
    hold on
    plot(wtp_thresholds, prob_70*100, 'LineWidth', 3, 'Color', [0.8 0.4 0.2])
    plot(wtp_thresholds, prob_90*100, 'LineWidth', 3, 'Color', [0.3 0.7 0.3])
    
    % Formatting
    title('CEAC: Cost-Effectiveness Acceptability Curves', 'FontSize', 16)
    xlabel('Willingness-to-Pay Threshold ($/DALY saved)', 'FontSize', 14)
    ylabel('Probability Cost-Effective (%)', 'FontSize', 14)
    ylim([0 105])
    xlim([0 1000])
    grid on
    
    % Reference lines
    line([500 500], [0 100], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 2)
    line([0 1000], [50 50], 'Color', [0.5 0.5 0.5], 'LineStyle', ':', 'LineWidth', 1.5)
    
    % Legend
    legend({'50% Efficacy', '70% Efficacy', '90% Efficacy'}, ...
           'Location', 'southeast', 'FontSize', 12)
    
    % Annotations
    text(520, 40, 'Zambia WTP Threshold ($500/DALY)', 'Color', 'k', 'FontSize', 12, 'Rotation', 90)
    text(750, 52, '50% Decision Probability', 'Color', [0.5 0.5 0.5], 'FontSize', 11)
    
    % Highlight key findings
    %annotation('textarrow', [0.65 0.55], [0.35 0.25], 'String', ...
     %   '78% probability at $500/DALY for 70% efficacy', ...
      %  'FontSize', 12, 'HeadWidth', 15)
end