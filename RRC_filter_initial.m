%% Generating RRC filter

Nsymb = 12;           % Filter span
roll_off = 0.35;     % Roll-off factor
sampsPerSymb = 8;    % Uspample/decimation factor 

rrcTxFil = comm.RaisedCosineReceiveFilter( ...
  'Shape',                  'Square root', ...
  'RolloffFactor',          roll_off,      ...
  'FilterSpanInSymbols',    Nsymb,         ...
  'InputSamplesPerSymbol',  sampsPerSymb,  ...
  'DecimationFactor',       sampsPerSymb   ...
);

taps = Nsymb * sampsPerSymb + 1;

fvtool(rrcTxFil, 'Analysis', 'impulse');

%% Generating filter to attenuate the stopband


FIR = Equirippple_Remez_matlab;
RRC = RRC_matlab;

RRC_Numerator = RRC.Numerator;
FIR_Numerator = FIR.Numerator;



%% Generate new filter
% Doing the convolution of the filters
convolution = conv(RRC_Numerator, FIR_Numerator);

newFil = dsp.FIRFilter('Numerator', convolution);

fvtool(newFil)


%% Testing influence of this filter to the scatter plot

