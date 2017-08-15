clc,clear
close all

%% ******************************** 读取 *********************************
% 1. position : 1列编号、2列 x 坐标、3列 y 坐标、4列海拔、5列功能区
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
area{1} = position(index1,:);
area{2} = position(index2,:);
area{3} = position(index3,:);
area{4} = position(index4,:);
area{5} = position(index5,:);

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

% figure(2)
% hold on
% contour(X,Y,Z,8)
% for i = 1:length(position)
% 	switch function_zone(i)
% 		case 1
% 			ax1 = plot3(x(i),y(i),z(i),'or','markersize',10);
% 		case 2
% 			ax2 = plot3(x(i),y(i),z(i),'*k','markersize',10);
% 		case 3
% 			ax3 = plot3(x(i),y(i),z(i),'+b','markersize',10);	
% 		case 4
% 			ax4 = plot3(x(i),y(i),z(i),'sm','markersize',10);	
% 		case 5
% 			ax5 = plot3(x(i),y(i),z(i),'pg','markersize',10);		
% 	end
% end
% leg = legend([ax1,ax2,ax3,ax4,ax5],'生活区','工业区','山区','交通区','公园绿地区');
% xlabel('x/m')
% ylabel('y/m')
% title('城市二维等高线图')
% hold off;

%% ********************************  *********************************
