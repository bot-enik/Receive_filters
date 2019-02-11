%%
% FIR
% All frequency values are in kHz.
Fs    = 144;       % Sampling Frequency
N     = 144;       % Order
Fpass = 11;        % Passband Frequency
Fstop = 13.5;      % Stopband Frequency
Wpass = 0.1;       % Passband Weight
Wstop = 80;        % Stopband Weight
dens  = 16;        % Density Factor

good_res = zeros(3,100);

for n=108:8:144
   for f_pass = 10:0.25:15
      for f_stop = f_pass + (3:0.25:6)
          
          FIR = Equirippple_Remez_matlab(Fs, n, f_pass, f_stop, Wpass, Wstop, dens);
          numerator = FIR.Numerator;
          
          if abs(numerator(n/2 + 9)) < 0.01
           
%             good_res = [good_res  [n; f_pass; fstop]];
            res = n
            res = f_pass
            res = f_stop
            res = abs(numerator(n/2 + 9))
            fvtool(FIR, 'analysis', 'impulse');
            
            result = input('Continue? ', 's');
            if result == 'no'
                break
                break
                break
            end
          end
  
      end
   end
end