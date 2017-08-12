clc,clear
close all
tic
%% ******************************** 读取数据 *********************************
% 1. mindist : 各个点之间的最短距离矩阵
% 2. agg : 添加点的集合
load mindist
load agg5

%% ******************************** 数据初始化 *********************************
global service_road
global num_service
global num
global y0   % 一次分配之后各站点的发案总数
global w    % 一次分配之后需要继续分配的路口的发案数
global lcase

minS = inf;
for k = 1:size(agg,1)
    service = [1:20,agg(k,:)]';              % 服务站点
    num_service = length(service);  % 服务站点的数量
    mindistA = mindist(1:92,1:92);  % A 区各个点之间的最短距离
    service_road = mindistA(service,:);
    isInclude = zeros(1,92);        % 包含在 3 分钟内的取 1，不包含的取 0
    numInclude = zeros(1,92);       % 包含在 3 分钟内的重叠个数
    belong = cell(num_service,2);   % 各个地点隶属的服务区
    num = cell(num_service,2);      % 到各个服务站比 3 小的地区
    can = zeros(num_service,92);             % 能否分配
    lcase = lcase(1:92);            % 发案率
    
    %% ******************************** 将能直接分配的分配掉 *********************************
    for i = 1:num_service
        num{i,1} = service(i);
        belong{i,1} = service(i);
    end
    
    for i = 1:num_service
        num{i,2} = find(service_road(i,:)<=3);
        can(i,num{i,2}) = 1;          % 将当前服务站能分配的地区赋 1        
        isInclude(num{i,2}) = 1;
        numInclude(num{i,2}) = numInclude(num{i,2}) + 1;
        belong{i,2} = [belong{i,2},i];      % 地区本地分配给服务站本地
    end
    
    ge3 = find(numInclude == 0);    % 大于 3 分钟的地区
    belong = GE3(belong,ge3);
    
    D = setdiff([1:92],service');         % A 区中不是服务站的点
    eq1 = D(find(numInclude(D) == 1));    % 覆盖率为 1 的地区
    belong = EQ1(belong,eq1);
    
    % 以上分配完还剩49个
    remove = [service',eq1,ge3];
    temp_all = ones(1,92);
    temp_all(remove) = 0;
    left = find(temp_all == 1);      % 未分配的
    showLeft = [[1:length(left)]',left'];   % 未分配的对应关系矩阵
    can2 = can(:,left);         % 未分配的能分配矩阵
    
    y0 = zeros(num_service,2);       % 到目前为止分配后站点的案件数
    y0(:,1) = service;
    for i = 1:num_service
        y0(i,2) = sum(lcase(belong{i,2}));
    end
    
    %% ******************************** 剩下的路口在哪些站点的范围内 *********************************
    
    left_from = cell(length(left),2);  % 剩下的路口被几个站点包容
    left_from_index = zeros(length(left),1);    % 就是 left 这里变量冗余了
    for i = 1:length(left)
        left_from_index(i) = left(i);
        left_from{i,1} = left(i);
        for j = 1:length(num)
            if ismember(left(i),num{j,2})
                left_from{i,2} = [left_from{i,2},num{j,1}];
            end
        end
    end
    
    %% ******************************** 遗传算法 *********************************
    % 遗传算法参数
    lb = ones(1,length(left));  % 下界
    ub = numInclude(left);      % 上界
    NIND = 50;                  % 种群大小
    MAXGEN = 100;                % 最大遗传代数
    PRECI = 10;   % 种群长度
    GGAP = 0.95;                % 代沟
    px = 0.8;                   % 交叉概率
    pm = 0.01;                  % 变异概率
    left_num = length(left);    % 剩下路口的个数
    trace = zeros(MAXGEN,left_num+1);   % 寻优结果初始值
    Field = [repmat(PRECI,1,left_num);lb;ub;ones(1,left_num);zeros(1,left_num);ones(1,left_num);ones(1,left_num)];  % 区域描述器
    Chrom = crtbp(NIND,PRECI * left_num);   % 创建任意离散随机种群
    % 优化
    gen = 0;        % 当前代数
    X = round(bs2rv(Chrom,Field));     % 初始种群的十进制转换
    ObjV = X2Value(X,left_from,y0,belong,agg(k,:));      % 计算目标函数值
    while gen < MAXGEN
        FitnV = ranking(ObjV);                  % 分配适应度
        SelCh = select('sus',Chrom,FitnV,GGAP); % 选择
        SelCh = recombin('xovsp',SelCh,px);     % 重组
        SelCh = mut(SelCh,pm);                  % 变异
        X = round(bs2rv(SelCh,Field));
        ObjVSel = X2Value(X,left_from,y0,belong,agg(k,:));   % 计算子代的目标函数值
        [Chrom,ObjV] = reins(Chrom,SelCh,1,1,ObjV,ObjVSel); % 重插入得到新种群
        X = round(bs2rv(Chrom,Field));
        gen = gen + 1;
        [Y,I] = min(ObjV);
        trace(gen,1:end-1) = X(I,:);            % 记下每代的最优解
        trace(gen,end) = Y;                     % 记下每代的最优值
    end 
    
    % trace
    % trace(:,end)
    result = X2Road(trace(end,1:end-1),left_from);
    result = [left;result]';
    for i = 1:size(result,1)
        if result(i,2) > 20
            result(i,2) = 20 + find(result(i,2) == agg(k,:));
        end
        belong{result(i,2),2} = [belong{result(i,2),2},result(i,1)];
        belong{result(i,2),2} = sort(belong{result(i,2),2});
    end

    if minS > trace(end,end)
        minS = trace(end,end);
        result_belong = belong;
        agg_result = agg(k,:);
    end

end

toc

%% ******************************** 子函数 *********************************
%% GE3: 归类没有覆盖的区域
function [belong] = GE3(belong,ge3)
    global num_service
    global service_road
    for i = 1:length(ge3)
        temp = service_road([1:num_service]',ge3(i));       % 需要分配的地区的列
        index = find(temp == min(temp));    % 找到分配地区到服务站最短距离的服务站
        belong{index,2} = [belong{index,2},ge3(i)];
        belong{index,2} = sort(belong{index,2});
    end
end

%% ******************************** 子函数 *********************************
%% EQ1: 归类覆盖率为 1 的区域
function [belong] = EQ1(belong,eq1)
    global num_service
    global num
    for i = 1:length(eq1)
        temp = eq1(i);      % 需要分配的数
        for j = 1:num_service
            if ismember(temp,num{j,2})
                belong{j,2} = [belong{j,2},temp];
                belong{j,2} = sort(belong{j,2});
                break;
            end
        end
    end
end


%% ******************************** 遗传子函数 *********************************
%% X2Value: 把每行 X 代表的值转换为方差
% Y 是分数，是 种群数目 * 1 的矩阵，表示每个种群的方差
function [Y] = X2Value(X,left_from,y0,belong,agg)
    global lcase
    X_row = size(X,1);
    Y = zeros(X_row,1);
    for i = 1:X_row
        temp_belong = belong;
        temp_y = y0(:,2);
        for j = 1:size(X,2)
            road = left_from{j,1};         % 该路口序号
            station = left_from{j,2}(X(i,j));  % 该路口选择的站点
            if station > 20
               station = 20 + find(agg == station);
            end
            temp_belong{station,2} = [temp_belong{station,2},road];     % 把路口加入站点
            temp_belong{station,2} = sort(temp_belong{station,2});      % 排序
            temp_y(station) = temp_y(station) + lcase(road);            % 把路口工作量加入站点
        end
        Y(i) = std(temp_y,1);
    end
end

%% ******************************** 遗传子函数 *********************************
%% X2Road: 把每行 X 转换为对应的站点
function [R] = X2Road(X,left_from)
    X_row = size(X,1);
    X_col = size(X,2);
    R = zeros(X_row,X_col);
    for i = 1:X_row
        for j = 1:size(X,2);
            station = left_from{j,2}(X(i,j));  % 该路口选择的站点
            R(i,j) = station;
        end
    end  
end