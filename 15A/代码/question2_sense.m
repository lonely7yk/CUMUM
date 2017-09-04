clear,clc
close all 

best = [115.401 -2.249];
changp = [119.489 10.89; 135.759 10.647; 156.621 11.065; 101.256 10.647];
D = pdist2(best,changp)
plot(D)