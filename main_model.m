% MATLAB code for SEIR model with RTS,S malaria vaccine in Zambia
% AVULUNDIAH PHIRI| 23 MAY 2025
% Parameters
Lambda = 3994200;%100; % Recruitment rate of humans
Lambda_m = 200; % Recruitment rate of mosquitoes
mu = 1 / (65 * 365); % Natural death rate of humans (1/lifespan in days)
mu_m = 0.04;%1 / 10; % Natural death rate of mosquitoes (1/lifespan in days)
beta_mh = 0.195;%0.3; % Transmission rate from mosquitoes to humans
beta_hm = 1;%0.5; % Transmission rate from humans to mosquitoes
sigma = 0.009;%1 / 12; % Progression rate from exposed to infectious in humans
sigma_m = 0.00098;%1 / 10; % Progression rate from exposed to infectious in mosquitoes
gamma = 0.006; %1 / 14; % Recovery rate in humans
phi = 0.001;%1 / 180; % Loss of immunity rate in humans
epsilon = 0.75;%0.4; % Vaccine efficacy
omega = 0.5;%0.002; % Vaccination rate

% Initial conditions
S0 = 21913874;%%990; % Initial susceptible humans
V0 = 0; % Initial vaccinated humans
E0 = 10; % Initial exposed humans
I0 = 0; % Initial infectious humans
R0 = 0; % Initial recovered humans
Sm0 = 200; % Initial susceptible mosquitoes
Em0 = 0; % Initial exposed mosquitoes
Im0 = 0; % Initial infectious mosquitoes

% Time span
%tspan = [0 365*10]; % 10 years in days
tspan = [0 4000]; % 10 years in days



% Solve ODEs
params = [Lambda, Lambda_m, mu, mu_m, beta_mh, beta_hm, sigma, sigma_m, gamma, phi, epsilon, omega];
initial_conditions = [S0, V0, E0, I0, R0, Sm0, Em0, Im0];
[t, x] = ode45(@(t, x) SEIR_ODE(t, x, params), tspan, initial_conditions);

% Plot results
figure;
subplot(2,1,1);
plot(t, x(:,1), 'b', t, x(:,2), 'm', t, x(:,3), 'r', t, x(:,4), 'k', t, x(:,5), 'c','LineWidth',2);
legend('Susceptible', 'Vaccinated', 'Exposed', 'Infectious', 'Recovered');
xlabel('Time (days)');
ylabel('Human Population');
title('Human–Mosquito SEIR Model Dynamics');

subplot(2,1,2);
plot(t, x(:,6), 'b', t, x(:,7), 'r', t, x(:,8), 'k','LineWidth',2);
legend('Susceptible Mosquitoes', 'Exposed Mosquitoes', 'Infectious Mosquitoes');
xlabel('Time (days)');
ylabel('Mosquito Population');
title('Human–Mosquito SEIR Model Dynamics');
fontsize(gcf,scale=1.2)
% ODE system
function dxdt = SEIR_ODE(t, x, params)
    S = x(1);
    V = x(2);
    E = x(3);
    I = x(4);
    R = x(5);
    Sm = x(6);
    Em = x(7);
    Im = x(8);

    Lambda = params(1);
    Lambda_m = params(2);
    mu = params(3);
    mu_m = params(4);
    beta_mh = params(5);
    beta_hm = params(6);
    sigma = params(7);
    sigma_m = params(8);
    gamma = params(9);
    phi = params(10);
    epsilon = params(11);
    omega = params(12);

    dSdt = Lambda - beta_mh * Im / (Sm + Em + Im) * S - omega * S + phi * R - mu * S;
    dVdt = omega * S - (1 - epsilon) * beta_mh * Im / (Sm + Em + Im) * V - mu * V;
    dEdt = beta_mh * Im / (Sm + Em + Im) * S + (1 - epsilon) * beta_mh * Im / (Sm + Em + Im) * V - sigma * E - mu * E;
    dIdt = sigma * E - gamma * I - mu * I;
    dRdt = gamma * I - phi * R - mu * R;
    dSmdt = Lambda_m - beta_hm * I / (S + V + E + I + R) * Sm - mu_m * Sm;
    dEmdt = beta_hm * I / (S + V + E + I + R) * Sm - sigma_m * Em - mu_m * Em;
    dImdt = sigma_m * Em - mu_m * Im;

    dxdt = [dSdt; dVdt; dEdt; dIdt; dRdt; dSmdt; dEmdt; dImdt];
end
