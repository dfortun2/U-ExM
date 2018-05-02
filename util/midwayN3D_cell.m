function [u_midway]=midwayN3D_cell(u)
%% Volumes must have the same size

N=length(u);

u_midway=cell(N,1);

u_sort=zeros(size(u{1},1)*size(u{1},2)*size(u{1},3),N);
index_u=zeros(size(u{1},1)*size(u{1},2)*size(u{1},3),N);
for i=1:N
    ui=u{i};
    [u_sort(:,i) ,index_u(:,i)] = sort(ui(:));
end

for i=1:N
    tmp=u_midway{i};
    tmp(index_u(:,i)) = sum(u_sort,2)/N;
    u_midway{i} = reshape(tmp ,size(u{i}));
end


