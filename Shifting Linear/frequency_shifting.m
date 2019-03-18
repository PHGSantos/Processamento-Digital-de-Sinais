clear all; close all; clc
clear clc;

%%%%%%%%%%%%%Gravando audio do Microfone%%%%%%%%%%%%%%%%%%%%
%voz = audioread('C:\Users\vaio\Desktop\teste1.wav');
fs = 44100;
recorder = audiorecorder(fs, 16, 1);
disp('Iniciando gravação...');
record(recorder);
pause(5);
stop(recorder);
disp('gravação encerrada...');
voz = getaudiodata(recorder, 'double');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
audiowrite('C:\Users\vaio\Desktop\Minhas Coisas\Matlab Projects\Problema III\Shifting Linear\audio_original.wav', voz, fs);

%subplot(linhas,colunas,ordem);

%%%%%%%%%%%%%%%%%%%plota voz original%%%%%%%%%%%%%%%%%%
subplot(3,2,1);
plot(voz); 
title('Voz Original');
xlabel('tempo');
ylabel('amplitude');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%calcula a fft da voz e plota%%%%%%%%%%%%%%%
A = fft(voz);
%L =size(voz,1);
%S = L/fs;%duração do audio em segundos

N = size(A,1);
Fbin = 0:1:N-1;
subplot(3,2,2);
plot((fs/N).*Fbin, abs(A)/(N/2)); 
%xlim([0 fs/2]);
title('FFT da Voz Original');
xlabel('$f(Hz)$','Interpreter','Latex','FontSize',18);
ylabel('$|X(\omega)|$','Interpreter','Latex','FontSize',18);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%remover algumas frequências antes do shift%%%%
k = 800;

B = zeros(size(A));

for n = 1: size(A) - k  
   B(n,1) = A(k+n,1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%Shifing%%%%%%%%%%%%%%%%%%%%%%%%
d = 2000;
r = 1;
C = zeros(size(B));
for n2 = d+1:size(B)+d
    C(n2,1) = B(r,1);
    r = r + 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%plota a voz modificada%%%%%%%%%%%%%%%%
%figure();
N2 = size(C,1);
Fbin2 = 0:1:N2-1;
subplot(3,2,3);
plot((fs/N).*Fbin2, abs(C)/(N2/2)); %plota a voz modificada na frequência 
%plot(abs(C));
title('FFT da Voz Alterada');
xlabel('$f(Hz)$','Interpreter','Latex','FontSize',18);
ylabel('$|X(\omega)|$','Interpreter','Latex','FontSize',18);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%plota ifft da voz modificada no tempo%%%%%%%
D = ifft(C);
subplot(3,2,4);
plot(abs(D)); %plota a voz modificada no tempo 
title('IFFT da Voz Alterada');
xlabel('tempo');
ylabel('amplitude');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%Reproduz a ifft da voz modificada%%%%%%%%%%%%%%%
%soundsc(abs(Z), fs);
ap = audioplayer(D*4, fs);
play(ap);
disp('Executando o audio distorcido...');
audiowrite('C:\Users\vaio\Desktop\Minhas Coisas\Matlab Projects\Problema III\Shifting Linear\audio_distorcido.wav', D, fs);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fftD = fft(D);
E = zeros(size(fftD));
b = 1;
for n2 = d+1 : size(fftD)
   E(b, 1) = fftD(n2,1);
   b = b + 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%Plotando o audio recuperado sem shifting%%%%%%%%%%%%%
recuperado = ifft(E);
subplot(3,2,5);
plot(abs(recuperado)); %plota a voz modificada no tempo 
title('IFFT da Voz Alterada');
xlabel('tempo');
ylabel('amplitude');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%Executando o audio recuperado sem shifting%%%%%%%%%%%%
ap2 = audioplayer(recuperado, fs);
pause(7);
disp('Executando o audio recuperado...');
play(ap2);
audiowrite('C:\Users\vaio\Desktop\Minhas Coisas\Matlab Projects\Problema III\Shifting Linear\audio_recuperado.wav', recuperado, fs);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
