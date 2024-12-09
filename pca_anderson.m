clear all
clc
close all

filename = "Refined_Data2.mat";
load(filename);
prebuffer = 100;
postbuffer = 150;
%%
selected = [1,4,8,13,14,20]; %duration 100ms
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
subplot(2,2,1);
plot(window_start(1)-prebuffer:length(Trace)-prebuffer,Trace(window_start(1):end,:));
xlabel('time from stimulation end (ms)');
ylabel('ipsi eye position (deg)');
title("Caesar Session 2 return trace ipsi dur=50ms princiapal component analysis");
subplot(2,2,2);
plot(window_start(1)-prebuffer:length(Trace_contra)-prebuffer,Trace_contra(window_start(1):end,:));
xlabel('time from stimulation end (ms)');
ylabel('ipsi eye position (deg)');
title("Caesar Session 2 return trace contra dur=50ms princiapal component analysis");
subplot(2,2,3);
plot(window_start-prebuffer,explained_step');
xlabel('time from stimulation end (ms)');
ylabel('% explained variance');
legend("PC1","PC2","PC3","PC4");
title("Caesar Session 2 return trace ipsi dur=50ms princiapal component analysis");
subplot(2,2,4);
plot(window_start-prebuffer,explained_step_c');
xlabel('time from stimulation end (ms)');
ylabel('% explained variance');
legend("PC1","PC2","PC3","PC4");
title("Caesar Session 2 return trace contra dur=50ms princiapal component analysis");