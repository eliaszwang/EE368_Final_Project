function [ks, ls, z] = nearest_n(R, X, Q_size, S, h, w, c, Pp,Vp)
%Q_size=uint8(sqrt(sum(R(:)/3)))
opt = 1;
% [h,w,c] = size(S);
S = reshape(S, [h w c]);
RX = X(logical(R));
min_l2 = Inf;


if opt == 0
    P=Pp;
%     for k=1:(h-Q_size+1)
%         for j=1:(w-Q_size+1)
%             patch = S(k:k+Q_size-1,j:j+Q_size-1,:);
%             diff = RX - patch(:);
%             sqr = sum(diff .* diff);
%             if sqr < min_l2
%                 min_l2 = sqr;
%                 ks = k; ls = j;
%             end
%         end
%     end

    temp=repmat(RX,1,size(P,2));
  tic; sqr=sum((temp-P).^2,1);toc;
    [~,idx]=min(sqr);
    [ls,ks]=ind2sub([(w-Q_size+1) (h-Q_size+1)],idx); %flipped since ind goes across rows, then down columns 
elseif opt == 1

   
    RXp = Vp' * RX;
    dif = repmat(RXp, [1 size(Pp,2)]) - Pp;
    sqr = sum(dif.^2, 1);
    [~, idx] = min(sqr);
%     ls = mod(idx-1, (w-Q_size+1)) + 1;
%     ks = floor((idx-1)/(w-Q_size+1)) + 1;
    [ls,ks]=ind2sub([(w-Q_size+1) (h-Q_size+1)],idx); %flipped since ind goes across rows, then down columns 
elseif opt == 2
    htm=vision.TemplateMatcher('Metric','Sum of squared differences');
    Loc=step(htm,rgb2gray(S),rgb2gray(reshape(RX,[Q_size Q_size 3])));
    ks = floor(Loc(2)-Q_size/2); ls = floor(Loc(1)-Q_size/2);
end


z = S(ks:ks+Q_size-1,ls:ls+Q_size-1,:); %maybe compute outside so no need to pass S
z = z(:);






end