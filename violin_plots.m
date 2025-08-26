%% Author: Avulundiah Ed2in Phiri, Copperbelt University. Date: 24 August, 2025
clc; clear; close all;
rng(42); % For reproducibility
n_samples = 5000;

icer_rts = 395 + 60*randn(n_samples, 1);
icer_r21_5 = 375 + 55*randn(n_samples, 1);
icer_r21_3 = 265 + 45*randn(n_samples, 1);

all_data = [icer_rts; icer_r21_5; icer_r21_3]; % Stack all data vertically
group = [repmat("RTS,S (Base Case)", n_samples, 1); 
         repmat("R21 ($5/dose)", n_samples, 1);
         repmat("R21 ($3/dose)", n_samples, 1)];


figure('Position', [100, 100, 800, 600]);
hold on;

bp = boxplot(all_data, group, 'Symbol', '', 'Whisker', Inf); % 'Whisker', Inf shows min/max

h = findobj(gca, 'Tag', 'Box');
colors = [ 0.2 0.5 0.7; 0.7 0.2 0.2;0.3 0.7 0.4];
for i = 1:length(h)
    patch(get(h(i), 'XData'), get(h(i), 'YData'), colors(i, :), 'FaceAlpha', 0.5);
end


groups = unique(group);
x_pos = 1:length(groups); 

for i = 1:length(groups)
  
    current_data = all_data(group == groups(i));
    [density, value] = ksdensity(current_data, 'Support', 'positive');
    density = density / max(density) * 0.4; % Normalize width to 0.4
  
    fill(x_pos(i) - density, value, colors(i, :), 'FaceAlpha', 0.6, 'EdgeColor', 'none');
    fill(x_pos(i) + density, value, colors(i, :), 'FaceAlpha', 0.6, 'EdgeColor', 'none');
end


yline(500, 'r:', 'LineWidth', 2, 'Label', 'WTP Threshold ($500/DALY)', 'LabelVerticalAlignment', 'middle');
title('Comparison of ICER Distributions for Vaccine Scenarios');
ylabel('ICER ($/DALY)');
xlabel('Vaccine Scenario');
grid on;
set(gca, 'FontSize', 13, 'FontName', 'Arial');
ylim([0 700]); % Adjust based on your data range

hold off;
saveas(gcf, 'Figure6_ICER_Comparison.png'); % Or .eps, .pdf, etc.