function [ks, ls] = nearest_n(R, X, Q_size, S)

opt = 0;
[h,w,c] = size(S);
RX = R.*X(:);
min_l2 = Inf;

if opt == 0
    for k=1:(h-Q_size+1)
        for j=1:(w-Q_size+1)
            patch = S(k:k+Q_size-1,j:j+Q_size-1);
            diff = RX - patch(:);
            sqr = sum(diff .* diff);
            if sqr < min_l2
                sqr = min_l2;
                ks = k; ls = l;
            end
        end
    end
else
    P = zeros(Q_size*Q_size, (h-Q_size+1)*(w-Q_size+1));
    for k=1:(h-Q_size+1)
        for j=1:(w-Q_size+1)
            patch = S(k:k+Q_size-1,j:j+Q_size-1);
            P(:,(k-1)*(w-Q_size+1)+j) = patch(:);
        end
    end
    
end










end