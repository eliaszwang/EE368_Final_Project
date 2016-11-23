function [Rmat]=Rvec2mat(Rvec)
    % Rvec is Rn_ij as 3N_c by 1 vector 
    % Rmat is matrix with dimensions n by 3N_c
    N=length(Rvec);
    n=sum(Rvec);
    Rmat=zeros(n,N);
    curRow=Rvec';
    for i=1:n
        ind=find(curRow==1,1);
        Rmat(i,ind)=1;
        curRow(ind)=0;
    end
end