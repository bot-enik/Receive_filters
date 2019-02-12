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

fvtool(Initial_RRC)

%%

DBL = measure(Initial_RRC, 'Arithmetic', 'double')

%%
Fpass = 9e3
Fstop = 1
spec_RRC = fdesign.lowpass();
H_RRC = design(spec_RRC, '')

%%
% help fdesign/responses

%%























