clc,clear
close all
t = 2015:2050;
line1 = load('line1');
line2 = load('line2');
p1 = line1.p;
p2 = line2.p;
l1 = plot(t,p1,'r');
hold on
l2 = plot(t,p2,'b');
legend([l1,l2],'全面二胎政策前','全面二胎政策后');
xlabel('年份/年');
ylabel('综合评价');
title('综合评价曲线');