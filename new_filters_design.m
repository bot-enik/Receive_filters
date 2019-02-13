%% #################### Generate filters for new specification ###########
% 

% Расчет параметров RRC фильтра:
% ups_factor = 8;
% roll_off = 0.35;
% 
% Fs_init = 18e3;
% Ts_init = 1/Fs_init;
% 
% F1 = (1-roll_off) / (2*Ts_init)
% F  = (1) / (2*Ts_init)
% F2 = (1+roll_off) / (2*Ts_init)


% Требования: 
% 1. Подавление на 25кГц (0.34 рад/сек)  не менее 60дБ
% 2. Подавление на 50кГц (0.69 рад/сек)  не менее 83дБ
% 3. Подавление на 72кГц (1 рад/сек)     не менее 100дБ
% 4. Гладкая ровная АЧХ в полосе пропускания RRC фильтра:
%    до 12.150кГц (0.17 рад/сек)

%% Генерация фильтра приподнятого косинуса

% RRC
% All frequency values are in kHz.
Fs   = 144;        % Sampling Frequency
N    = 112;        % Order (to achieve 60dB on 25kHz (without dop filter) 
%                                                       we need 112 order)
Fc   = 9;          % Cutoff Frequency
TM   = 'Rolloff';  % Transition Mode
R    = 0.35;       % Rolloff
DT   = 'sqrt';     % Design Type
Beta = 0.5;        % Window Parameter

Initial_RRC = RRC_matlab(Fs, N, Fc, TM, R, DT, Beta);
Initial_RRC_Numerator = Initial_RRC.Numerator;
% fvtool(Initial_RRC, 'Analysis', 'impulse');

b = rcosdesign(0.35,N/8,8,'sqrt');

% b.Numerator = b.Numerator./max(b.Numerator)
fvtool(b)

%% Генерация максимально гладкого фильтра 

Nf = 64;           % Order
Fcnorm = 0.24;     % Cutoff normalized frequency 

Max_Flat = Max_Flat_matlab(N, Fcnorm);
fvtool(Max_Flat);

%% Тестирование АЧХ суммарных фильтров

% Генерируем тестовый сигнал (дельта-функция)
Fs = 144e3;
L  = (N + Nf);

delta =  [1 zeros(1,L/2 + N)];

impulse = filter(b, 1, delta);
% out = filter(Max_Flat, impulse);

plot((0:max(size(out))-1), out);


Y = fft(impulse);
P2 = abs(Y/L);
P1 = P2(1:L/2 + 1);
P = 20*log10(P1);

f = Fs*(0:(L/2))/L;

% figure;
plot(f, P);
title('Frequency response')
xlabel('Frequency')
ylabel('Amplitude dB')








