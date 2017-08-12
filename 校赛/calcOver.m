function [ over_time ] = calcOver( t )
    if (t >=0 & t<=40)
        over_time = t + 80;
    elseif (t > 40 & t <= 120)
        over_time = 7/8*t + 85;
    elseif (t > 120 & t <= 530)
    	over_time = t + 70;
    elseif (t > 530 & t <= 600)
    	over_time = 8/7 * t - 40/7;
    elseif (t > 600 & t <= 640)
    	over_time = t + 80;
    elseif (t > 640 & t <=720)
    	over_time = 15/16 * t + 120;
    else
    	over_time = t + 75;
    end
end

