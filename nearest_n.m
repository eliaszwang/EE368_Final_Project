function [ks, ls, z] = nearest_n(R, X, Q_size, S, h, w, c)
%Q_size=uint8(sqrt(sum(R(:)/3)))
opt = 0;
% [h,w,c] = size(S);
S = reshape(S, [h w c]);
RX = X(logical(R));
min_l2 = Inf;


if opt == 0
    for k=1:(h-Q_size+1)
        for j=1:(w-Q_size+1)
            patch = S(k:k+Q_size-1,j:j+Q_size-1,:);
            diff = RX - patch(:);
            sqr = sum(diff .* diff);
            if sqr < min_l2
                min_l2 = sqr;
                ks = k; ls = j;
            end
        end
    end
else
    % compute patch matrix
    P = zeros(c*Q_size*Q_size, (h-Q_size+1)*(w-Q_size+1));
    for k=1:(h-Q_size+1)
        for j=1:(w-Q_size+1)
            patch = S(k:k+Q_size-1,j:j+Q_size-1,:);
            P(:,(k-1)*(w-Q_size+1)+j) = patch(:);
        end
    end
    P = P - repmat(mean(P,2),[1 size(P,2)]);
    [V, D] = eig(P*P');
    
    % find eig vals
    eig_idx = 1;
    energy = 0; energy_tot = sum(D(:));
    for i=1:size(D,1)
        energy = energy + D(i,i);
        if energy > 0.95*energy_tot
            eig_idx = i;
            break;
        end
    end
    
    % reduce dimensionality
    Vp = V(:,1:eig_idx);
    Pp = Vp' * P;
    RXp = Vp' * RX;
    diff = repmat(RXp, [1 size(Pp,2)]) - Pp;
    sqr = sum(diff .* diff, 1);
    [~, idx] = min(sqr);
    ks = mod(idx, (w-Q_size+1)) + 1;
    ls = floor(idx/(w-Q_size+1)) + 1;
end


z = S(ks:ks+Q_size-1,ls:ls+Q_size-1,:);
z = z(:);






end