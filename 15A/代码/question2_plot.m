clc,clear
close all

x = [115.401 23.46 -150.30 115.40];
y = [-2.249 87.85 86.03 23.55];

hold on
plot(linspace(-180,180,100),10.6466 .* ones(100,1),'LineWidth',3)
plot(x,y,'o','MarkerSize',10,'LineWidth',2)
axis([-180,180,-10,90])
hold off