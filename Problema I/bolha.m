%desenha o circulo
clc
r = 1; xc = 0; yc = 0;
theta = linspace(0,2*pi);
x = r*cos(theta) + xc; y = r*sin(theta) + yc;
plot(x,y)
title('Simulação da Amostragem no Tempo');
axis(gca, 'equal');
axis([-1.5 1.5 -1.5 1.5]);


%Superamostragem (f > 2*fs)
%Parado (f = 2*fs)
%Aliasing (f < 2*fs)

f = 10; %frequencia do sinal (ventilador)
fs = 3; %frequencia de amostragem
Ts = 1/fs;

w = -2*pi*f; %giro no sentido horário
%t = 0;
n = 0;

while n <= 100
    
        t = n*Ts;
        disp('tempo');
        disp(t)
        pos_x = cos(w*t);
        pos_y = sin(w*t);
        pos = r*[pos_x,pos_y];
        bola = viscircles(pos,0.05);
        pause(0.5);
        delete(bola);
        disp('numero do pulso');
        disp(n); 
        n = n + 1;
  
    %t = t+0.1;
    
end

    %pos_x = cosd(w*(t));
    %pos_y = sind(w*(t));
    %pos = r*[pos_x,pos_y];
    %bola = viscircles(pos,0.05);
    %pause(0.1);
    %delete(bola);    
    