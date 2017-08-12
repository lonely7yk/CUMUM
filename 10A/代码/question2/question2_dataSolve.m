clc,clear('all');
close all;

bias_before = xlsread('d2.xlsx','D2:F303');
bias_after = xlsread('d2.xlsx','D305:F604');
bias_before = bias_before ./ 1000;
bias_after = bias_after ./ 1000;


save data2