%% Generating basic filters 

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
Fs    = 144;   % Sampling Frequency
N     = 144;   % Order
Fpass = 11;    % Passband Frequency
Fstop = 13.5;  % Stopband Frequency
Wpass = 1;     % Passband Weight
Wstop = 60;    % Stopband Weight
dens  = 16;    % Density Factor

Initial_FIR = Equirippple_Remez_matlab(Fs, N, Fpass, Fstop, Wpass, Wstop, dens);
Initial_FIR_Numerator = Initial_FIR.Numerator;


%% Generating filter to attenuate the stopband

% All frequency values are in kHz.
Fs = 144;      % Sampling Frequency
N     = 96;    % Order
Fpass = 11;    % Passband Frequency
Fstop = 13.5;  % Stopband Frequency
Wpass = 1;     % Passband Weight
Wstop = 60;    % Stopband Weight
dens  = 16;    % Density Factor

FIR = Equirippple_Remez_matlab(Fs, N, Fpass, Fstop, Wpass, Wstop, dens);
FIR_Numerator = FIR.Numerator;


%% Generating raised cosine filter

% All frequency values are in kHz.
Fs = 144;          % Sampling Frequency
N    = 96;         % Order
Fc   = 9;          % Cutoff Frequency
TM   = 'Rolloff';  % Transition Mode
R    = 0.35;       % Rolloff
DT   = 'sqrt';     % Design Type
Beta = 0.5;        % Window Parameter

RRC = RRC_matlab(Fs, N, Fc, TM, R, DT, Beta);
RRC_Numerator = RRC.Numerator;


%% Generating new filter

% Doing the convolution of the filters
convolution = conv(RRC_Numerator, FIR_Numerator);

NEW = dsp.FIRFilter('Numerator', convolution);

fvtool(NEW);

%% Comparing cost

C01 = cost(Initial_FIR);
C02 = cost(Initial_RRC);


C1 = cost(FIR);
C2 = cost(RRC);
C3 = cost(NEW);

%% Comparing delay

Initial_RRC_delay = grpdelay(Initial_RRC, 1, Fs);
Initial_FIR_delay = grpdelay(Initial_FIR, 1, Fs);
Initial_delay = Initial_FIR_delay + Initial_RRC_delay;

RRC_delay = grpdelay(RRC, 1, Fs);
FIR_delay = grpdelay(FIR, 1, Fs);
NEW_delay = grpdelay(NEW, 1, Fs);

delay_diff = NEW_delay - (RRC_delay + FIR_delay);

%%  Testing influence of this filter to the scatter plot



