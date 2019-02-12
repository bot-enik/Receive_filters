%%
% ################## Генерация сверточного фильтра ###################### 
% 
% Данный файл генерирует сверточный фильтр на той основе,
% которую задают перед циклом
% (брать желательно из searching_ideal_FIR.m)

% Генерируем параметры для начальных фильтров
% (это необходимо для сравнения)

% RRC
% All frequency values are in kHz.
Fs = 144;          % Sampling Frequency
N    = 64;         % Order
Fc   = 9;          % Cutoff Frequency
TM   = 'Rolloff';  % Transition Mode
R    = 0.35;       % Rolloff
DT   = 'sqrt';     % Design Type
Beta = 0.5;        % Window Parameter

Initial_RRC = RRC_matlab(Fs, N, Fc, TM, R, DT, Beta);
Initial_RRC_Numerator = Initial_RRC.Numerator;

% FIR
% All frequency values are in kHz.
Fs    = 144;       % Sampling Frequency
N     = 144;       % Order              144
Fpass = 11;        % Passband Frequency 11
Fstop = 13.5;      % Stopband Frequency 13.5
Wpass = 0.1;       % Passband Weight
Wstop = 80;        % Stopband Weight
dens  = 16;        % Density Factor

Initial_FIR = Equirippple_Remez_matlab(Fs, N, Fpass, Fstop, Wpass, Wstop, dens);
Initial_FIR_Numerator = Initial_FIR.Numerator;

C01 = cost(Initial_FIR)
C02 = cost(Initial_RRC)

Initial_RRC_delay = grpdelay(Initial_RRC, 1, Fs);
Initial_FIR_delay = grpdelay(Initial_FIR, 1, Fs);
Initial_delay = Initial_FIR_delay + Initial_RRC_delay


%%
% ##################### Synthesising filters #############################
% 
% Синтез сверточного фильтра на основе того, который зададим далее:

% Зададим параметры для FIR фильтра 
% (брать желательно из searching_ideal_FIR.m)

    % FIR
    Fpass = 15;        % Passband Frequency 11
    Fstop = 21;        % Stopband Frequency 13.5
    Wpass = 0.1;       % Passband Weight
    Wstop = 80;        % Stopband Weight
    dens  = 16;        % Density Factor

    % RRC
    Fc   = 9;          % Cutoff Frequency
    TM   = 'Rolloff';  % Transition Mode
    R    = 0.35;       % Rolloff
    DT   = 'sqrt';     % Design Type
    Beta = 0.5;        % Window Parameter
    

delay_diff  = [];
numerator   = [];
order       = [];

% Loop "for" by Nsymb in RRC, which sets the order of filter
for Nsymb = 10:14
    
    N = Nsymb * 8;

    % Recalculate the filters
    FIR = Equirippple_Remez_matlab(Fs, N, Fpass, Fstop, Wpass, Wstop, dens);
    RRC = RRC_matlab(Fs, N, Fc, TM, R, DT, Beta);
    FIR_Numerator = FIR.Numerator;
    RRC_Numerator = RRC.Numerator;

    convolution = conv(RRC_Numerator, FIR_Numerator);
    NEW = dsp.FIRFilter('Numerator', convolution);
%     fvtool(NEW);
    
    % Comparing
    NEW_delay = grpdelay(NEW, 1, Fs);
    delay_diff = [delay_diff NEW_delay - (Initial_delay)];
    
    close_to_zero = abs(convolution(n/2 + 9));
    numerator = [numerator close_to_zero];
    order = [order N];
    
%     result = input('Continue? ', 's');
%     if result == 'no'
%         break
%     end
    
end 

%%
% Результаты (для данных 15 21 0.1 80 16): 
% order =      80        88        96        104       112
% numerator =  0.0070    0.0031    0.0003    0.0009    0.0008
% delay_diff = -24.0000  -16.0000  -8.0000   0         8.0000

FIR = Equirippple_Remez_matlab(Fs, 88, Fpass, Fstop, Wpass, Wstop, dens);
    RRC = RRC_matlab(Fs, 88, Fc, TM, R, DT, Beta);
    FIR_Numerator = FIR.Numerator;
    RRC_Numerator = RRC.Numerator;

    convolution = conv(RRC_Numerator, FIR_Numerator);
    b = max(convolution);
    convolution = convolution ./ b;
    NEW = dsp.FIRFilter('Numerator', convolution);
    fvtool(NEW);
    
    C3 = cost(NEW);


%%
numerator = [zeros(1,72) 1 zeros(1,72)]
