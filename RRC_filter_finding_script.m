% ##################### Generating basic filters ######################### 

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
N     = 116;       % Order              144
Fpass = 15;        % Passband Frequency 11
Fstop = 21;        % Stopband Frequency 13.5
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

% ##################### Synthesising filters #############################
%%
% Loop "for" by Nsymb in RRC, which sets the order of filter
for Nsymb = 11:11
    
    N = Nsymb * 8;
    % RRC
    Fc   = 9;          % Cutoff Frequency
    TM   = 'Rolloff';  % Transition Mode
    R    = 0.35;       % Rolloff
    DT   = 'sqrt';     % Design Type
    Beta = 0.5;        % Window Parameter
    
    % FIR
    Fpass = 15;        % Passband Frequency 11
    Fstop = 21;        % Stopband Frequency 13.5
    Wpass = 0.1;       % Passband Weight
    Wstop = 80;        % Stopband Weight
    dens  = 16;        % Density Factor

    
    
    
    % Recalculate the filters
    FIR = Equirippple_Remez_matlab(Fs, N, Fpass, Fstop, Wpass, Wstop, dens);
    RRC = RRC_matlab(Fs, N, Fc, TM, R, DT, Beta);
    FIR_Numerator = FIR.Numerator;
    RRC_Numerator = RRC.Numerator;

    convolution = conv(RRC_Numerator, FIR_Numerator);
    NEW = dsp.FIRFilter('Numerator', convolution);
    fvtool(NEW);
    
    
    % Comparing
    C3 = cost(NEW);
    NEW_delay = grpdelay(NEW, 1, Fs);
    delay_diff = NEW_delay - (Initial_delay)
    
    
    result = input('Continue? ', 's');
    if result == 'no'
        break
    end
    
end % Loop end

%%
numerator = [zeros(1,72) 1 zeros(1,72)]
