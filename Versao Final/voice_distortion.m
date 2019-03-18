clear all; close all; clc
clear clc;

%%%%%%%%%%%%%Gravando audio do Microfone%%%%%%%%%%%%%%%%%%%%
%voz = audioread('C:\Users\vaio\Desktop\teste1.wav');
fs = 44100;%frequência de amostragem
recorder = audiorecorder(fs, 16, 1);%instanciando sistema de gravaçao com 16 bits, 44100Hz no canal mono
disp('Iniciando gravação...');
record(recorder)%gravando
pause(5);%tempo de gravação = 5s
stop(recorder);%fim da gravação
disp('gravação encerrada...');
voz = getaudiodata(recorder, 'double');%recupera o sinal de audio

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
audiowrite('audio_original.wav', voz, fs);%grava o sinal num arquivo .wav

%%%%%%%%%%%%%%%%%%%plota voz original%%%%%%%%%%%%%%%%%%
subplot(3,2,1);%posiciona o gráfico
Nvoz = size(voz,1);%quantidade de amostras do sinal de voz
t = linspace(0,Nvoz/fs,Nvoz);%vetor de tempo de acordo com o teorema da amostragem
plot(t,voz); %plotagem
title('Voz Original');
xlabel('tempo(s)');
ylabel('amplitude');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%calcula a fft da voz e plota%%%%%%%%%%%%%%%
A = fft(voz);%FFT do Sinal de voz 
N = size(A,1);%quantidade de amostras dele
Fbin = 0:1:N-1;%vetor de indices da FFT
subplot(3,2,2);
plot((fs/N).*Fbin, abs(A)/(N/2)); %conversão Fbins -> Freq em Hz
title('FFT da Voz Original');
xlabel('$f(Hz)$','Interpreter','Latex','FontSize',18);
ylabel('$|X(\omega)|$','Interpreter','Latex','FontSize',18);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%remover algumas frequÃªncias antes do shift%%%%
k = 800;%quantidade de frequencias a serem removidos

B = zeros(size(A));%futuro vetor que armazenará o resultado do deslocamento -> inicializado com zeros

%Esse laço executa o deslocamento da FFT do sinal de voz da direita para a
%esquerda, forçando a perda das  K menores frequencias
for n = 1: size(A) - k  
   B(n,1) = A(k+n,1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%Deslocamento para a Direita%%%%%%%%%%%%%%%%%%%%%%%%
d = 15000;%tamanho do deslocamento
r = 1;%variavel de apoio do loop
C = zeros(size(B));%futuro vetor que armazenará o resultado do deslocamento -> inicializado com zeros ->Será a FFT do sinal deslocado

%Esse laço executa o deslocamento da FFT do sinal de voz da esquerda para a
%direita, deslocando o espectro em d Hertz
for n2 = d+1:size(B)+d
    C(n2,1) = B(r,1);
    r = r + 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%plota a voz modificada%%%%%%%%%%%%%%%%
N2 = size(C,1);%numero de amostras da FFT do sinal distorcido 
Fbin2 = 0:1:N2-1;%Vetor de indices da DFT
subplot(3,2,4);%posicionamento do gráfico
plot((fs/N2).*Fbin2, abs(C)/(N2/2)); %plota a voz modificada na frequÃªncia 
title('FFT da Voz Alterada');
xlabel('$f(Hz)$','Interpreter','Latex','FontSize',18);
ylabel('$|X(\omega)|$','Interpreter','Latex','FontSize',18);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%plota ifft da voz modificada no tempo%%%%%%%
D = ifft(C);%vetor da IFFT do sinal modificado
Nvoz2 = size(D,1);%quantidade de amostras
t2 = linspace(0,Nvoz2/fs,Nvoz2);%vetor de tempo de acordo com o teorema da amostragem 
subplot(3,2,3);%posicionamento do gráfico
plot(t2,abs(D)); %plota a voz modificada no dominio do tempo 
title('IFFT da Voz Alterada');
xlabel('tempo(s)');
ylabel('amplitude');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%Reproduz a ifft da voz modificada%%%%%%%%%%%%%%%
%soundsc(abs(Z), fs);
ap = audioplayer(D*4, fs);%aumenta um pouco o volume do sinal distorcido, e o executa
play(ap);
disp('Executando o audio distorcido...');
audiowrite('audio_distorcido.wav', D, fs);%grava o sinal distorcido num arquivo .wav
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fftD = fft(D);%gera novamente a fft do sinal distorcido (só pra seguir o fluxograma feito na sessão)
E = zeros(size(fftD));%vetor que guardará o resultado do deslocamento no sentido contrário, em d Hertz
b = 1;

%Esse loop executa o deslocamento do espectro de frequencias em d Hertz
for n2 = d+1 : size(fftD)
   E(b, 1) = fftD(n2,1);
   b = b + 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%plota fft da voz recuperada%%%%%%%%%%%%%%%%
N3 = size(E,1);%quantidade de amostras da FFT do sinal recuperado
Fbin2 = 0:1:N3-1;%vetor de indices
subplot(3,2,6);%posicionamento do grafico
plot((fs/N3).*Fbin2, abs(E)/(N2/2)); %plota a voz recuperada na frequÃªncia 
title('FFT da Voz Recuperada');
xlabel('$f(Hz)$','Interpreter','Latex','FontSize',18);
ylabel('$|X(\omega)|$','Interpreter','Latex','FontSize',18);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%Plotando o audio recuperado sem shifting%%%%%%%%%%%%%
recuperado = ifft(E);%ifft do sinal recuperado
Nvoz3 = size(recuperado,1);%numero de amostras dele
t3 = linspace(0,Nvoz3/fs,Nvoz3);%vetor tempo

subplot(3,2,5);%posicionamento do gráfico
plot(t3,abs(recuperado)); %plota a voz recuperada no domínio do tempo 
title('IFFT da Voz Recuperada');
xlabel('tempo(s)');
ylabel('amplitude');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%Executando o audio recuperado sem shifting%%%%%%%%%%%%
ap2 = audioplayer(recuperado, fs);%executa o audio
pause(7);%gera um pause de 7 segundos entre o começo da reprodução do audio do sinal distorcido e o começo da exibição do sinal recuperado
disp('Executando o audio recuperado...');
play(ap2);
audiowrite('audio_recuperado.wav', recuperado, fs);%grava o sinal recuperado num arquivo .wav
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

