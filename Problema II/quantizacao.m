t = linspace(0,1,1001);

%Onda Senoidal
V1 = 5.12/2;
f1 = 2;
fase = 0;
senoide = V1*sin(2*pi*f1*t + fase);
plot(t, senoide);

%Onda Quadrada
%V2 = 5.12/2;
%f2 = 2;
%quadrada = square(2*pi*f2*t);
%plot(t, quadrada);
%axis([-0.1 1.1 -1.1 1.1]);