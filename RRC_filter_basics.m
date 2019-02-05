%% Initialise the raised-cosine filter

Nsym = 6;           % Filter span
roll_off = 0.35;
sampsPerSymb = 8;

% Order of the filter:
order =  Nsym*sampsPerSymb;
% of in taps:
taps_order = Nsym*sampsPerSymb + 1;


rctFilt = comm.RaisedCosineTransmitFilter(  ...
    'Shape',                'Normal',       ...
    'RolloffFactor',        roll_off,       ...
    'FilterSpanInSymbols',  Nsym,           ...
    'OutputSamplesPerSymbol', sampsPerSymb	...
    )

b = coeffs(rctFilt);
rctFilt.Gain = 1/max(b.Numerator);

fvtool(rctFilt, 'Analysis', 'impulse')

%% Pulse shaping with RC filter

% Generate a bipolar data sequence
% Parameters
DataL = 20;             % Data lenght
R = 1000;               % Data rate
Fs = R * sampsPerSymb;  % Sampling frequency

% Refresh main random stream to create repeatability
hStr = RandStream('mt19937ar', 'Seed', 0);

% Generate random data
x = 2*randi(hStr, [0 1], DataL, 1) - 1;
% Generate time-vector sampled at symbol rate in milliseconds
tx = 1000 * (0:DataL - 1) / R;

% Pass the information through filter
yo = rctFilt([x; zeros(Nsym/2,1)]);
% Time vector sampled at sampling frequency in milliseconds
to = 1000 * (0:(DataL+Nsym/2)*sampsPerSymb - 1) / Fs;

% Plot data
fig1 = figure;
stem(tx, x, 'kx'); hold on;
% Plot filtered data
plot(to, yo, 'b-'); hold off;
% Set axes and labels
axis([0 30 -1.7 1.7]);  xlabel('Time (ms)'); ylabel('Amplitude');
legend('Transmitted Data', 'Upsampled Data', 'Location', 'southeast')


% Compensating group delay
filtDelay = Nsym / (2*R);

% Compensating the delay by removing filter transients
yo = yo(filtDelay*Fs+1:end);
to = 1000 * (0:DataL*sampsPerSymb - 1) / Fs;

% Plot the data
stem(tx, x , 'kx'); hold on;
plot(to, yo, 'b-'); hold off;
axis([0 25 -1.7 1.7]);  xlabel('Time (ms)'); ylabel('Amplitude');
legend('Transmitted Data', 'Upsampled Data', 'Location', 'southeast')



%% Influence of the roll-off factor

roll_off_2 = 0.2;

rctFilt2 = comm.RaisedCosineTransmitFilter(  ...
    'Shape',                'Normal',       ...
    'RolloffFactor',        roll_off_2,     ...
    'FilterSpanInSymbols',  Nsym,           ...
    'OutputSamplesPerSymbol', sampsPerSymb	...
    )

b = coeffs(rctFilt2)
rctFilt2.Gain = 1/max(b.Numerator)

yo1 = rctFilt2([x; zeros(Nsym/2,1)]);
to1 = 1000 * (0:(DataL+Nsym/2)*sampsPerSymb - 1) / Fs;

% Compensating the delay by removing filter transients
yo1 = yo1(filtDelay*Fs+1:end);
to1 = 1000 * (0:DataL*sampsPerSymb - 1) / Fs;

% Plot the data
stem(tx, x , 'kx'); hold on;
plot(to, yo, 'b-', to1, yo1, 'r-'); hold off;
axis([0 25 -1.7 1.7]);  xlabel('Time (ms)'); ylabel('Amplitude');
legend('Transmitted Data', 'beta = 0.5', 'beta = 0.2', 'Location', 'southeast')



%% Square root cosine filters

Nsym_rc = 6;               % Filter span
roll_off_rc = 0.35;        % Roll off factor
sampsPerSymb_rc = 8;       % Decimation factor

% Transmit filter
rrcTxFil = comm.RaisedCosineTransmitFilter(      ...
    'Shape',                   'Square root',    ...
    'RolloffFactor',            roll_off_rc,     ...
    'FilterSpanInSymbols',      Nsym_rc,         ...
    'OutputSamplesPerSymbol',   sampsPerSymb_rc	 ...
    )

yc = rrcTxFil([x; zeros(Nsym_rc/2,1)]);
yc = yc(filtDelay*Fs+1:end);

% Plot data.
stem(tx, x, 'kx'); hold on;
% Plot filtered data.
plot(to, yc, 'm-'); hold off;
% Set axes and labels.
axis([0 25 -1.7 1.7]);  xlabel('Time (ms)'); ylabel('Amplitude');
legend('Transmitted Data', 'Sqrt. Raised Cosine', 'Location', 'southeast')

% Receive filter

rcrFilt = comm.RaisedCosineReceiveFilter(...
  'Shape',                  'Square root', ...
  'RolloffFactor',          roll_off, ...
  'FilterSpanInSymbols',    Nsym, ...
  'InputSamplesPerSymbol',  sampsPerSymb, ...
  'DecimationFactor',       1);
% Filter at the receiver.
yr = rcrFilt([yc; zeros(Nsym*sampsPerSymb/2, 1)]);
% Correct for propagation delay by removing filter transients
yr = yr(filtDelay*Fs+1:end);
% Plot data.
stem(tx, x, 'kx'); hold on;
% Plot filtered data.
plot(to, yr, 'b-',to, yo, 'm:'); hold off;
% Set axes and labels.
axis([0 25 -1.7 1.7]);  xlabel('Time (ms)'); ylabel('Amplitude');
legend('Transmitted Data', 'Rcv Filter Output',...
    'Raised Cosine Filter Output', 'Location', 'southeast')


%% Comparing cost

C1 = cost(rrcTxFil)
C2 = cost(rcrFilt)



