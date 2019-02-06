function res = func_G(f, a, T)
% f - input freq
% a - roll-off factor
% T - symbol duration
    F = abs(f);
    if (F <= (1-a)/2*T)
       res = 1;
    elseif (F >= (1+a)/2*T) 
        res = 0;
    else
        res = sqrt(0.5*(1-sin(pi*(2*F*T - 1)/(2*a))));
    end

end