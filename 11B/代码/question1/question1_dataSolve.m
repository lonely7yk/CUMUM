clc,clear
close all

%% ******************************** 读取数据 *********************************
coord = xlsread('/Users/shengliyi/Documents/MATLAB/比赛Matlab/11B/代码/data.xlsx',1,'B2:C583');
road = xlsread('/Users/shengliyi/Documents/MATLAB/比赛Matlab/11B/代码/data.xlsx',2,'A2:B929');
lcase = xlsread('/Users/shengliyi/Documents/MATLAB/比赛Matlab/11B/代码/data.xlsx',1,'E2:E583'); % 事件数
zhipai = xlsread('/Users/shengliyi/Documents/MATLAB/比赛Matlab/11B/代码/data.xlsx',4,'C2:C14'); % 指派地点

%% ******************************** 计算所有地点间的最短距离 *********************************
n = size(coord,1);      % n 为所有地点的个数
dist = zeros(n);      % 表示每个点到其他所有点的直接距离，没有的话是无穷
dist(:,:) = inf;
dist(1:n+1:n^2) = 0;
for i = 1:length(road)
    temp = road(i,:);
    a = coord(temp(1),:);
    b = coord(temp(2),:);
    d = pdist([a;b],'euclidean') / 10;  % 因为单位是百米，转化到千米就要除以 10
    dist(temp(1),temp(2)) = d;
    dist(temp(2),temp(1)) = d;
end
[mindist,minpath] = myfloyd(dist);
save mindist mindist lcase zhipai
save dist mindist dist

%% 弗洛伊德算法
function [dists,paths,dist,mypath]=myfloyd(a,sb,db)
    % 输入：
    % a--邻接矩阵；元素a(i.j)--顶点i到j之间的直达距离，可以是有向的
    % sb--起点的标号
    % db--终点的标号
    
    % 输出：
    % dist--最短路的距离
    % mypath--最短路的路径
    
    n=size(a,1);paths=zeros(n);
    for k=1:n
        for i=1:n
            for j=1:n
                if a(i,j)>a(i,k)+a(k,j)
                    a(i,j)=a(i,k)+a(k,j);
                    paths(i,j)=k;
                end
            end
        end
    end
    dists = a;

    if nargin == 3
        dist=a(sb,db);
        parent=paths(sb,:); %从起点sb到终点db的最短路上各顶点的前驱顶点
        parent(parent==0)=sb; %path中的分量为0，表示该顶点的前驱是起点
        mypath=db;t=db;
        while t~=sb
            p=parent(t);mypath=[p mypath];
            t=p;
        end
    end
end