function [Xtilde]=irls(R,X,z)
    % performs IRLS to estimate Xtilde
    % R is matrix of image patches with dimensions 3N_c by N_ij
    % X is initial estimate, dimensions 3N_c by 1
    % z is matrix of style patches with dimensions n by N_ij
    [tNc,Nij]=size(R);
    I= 10; %max number of IRLS iterations
    Xk=X; %current estimate
    r=0.8;
    unsampled_pixs=double(~(sum(R,2)>0)); %prevent black bar artifacts from gap
    for k=1:I
        %Xrep=repmat(Xk,1,Nij);
        %w= sum((reshape(Xrep(logical(R)),size(z)) - z).^2,1).^((r-2)/2);
        A=unsampled_pixs;%zeros(tNc,1); %prevent black bar artifacts from gap
        B=Xk.*unsampled_pixs;%zeros(tNc,1);
        for i=1:Nij
            w=sum((Xk(logical(R(:,i)))-z(:,i)).^2 + 1e-10).^((r-2)/2);
            A=A+w*R(:,i); % diag(R)=Rvec2mat(R)'*Rvec2mat(R)
            temp=R(:,i);
            temp(logical(temp))=z(:,i);
            B=B+w*temp;
            %A=A+w(i)*diag(R(:,i));
            %B=B+w(i)*Rvec2mat(R(:,i))'*z(:,i);
        end
        Xk=(1./(A+1e-10)).*B;
    end
    Xtilde=Xk;
end
