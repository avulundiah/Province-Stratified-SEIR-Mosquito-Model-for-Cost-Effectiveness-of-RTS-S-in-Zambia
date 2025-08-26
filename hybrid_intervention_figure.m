function hybrid_intervention_figure()
    % Avulundiah Phiri| 26 August 2025
    interventions = {
        'No Intervention'
        'ITNs Only'
        'RTS,S Only'
        'IRS Only'
        'RTS,S + ITNs'
        'RTS,S + IRS'
        'Triple Intervention'
    };
    
    icer = [NaN, 150, 320, 210, 240, 260, 190];  % $/DALY
    infections_averted = [0, 1.8, 1.23, 1.5, 2.6, 2.2, 3.0];  % Millions
    
    % Create figure with two subplots
    fig = figure('Position', [100, 100, 1200, 500]);
    
    % Subplot 1: ICER comparison
    subplot(1,2,1);
    bar(icer, 'FaceColor', [0.4 0.6 0.8]);
    set(gca, 'XTick', 1:length(interventions), 'XTickLabel', interventions, ...
        'XTickLabelRotation', 45, 'FontSize', 10);
    ylabel('ICER ($/DALY)', 'FontSize', 11, 'FontWeight', 'bold');
    title('Cost-Effectiveness of Intervention Strategies', 'FontSize', 12, 'FontWeight', 'bold');
    grid on;
    ylim([0 350]);
    
    % Add ICER values on bars
    for i = 1:length(icer)
        if ~isnan(icer(i))
            text(i, icer(i)+10, sprintf('$%d', icer(i)), ...
                'HorizontalAlignment', 'center', 'FontSize', 10);
        end
    end
    
    % Add WTP threshold
    hold on;
    plot(xlim, [1300 1300], 'r--', 'LineWidth', 1.5);
    text(1.5, 1350, 'Zambia WTP Threshold ($1,300/DALY)', ...
        'FontSize', 10, 'Color', 'r');
    
    % Subplot 2: Infections averted
    subplot(1,2,2);
    bar(infections_averted, 'FaceColor', [0.8 0.4 0.4]);
    set(gca, 'XTick', 1:length(interventions), 'XTickLabel', interventions, ...
        'XTickLabelRotation', 45, 'FontSize', 10);
    ylabel('Infections Averted (Millions/Year)', 'FontSize', 11, 'FontWeight', 'bold');
    title('Epidemiological Impact', 'FontSize', 12, 'FontWeight', 'bold');
    grid on;
    ylim([0 3.5]);
    
    % Add values on bars
    for i = 1:length(infections_averted)
        text(i, infections_averted(i)+0.1, sprintf('%.2fM', infections_averted(i)), ...
            'HorizontalAlignment', 'center', 'FontSize', 10);
    end
    
    % Add synergy annotation
    annotation('textarrow', [0.78, 0.65], [0.35, 0.55], ...
        'String', 'Synergy: 35% more impact', ...
        'FontSize', 11, 'TextColor', 'k', 'HeadWidth', 15, 'HeadLength', 15);
    
    % Add overall title
    sgtitle('Cost-Effectiveness of Hybrid Malaria Interventions in Zambia', ...
        'FontSize', 14, 'FontWeight', 'bold');
    
  
    exportgraphics(fig, 'Figure_S3_Hybrid_Interventions.png', 'Resolution', 300);
end