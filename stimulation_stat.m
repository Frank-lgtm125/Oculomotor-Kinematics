clear all
clc
%% stimulation statistic

filename = "Refined_Data2.mat";
load(filename);
prebuffer = 100;
postbuffer = 150;
%%
selected = [3,4,6]; %amplitude 40uA, frequency 200Hz
n_file = zeros(length(Refined_Data2),1);


for i = 1:length(Refined_Data2)
    n_file(i,1) = Refined_Data2{i,1}.number;
    [n_idx,~] = find(n_file == selected);
end
%%
n_sample = length(n_idx);
sample = cell(length(n_sample),6);

for i = 1:n_sample
    sample{i,1} = Refined_Data2{n_idx(i),1}.ehp_ipsi;
    sample{i,2} = Refined_Data2{n_idx(i),1}.ehp_contra;
    sample{i,3} = -min(Refined_Data2{n_idx(i),1}.ipsi_ehp_avg(prebuffer:end));
    sample{i,4} = Refined_Data2{n_idx(i),1}.dur;
    sample{i,5} = Refined_Data2{n_idx(i),1}.freq;
    sample{i,6} = Refined_Data2{n_idx(i),1}.current;
end
%%
X1 = cell2mat(sample(1:n_sample,4))';
Y1 = cell2mat(sample(1:n_sample,3))';
%%
selected = [8]; %amplitude 40uA, frequency 400Hz
n_file = zeros(length(Refined_Data2),1);


for i = 1:length(Refined_Data2)
    n_file(i,1) = Refined_Data2{i,1}.number;
    [n_idx,~] = find(n_file == selected);
end
%%
n_sample = length(n_idx);
sample = cell(length(n_sample),6);

for i = 1:n_sample
    sample{i,1} = Refined_Data2{n_idx(i),1}.ehp_ipsi;
    sample{i,2} = Refined_Data2{n_idx(i),1}.ehp_contra;
    sample{i,3} = -min(Refined_Data2{n_idx(i),1}.ipsi_ehp_avg(prebuffer:end));
    sample{i,4} = Refined_Data2{n_idx(i),1}.dur;
    sample{i,5} = Refined_Data2{n_idx(i),1}.freq;
    sample{i,6} = Refined_Data2{n_idx(i),1}.current;
end

%%
X2 = cell2mat(sample(1:n_sample,4))';
Y2 = cell2mat(sample(1:n_sample,3))';
%%
selected = [1,2,5]; %amplitude 80uA, frequency 200Hz
n_file = zeros(length(Refined_Data2),1);


for i = 1:length(Refined_Data2)
    n_file(i,1) = Refined_Data2{i,1}.number;
    [n_idx,~] = find(n_file == selected);
end
%%
n_sample = length(n_idx);
sample = cell(length(n_sample),6);

for i = 1:n_sample
    sample{i,1} = Refined_Data2{n_idx(i),1}.ehp_ipsi;
    sample{i,2} = Refined_Data2{n_idx(i),1}.ehp_contra;
    sample{i,3} = -min(Refined_Data2{n_idx(i),1}.ipsi_ehp_avg(prebuffer:end));
    sample{i,4} = Refined_Data2{n_idx(i),1}.dur;
    sample{i,5} = Refined_Data2{n_idx(i),1}.freq;
    sample{i,6} = Refined_Data2{n_idx(i),1}.current;
end

%%
X3 = cell2mat(sample(1:n_sample,4))';
Y3 = cell2mat(sample(1:n_sample,3))';
%%

figure;
scatter(X1,Y1,"filled",'MarkerFaceColor',[1 0 0]);
hold on
scatter(X2,Y2,"filled",'MarkerFaceColor',[0 1 0]);
scatter(X3,Y3,"filled",'MarkerFaceColor',[0 0 1]);
legend('40uA 200Hz','40uA 400Hz','80uA 200Hz');
title('Caesar Session 2 Stimulation Middle Stats')
xlabel('stimulation duration (ms)');
ylabel('peak eye position (deg)');
box off;
%%
selected = [16,18]; %amplitude 40uA, frequency 200Hz Shell
n_file = zeros(length(Refined_Data2),1);


for i = 1:length(Refined_Data2)
    n_file(i,1) = Refined_Data2{i,1}.number;
    [n_idx,~] = find(n_file == selected);
end
%%
n_sample = length(n_idx);
sample = cell(length(n_sample),6);

for i = 1:n_sample
    sample{i,1} = Refined_Data2{n_idx(i),1}.ehp_ipsi;
    sample{i,2} = Refined_Data2{n_idx(i),1}.ehp_contra;
    sample{i,3} = -min(Refined_Data2{n_idx(i),1}.ipsi_ehp_avg(prebuffer:end));
    sample{i,4} = Refined_Data2{n_idx(i),1}.dur;
    sample{i,5} = Refined_Data2{n_idx(i),1}.freq;
    sample{i,6} = Refined_Data2{n_idx(i),1}.current;
end

%%
X4 = cell2mat(sample(1:n_sample,4))';
Y4 = cell2mat(sample(1:n_sample,3))';
%%
selected = [15,17]; %amplitude 40uA, frequency 200Hz Shell
n_file = zeros(length(Refined_Data2),1);


for i = 1:length(Refined_Data2)
    n_file(i,1) = Refined_Data2{i,1}.number;
    [n_idx,~] = find(n_file == selected);
end
%%
n_sample = length(n_idx);
sample = cell(length(n_sample),6);

for i = 1:n_sample
    sample{i,1} = Refined_Data2{n_idx(i),1}.ehp_ipsi;
    sample{i,2} = Refined_Data2{n_idx(i),1}.ehp_contra;
    sample{i,3} = -min(Refined_Data2{n_idx(i),1}.ipsi_ehp_avg(prebuffer:end));
    sample{i,4} = Refined_Data2{n_idx(i),1}.dur;
    sample{i,5} = Refined_Data2{n_idx(i),1}.freq;
    sample{i,6} = Refined_Data2{n_idx(i),1}.current;
end

%%
X5 = cell2mat(sample(1:n_sample,4))';
Y5 = cell2mat(sample(1:n_sample,3))';
%%
selected = [13,14]; %amplitude 40uA, frequency 200Hz Shell
n_file = zeros(length(Refined_Data2),1);


for i = 1:length(Refined_Data2)
    n_file(i,1) = Refined_Data2{i,1}.number;
    [n_idx,~] = find(n_file == selected);
end
%%
n_sample = length(n_idx);
sample = cell(length(n_sample),6);

for i = 1:n_sample
    sample{i,1} = Refined_Data2{n_idx(i),1}.ehp_ipsi;
    sample{i,2} = Refined_Data2{n_idx(i),1}.ehp_contra;
    sample{i,3} = -min(Refined_Data2{n_idx(i),1}.ipsi_ehp_avg(prebuffer:end));
    sample{i,4} = Refined_Data2{n_idx(i),1}.dur;
    sample{i,5} = Refined_Data2{n_idx(i),1}.freq;
    sample{i,6} = Refined_Data2{n_idx(i),1}.current;
end

%%
X6 = cell2mat(sample(1:n_sample,4))';
Y6 = cell2mat(sample(1:n_sample,3))';
%%
figure;
scatter(X4,Y4,"filled",'MarkerFaceColor',[1 0 0]);
hold on
scatter(X5,Y5,"filled",'MarkerFaceColor',[0 0 1]);
scatter(X6,Y6,"filled",'MarkerFaceColor',[0 1 0]);
legend('40uA 200Hz','80uA 200Hz','85uA 200Hz');
title('Caesar Session 2 Stimulation Shell Stats')
axis([-inf inf 10 35])
xlabel('stimulation duration (ms)');
ylabel('peak eye position (deg)');
box off;