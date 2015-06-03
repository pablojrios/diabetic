% P_a is a real, I_a is a complex number
function P_a = extractInvariant(B, w, a)
    % validar parametros
    if (a <= 0 || a > 1)
        error('a=%f is not gt 0 and le 1', a)
    end
    
    % buscar indice de fila y columna con freq 0 en matriz biespectro
    freq0 = find(w == 0);
    freq1 = 1;
    freqN = floor((length(w)/2 - 1)/(1+a));
%     fprintf('Calculating invariant %f in interval [%d, %d] whose frequencies are [%f, %f] ...\n', a, freq0+freq1, freq0+freqN, w(freq0+freq1), w(freq0+freqN)); 
    I_a = 0+0i;
    for k1 = freq1:freqN
        p = a*k1 - floor(a*k1);
        interpolated = p*B(freq0+k1, freq0+ceil(a*k1)) + (1-p)*B(freq0+k1, freq0+floor(a*k1));
%         fprintf('Interpolation: (%d, %d) (%d, %d), %f\n', freq0+k1, freq0+ceil(a*k1), freq0+k1, freq0+floor(a*k1),...
%             angle(interpolated));
        I_a = I_a + interpolated;
    end
    
    % M = abs(Inv_a)    %magnitude
    %%% Dos formas de calcular la fase (ie.: Ph = Ph2)
    P_a = angle(I_a); %phase angle
    P_a2 = atan2(imag(I_a), real(I_a)); %#ok<NASGU> %phase angle
end
