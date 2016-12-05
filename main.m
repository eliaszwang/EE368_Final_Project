clear all
close all

tic;
addpath('DomainTransformFilters-Source-v1.0/');

% import images
% house=im2double(imread('images/house - small.jpg'));
% house=im2double(imread('images/house 2-small.jpg'));
% house=im2double(imread('images/selfie.jpg'));
house=im2double(imread('images/eagles.jpg'));
% house=im2double(imread('images/lena.jpg'));
imsize=400;
house=house(1:imsize,1:imsize,:);
% night=im2double(imread('images/starry-night - small.jpg'));
% night=im2double(imread('images/night2.jpg'));
% night=im2double(imread('images/femme2.jpg'));
%night=im2double(imread('images/man.jpg'));
% night=im2double(imread('images/picasso2.jpg'));
% night=im2double(imread('images/lamuse.jpeg'));
night=im2double(imread('images/derschrei.jpg'));
night=night(1:imsize,1:imsize,:);
% house=ones(size(house)); %remove comment if want to generate hallucination, remember to change mask(W) too
% hall=im2double(imread('images/hall_night.jpg'));
hall=im2double(imread('images/hall_night2.jpg'));
% hall=im2double(imread('images/hall_pic.jpg'));
% hall=im2double(imread('images/hall_schrei.jpg'));
return
% Initialize variables
C0 = house(:);
mask0 = segment(rgb2gray(house), 1);
S0 = night(:);
sigma_s = 5;
sigma_r = 0.2;
h0=imsize; w0=imsize; c=3;
C0=imhistmatch(reshape(C0,h0,w0,c),reshape(S0,h0,w0,c)); %initailize C to color palette of S
C0=C0(:);
patch_sizes=[36 22 13 10];
gap_sizes=[28 18  9 6];
scales=[4 2 1];
Lmax = max(scales);
% X0=bg_hall(reshape(C0,h0,w0,c),ones(h0,w0,c)); %initialize estimate to content image
% X0=bg_hall(reshape(C0,h0,w0,c),hall); %initialize estimate to content image
X=C0;
X=X+max(X)*randn(size(X)); %add large noise at beginning

X=X(:);


%             % 0. Transfer style with SURF
%             disp('SURF transfer')
%             X = surf_transfer(reshape(X, [h0 w0 c]), reshape(S0, [h0 w0 c]));
%             X = X(:);

% Loop over scales L=Lmax, ... ,1
for L=scales
    % Scale everything
    C_scaled = imresize(reshape(C0, [h0 w0 c]), 1/L);
    S_scaled = imresize(reshape(S0, [h0 w0 c]), 1/L);
    mask = imresize(mask0, 1/L);
    C = C_scaled(:); S = S_scaled(:);
    h = ceil(h0/L); w = ceil(w0/L);
    X=imresize(reshape(X, [h0 w0 c]),1/L);
    halls=imresize(hall,1/L);
    
    X=X(:);
    
    % Add noise to initialization image
    %X=X+0.2*randn(size(X));
%     X=imhistmatch(reshape(X,h,w,c),reshape(S,h,w,c));
%     X=X(:);

    % Loop over patch sizes n=n1, ... ,nm
    for n=patch_sizes(1:3)
        if L>1 && n==13
            continue
        end
        Q_size=n;
        % precompute P
        Pstride=4;
        S = reshape(S, [h w c]);
        P = zeros(c*Q_size*Q_size, (floor( ((h-Q_size+1)-1)/Pstride ) + 1 )*(floor( ((w-Q_size+1)-1)/Pstride ) + 1)*4 );
        for k=1:Pstride:(h-Q_size+1)
            for j=1:Pstride:(w-Q_size+1)
                patch = S(k:k+Q_size-1,j:j+Q_size-1,:);
                for l=0:3
                    temp=imrotate(patch,l*90,'bilinear');
                    P(:,(ceil(k/Pstride)-1)*(floor( ((w-Q_size+1)-1)/Pstride )+ 1)*4 + (ceil(j/Pstride)-1)*4 + l + 1 ) = temp(:);
                end
            end
        end
        S=S(:);
        %remove mean from P
        mp=mean(P,2);
        P=P-repmat(mp,1,size(P,2));
        
        % compute PCA of P
        [V, D] = eig(P*P');
        [D,I] = sort(diag(D),'descend');
        V = V(:, I);
        
        % find top eig vals
        eig_idx = 1; %size(D,1)
        energy = 0; energy_tot = sum(D);
        for i=1:size(D,1)
            energy = energy + D(i);
            if energy >= 0.95*energy_tot
                eig_idx = i;
                break;
            end
        end
        
        % reduce dimensionality
        Vp = V(:,1:eig_idx);
        Pp = Vp' * P;
        
        
        % Iterate: for k=1, ... ,Ialg
        for k=1:3
            
            X = 0.25*halls(:)+0.75*X;
            
            % 1. Patch Matching
            disp('patch matching')
            gap=gap_sizes(patch_sizes==n); %should correspond to current n
            Rall=zeros(h*w*c, (floor( ((h-Q_size+1)-1)/gap ) + 1 )*(floor( ((w-Q_size+1)-1)/gap ) + 1) );
            z=zeros(c*n^2, (floor( ((h-Q_size+1)-1)/gap ) + 1 )*(floor( ((w-Q_size+1)-1)/gap ) + 1) );
            for i=1:gap:h-Q_size+1
                for j=1:gap:w-Q_size+1
                    R = zeros(h,w,c);
                    R(i:i+Q_size-1,j:j+Q_size-1,:) = 1;
                    R = R(:);
                    Rall(:,(ceil(i/gap)-1)*(floor( ((w-Q_size+1)-1)/gap )+ 1) + ceil(j/gap))=R;
                    [ks, ls, zij,ang] = nearest_n(R, X, Q_size, S, h, w, c, Pp,Vp,Pstride,mp,L, gap);
                    temp=imrotate(reshape(zij,n,n,c),ang*90,'bilinear');
                    z(:,(ceil(i/gap)-1)*(floor( ((w-Q_size+1)-1)/gap )+ 1) + ceil(j/gap))=temp(:);
                end
            end
            
            % 2. Robust Aggregation
            disp('robust aggregation')
            [Xtilde]=irls(Rall,X,z);
            
            
            % 3. Content Fusion
            disp('content fusion')
            W = repmat(1.5*mask(:)/max(mask(:)),c,1);
            %Nc=(ceil(imsize/L))^2;
%             W=1.5*zeros(size(W));
            Xhat=(1./(W+ones(size(W)))).*(Xtilde+W.*C); % W is (3*Nc/L x 1)
            
            
            % 4. Color Transfer
            disp('color transfer')
            X=imhistmatch(reshape(Xhat,h,w,c),reshape(S,h,w,c));

            
            % 5. Denoise
            disp('denoise')
            X = RF(X, sigma_s, sigma_r);
            X=X(:);
            
        end % end Iterate: for k=1, ... ,Ialg
        
    end % end patch size loop
    % Scale up
    if L>1
        X=imresize(reshape(X, [h w c]),L);
        X = X(:);
    end
end % end resolution/scale loop  

% Result
X=reshape(X,imsize,imsize,3);

toc;
sound(sin(6.28*1000*[1:0.1:500]));





