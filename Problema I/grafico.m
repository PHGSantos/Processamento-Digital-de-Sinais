syms x;
fx = abs(1+exp(-1*i*x) + exp(-2*i*x) + exp(-3*i*x));
omega = linspace(-15, 15, 1000);
y = subs(fx,x,omega);
plot(omega,y);