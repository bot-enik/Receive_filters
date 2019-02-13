%% #################### Generate filters for new specification ###########
% 

% ������ ���������� RRC �������:
% ups_factor = 8;
% roll_off = 0.35;
% 
% Fs_init = 18e3;
% Ts_init = 1/Fs_init;
% 
% F1 = (1-roll_off) / (2*Ts_init)
% F  = (1) / (2*Ts_init)
% F2 = (1+roll_off) / (2*Ts_init)


% ����������: 
% 1. ���������� �� 25��� (0.34 ���/���)  �� ����� 60��
% 2. ���������� �� 50��� (0.69 ���/���)  �� ����� 83��
% 3. ���������� �� 72��� (1 ���/���)     �� ����� 100��
% 4. ������� ������ ��� � ������ ����������� RRC �������:
%    �� 12.150��� (0.17 ���/���)

%% ��������� ������� ������������ ��������

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

%% ��������� ����������� �������� ������� 

Nf = 64;           % Order
Fcnorm = 0.24;     % Cutoff normalized frequency 

Max_Flat = Max_Flat_matlab(N, Fcnorm);
fvtool(Max_Flat);

%% ������������ ��� ��������� ��������

% ���������� �������� ������ (������-�������)
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








