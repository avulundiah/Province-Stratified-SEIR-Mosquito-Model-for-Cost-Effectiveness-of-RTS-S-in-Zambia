% Bifurcation Diagram: R0 vs Vaccine Efficacy (ε)
% AVULUNDIAH PHIRI| 25 JUNE 2025
clear; clc;
% --- Model Parameters (From Table 2) ---
beta_hm = 1.0;       % Human-to-mosquito transmission rate
beta_mh = 0.195;     % Mosquito-to-human transmission rate
mu = 0.000042;       % Human natural mortality rate
mu_m = 0.04;         % Mosquito natural mortality rate
omega = 0.5;         % Vaccination rate
gamma = 0.006;       % Human recovery rate
sigma = 0.009;       % Progression rate (exposed to infectious in humans)
sigma_m = 0.00098;   % Progression rate (exposed to infectious in mosquitoes)

% --- Define Efficacy Range (ε = 0 to 1) ---
epsilon = linspace(0, 1, 1000);  % 0% to 100% efficacy

% --- Compute R0 Components ---
Term1 = (beta_hm * beta_mh * mu) / ((omega + mu) * (gamma + mu) * mu_m);
Term2 = 1 + ((1 - epsilon) * omega) / mu;
Term3 = sigma / (sigma + mu);
Term4 = sigma_m / (sigma_m + mu_m);

% --- Calculate R0 ---
R0 = sqrt(Term1 * Term2 .* Term3 * Term4);

% --- Find Critical Efficacy (ε where R0 = 1) ---
critical_epsilon = interp1(R0, epsilon, 1);

% --- Plot Results ---
figure;
plot(epsilon, R0, 'c:', 'LineWidth', 1, 'DisplayName', 'R_0 values');
hold on;
yline(1, 'r--', 'LineWidth', 1.5, 'DisplayName', 'R_0 = 1 Threshold');
xline(critical_epsilon, 'k--', 'LineWidth', 1.5, 'DisplayName', sprintf('Critical ε = %.2f', critical_epsilon));
%fill([critical_epsilon, critical_epsilon, 1, 1], [0, 1, 1, 0], 'g', 'FaceAlpha', 0.1, 'EdgeColor', 'none', 'DisplayName', 'Elimination Zone');

H1=area(epsilon, R0);
%set(H1(1),'FaceColor',[0.5,1,1])
set(H1(1),'FaceColor',[0,1,1], 'DisplayName','Elimination Zone');
hold off;

% --- Format Plot ---
xlabel('Vaccine Efficacy (ε)');
ylabel('Basic Reproduction Number (R_0)');
title('Bifurcation Diagram: R_0 vs. Vaccine Efficacy');
legend('Location', 'best');
grid on;
set(gca, 'FontSize', 12);
xlim([.948 1])
% --- Display Critical ε ---
fprintf('Critical vaccine efficacy for R0 < 1: ε = %.2f\n', critical_epsilon);