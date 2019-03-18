clear all; close all; clc

%AMOSTRAGEM NO TEMPO
% dados do sinal
f = 60;%Freq entrada Hz
fs= 121 ;% Frequencia de amostragem Hz

% gerar sinal
tempo = [0:1/(100*f):10/f];%Tempo amostral
sinal = sin(2*pi*f*tempo); % Gera��o onda senoidal

% plotar sinal
subplot(2,2,1)
plot(tempo,sinal)
hold on;

% sinal amostrado
Ts = 1/fs;      %per�dodo de amostragem
N=1001;          %N�mero de amostras
n = [0:1:N-1];  % Vetor 0 a 100, n unidade de tempo discreta
t_sample = [0 : Ts : n(N)*Ts];  %Tempo de amostragem

DigitalFrequency=2*pi*f/fs; %frequencia de um sinal discreto
sinal_sample = sin (DigitalFrequency.*n); % sinal amostrado
plot(t_sample, sinal_sample,'o');
axis([0 10/f -1.5 1.5])
set(gca,'FontSize',16)
xlabel('$t$','Interpreter','LaTex','FontSize',18)
ylabel('$x[nT_s],x(t)$','Interpreter','LaTex','FontSize',18)







x=sinal_sample;

N = length(x);                      % vari�vel N recebe o tamanho do vetor x
k = 0:N-1;                          % k � um vetor que vai de zero at� N menos 1
T = N/fs;                           % Vetor de tempo N dividido pela frequ�ncia de amostragem
freq = k/T;
X = fftn(x)/N;                      % X recebe a FFT normalizada do vetor x sobre N

subplot(2,1,2)
plot(freq,abs(X));        % Plota a transformada de Fourier e o valor de X em m�dulo
title('Fast Fourier Transform');
xlabel('Frequency (Hz)');
ylabel('Amplitude');




















subplot(2,2,2)
x = [-1:0.01:1];
y = sqrt(1 - x.^2);
z = -sqrt(1 - x.^2);

i = 1;
indo = 1;
count = 0.0;
while true
    if indo >= 1
        i = i - 0.1;
        if i > -1
            z1 = sqrt(1 - i.^2);
        else
           indo = 0;
        end
    else
       i = i + 0.1;
       if i < 1
            z1 = -sqrt(1 - i.^2);
        else
           indo = 1;
       end
    end
    count = count + 0.1;
    
    if i > 1 
        t = 0;
    else if i < -1
         t = 0;
    else
        if count >= 0.1
            plot(x, y, x, z);
            plot(x,y,x,z,i,z1,'--ro');
            line([0 i],[0 z1])
            pause(1.0);
            count=0;
        else
           pause(0.1);
        end
     end
    end
    
   
end
    
    