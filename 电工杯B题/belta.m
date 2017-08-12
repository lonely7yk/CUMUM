function y = belta(t,i)
	g = (0.08 / t * i^2 + 1) * (t^2 - 1995 * t - 5444) / (t^2 - 1995 * t);
	y = g / (1 + g);
end