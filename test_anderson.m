clear all
clc
close all

filename = "Refined_Data2.mat";
load(filename);
prebuffer = 100;
postbuffer = 150;
%%
selected = [1,4,8,13,14,20]; %duration 50ms
n_file = zeros(length(Refined_Data2),1);
dur = Refined_Data2{selected(1),1}.dur;
freq = Refined_Data2{selected(1),1}.freq;
amplitude = Refined_Data2{selected(1),1}.current;

for i = 1:length(Refined_Data2)
    n_file(i,1) = Refined_Data2{i,1}.number;
    [n_idx,~] = find(n_file == selected);
end
%%
n_sample = length(n_idx);
sample = cell(length(n_sample),4);

for i = 1:n_sample
    sample{i,1} = Refined_Data2{n_idx(i),1}.ehp_ipsi;
    sample{i,2} = Refined_Data2{n_idx(i),1}.ehp_contra;
    sample{i,3} = Refined_Data2{n_idx(i),1}.freq;
    sample{i,4} = Refined_Data2{n_idx(i),1}.current;
end
%% unstimulated plant nonlinear fit with estimated TC
max_pos_pca = cell2mat(sample(:,3));
Trace = sample(1:n_sample,1);
Trace_contra = sample(1:n_sample,2)
Trace{3,1} = Trace{3,1}(:,1:303);
Trace_contra{3,1} = Trace_contra{3,1}(:,1:303);
Trace{6,1} = Trace{6,1}(:,1:303);
Trace_contra{6,1} = Trace_contra{6,1}(:,1:303);
Trace = cell2mat(Trace);
Trace_contra = cell2mat(Trace_contra);
Trace = -Trace';
Trace_contra = -Trace_contra';
[~,removed] = find(Trace(prebuffer+150:end,:)<0);
removed = unique(removed);
Trace(:,removed) = [];
Trace_contra(:,removed) = [];
[~,max_pos] = max(Trace(prebuffer:end-postbuffer+10,:));
start_fit = max(max_pos);
time = 100;
Trace_fit = Trace(prebuffer+start_fit+1:prebuffer+start_fit+time,:);
%%
% Combine A_j and T_j into a single parameter vector
N = size(Trace,2);
init_TCs = [0.01,0.1,1,10]; % Initial TCs given by Sklavos et al. 2005
init_As = [0.5,0.3,0.15,0.1];
init_As = repmat(init_As,N,1);
init_params = [init_As; init_TCs]'; % Flatten A_j and append T_j
time = 0:time-1;


% Objective function for all trajectories
function err = group_fit_objective(params, Trace, time, N)
    A = params(:,1:end-1); % Extract A_j for all trajectories
    TC = params(:,end); % Extract shared T_j
  
    % Compute error for each trajectory
    pred = zeros(size(Trace));
    for i = 1:N
        pred(:, i) = sum(A(:, i) .* exp(-time ./TC),1);
    end
    err = Trace(:) - pred(:); % Flatten and compute residuals
end

% Solve using lsqnonlin
options = optimset('Display', 'iter', 'MaxFunEvals', 1e4, 'TolFun', 1e-6);
fitted_params = lsqnonlin(@(params) group_fit_objective(params, Trace_fit, time, N),init_params, [], [], options);

%%
fitted_params = fitted_params';

df = N-1;
upper = tinv(0.975,df);
lower = tinv(0.025,df);

A1 = fitted_params(1:N,1);
A2 = fitted_params(1:N,2);
A3 = fitted_params(1:N,3);
A4 = fitted_params(1:N,4);

A1_stat = datastats(A1);
A2_stat = datastats(A2);
A3_stat = datastats(A3);
A4_stat = datastats(A4);

A1_CI_upper = A1_stat.mean + upper * A1_stat.std/sqrt(df+1);
A1_CI_lower = A1_stat.mean + lower * A1_stat.std/sqrt(df+1);
A2_CI_upper = A2_stat.mean + upper * A2_stat.std/sqrt(df+1);
A2_CI_lower = A2_stat.mean + lower * A2_stat.std/sqrt(df+1);
A3_CI_upper = A3_stat.mean + upper * A3_stat.std/sqrt(df+1);
A3_CI_lower = A3_stat.mean + lower * A3_stat.std/sqrt(df+1);
A4_CI_upper = A4_stat.mean + upper * A4_stat.std/sqrt(df+1);
A4_CI_lower = A4_stat.mean + lower * A4_stat.std/sqrt(df+1);

fit_A = [A1_stat.mean;A2_stat.mean;A3_stat.mean;A4_stat.mean];
fit_TC = fitted_params(end,:);

%%
X = 1:length(Trace_fit);
fitted_trace = sum(fit_A .* exp(-X ./fit_TC'),1);
figure;
subplot(2,2,1);
plot(fitted_trace);
title('fit return trajectory for duration = 50ms group');
ylabel('eye positon (deg)');
xlabel('time after peak displacement (ms)');
subplot(2,2,2);
plot(Trace(prebuffer+start_fit:prebuffer+start_fit+length(X)-1,:));
title('original return trajectory for duation = 50ms group')
ylabel('eye positon (deg)');
xlabel('time after peak displacement (ms)');
subplot(2,2,3);
aveg_ehp_ipsi = mean(Trace(prebuffer+start_fit:prebuffer+start_fit+length(X)-1,:),2);
plot(aveg_ehp_ipsi);
title('average original return trajectory for duation = 50ms group')
ylabel('eye positon (deg)');
xlabel('time after peak displacement (ms)');
subplot(2,2,4);
plot(fitted_trace' - aveg_ehp_ipsi);
title('error fit - average for duation = 50ms group')
ylabel('eye positon (deg)');
xlabel('time after peak displacement (ms)');

aveg_ehp_contra = mean(Trace_contra(prebuffer+start_fit:prebuffer+start_fit+length(X)-1,:),2);

%%
step = 1:2:40;
window_size = 100;
window_start = prebuffer + start_fit + step;
n_PC = 4;
explained_step = zeros(n_PC,length(step));
explained_step_c = zeros(n_PC,length(step));

%%
for j = 1:length(step)
    Trace_pca = Trace(window_start(j):window_start(j)+window_size,:);
    Trace_pca_contra = Trace_contra(window_start(j):window_start(j)+window_size,:);
    [wcoeff,~,latent,~,explained] = pca(Trace_pca);
    [wcoeff_c,~,latent_c,~,explained_c] = pca(Trace_pca_contra);
    explained_step(1:n_PC,j) = explained(1:n_PC,1);
    explained_step_c(1:n_PC,j) = explained_c(1:n_PC,1);
end

%%
subplot(2,1,1);
plot(window_start-prebuffer,explained_step');
xlabel('time from stimulation end (ms)');
ylabel('% explained variance');
legend("PC1","PC2","PC3","PC4");
title("Caesar Session 2 return trace ipsi dur=50ms princiapal component analysis");
subplot(2,1,2);
plot(window_start-prebuffer,explained_step_c');
xlabel('time from stimulation end (ms)');
ylabel('% explained variance');
legend("PC1","PC2","PC3","PC4");
title("Caesar Session 2 return trace contra dur=50ms princiapal component analysis");