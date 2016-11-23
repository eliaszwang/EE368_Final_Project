function [ks, ls] = nearest_n(R, X, Q_size, S)

opt = 0;
[h,w,c] = size(S);
RX = R.*X
min_l2 = Inf;

if opt == 0
    for k=1:(h-Q_size+1)
        for j=1:(w-Q_size+1)
            patch = zeros(h,w);
            patch(k:k+Q_size-1,j:j+Q_size-1) = 1;
            diff = RX - patch(:).*S;
            sqr = diff .* diff;
            if sqr < min_l2
                sqr = min_l2;
                ks = k; ls = l;
            end
        end
    end
else
    
    
end










end