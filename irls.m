function [Xhat]=irls(R,X,z )
    % performs IRLS to estimate Xtilde
    % R is matrix of image patches with dimensions 3N_c by N_ij
    % X is initial estimate 
    % z is matrix of style patches with dimensions n by N_ij
    [n,Nij]=size(z);
    I= 10; %max number of IRLS iterations
    Xk=X; %current estimate
    r=0.8;
    for k=1:I
        Xrep=repmat(Xk,1,Nij);
        w= sum((Xrep(R) - z).^2,1).^((r-2)/2);
        A=[];
        B=[];
        for i=1:Nij
            A=A+w(i)*diag(R(:,i)); % diag(R)=Rvec2mat(R)'*Rvec2mat(R)
            B=B+w(i)*Rvec2mat(R(:,i))'*z(:,i);
        end
        Xk=A\B;
    end
    Xhat=Xk;
end
