clc,clear
close all

%% ******************************** 读取 *********************************
% 1. position : 1列编号、2列 x 坐标、3列 y 坐标、4列海拔、5列功能区
% 2. density : 1列编号、2列 As、3列 Cd、4列 Cr、5列 Cu、6列 Hg、7列 Ni、8列 Pb、9列 Zn
load Q1

%% ******************************** 初始化 *********************************
seq = position(:,1);		% 序号
x = position(:,2);			% x 坐标
y = position(:,3);			% y 坐标
z = position(:,4);			% 海拔
function_zone = position(:,5);	% 功能区
index1 = find(position(:,5) == 1);	% 区域一的索引
index2 = find(position(:,5) == 2);	% 区域二的索引
index3 = find(position(:,5) == 3);	% 区域三的索引
index4 = find(position(:,5) == 4);	% 区域四的索引
index5 = find(position(:,5) == 5);	% 区域五的索引
area{1} = position(index1,:);	% 区域 1 位置
area{2} = position(index2,:);	% 区域 2 位置
area{3} = position(index3,:);	% 区域 3 位置
area{4} = position(index4,:);	% 区域 4 位置
area{5} = position(index5,:);	% 区域 5 位置
pollute{1} = density(index1,2:end);	% 区域 1 污染
pollute{2} = density(index2,2:end);	% 区域 2 污染
pollute{3} = density(index3,2:end);	% 区域 3 污染
pollute{4} = density(index4,2:end);	% 区域 4 污染
pollute{5} = density(index5,2:end);	% 区域 5 污染
background = [3.6	130	31	13.2	35	12.3	31	69];	% 各种金属的背景值
T = [10	30	2	5	40	5	5	1];			% 各指标的毒性系数

%% ******************************** 三维插值，城市三维地形图 *********************************

% [X,Y,Z] = griddata(x,y,z,linspace(min(x),max(x))',linspace(min(y),max(y)),'v4');
% figure(1)
% mesh(X,Y,Z);
% xlabel('x/m')
% ylabel('y/m')
% zlabel('海拔/m')
% title('城市三维地形图')


%% ******************************** 二维图，城市二维等高线图 *********************************
% 1. 红：生活区 2. 黑：工业区 3. 蓝：山区 4. 紫：交通区 5. 绿：公园绿地区

% [X,Y,Z] = griddata(x,y,z,linspace(min(x),max(x))',linspace(min(y),max(y)),'v4');
% figure(2)
% hold on
% ContourMap(X,Y,Z,x,y,function_zone,0);
% xlabel('x/m')
% ylabel('y/m')
% title('城市二维等高线图')
% hold off;

%% ******************************** 三维插值，把 z 轴变为浓度 *********************************
% z1 = density(:,2);
% [X,Y,Z] = griddata(x,y,z1,linspace(min(x),max(x))',linspace(min(y),max(y)),'v4');
% figure
% hold on
% ContourMap(X,Y,Z,x,y,function_zone,1)
% xlabel('x(m)')
% ylabel('y(m)')
% hold off
% colorbar

%% ******************************** 浓度和海拔的关系 *********************************
% hold on
% for i = 1:8
% 	figure(i)
% 	density_z = density(:,i+1);
% 	for j = 1:62
% 		index_z = find(z <= 5 * j & z >= 5 * j - 4);
% 		mean5(j) = mean(density_z(index_z));
% 	end
% 	bar(5:5:310,mean5);
%     xlabel('海拔(m)')
%     if i == 2 || i == 5
%         ylabel('浓度(μg/g)')
%     else
%         ylabel('浓度(ng/g')
%     end

% end
% hold off

%% ******************************** 浓度的平均值 *********************************
pollute_average = [];
for i = 1:length(pollute)
	pollute_average(i,:) = mean(pollute{i},1);
end

%% ******************************** Hakanson *********************************
Cr = pollute_average ./ background;	% 污染指数
Er = Cr .* T;		% 各指标的风险值
RI = sum(Er,2);		% 风险系数

%% ContourMap: 画二维等高线图
function ContourMap(X,Y,Z,x,y,function_zone,command)
	if command == 0
		contour(X,Y,Z,8)
	else
		contourf(X,Y,Z,8)
	end
	for i = 1:length(x)
		switch function_zone(i)
			case 1
				ax1 = plot(x(i),y(i),'or','markersize',8,'Linewidth',1.5);
			case 2
				ax2 = plot(x(i),y(i),'*k','markersize',8,'Linewidth',1.5);
			case 3
				ax3 = plot(x(i),y(i),'+b','markersize',8,'Linewidth',1.5);	
			case 4
				ax4 = plot(x(i),y(i),'sm','markersize',8,'Linewidth',1.5);	
			case 5
				ax5 = plot(x(i),y(i),'pg','markersize',8,'Linewidth',1.5);		
		end
    end
	leg = legend([ax1,ax2,ax3,ax4,ax5],'生活区','工业区','山区','交通区','公园绿地区');
    set(leg,'Location','southeast')
end