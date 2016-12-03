function W = segment(C, scale)

typ = 1;

if typ==1
    sigma_edge = scale*1; sigma_blur = scale*20;
    E = edge(C, 'log', 0.03, sigma_edge);
    B = imgaussfilt(0.5*E, sigma_blur);
    mask = B > mean2(B);
    BW = activecontour(C,mask);
    W = imgaussfilt(double(BW.*(1+2*E)),sigma_blur);
elseif typ==2
    sigma_edge = scale*0.8; sigma_blur = scale*20;
    BW = edge(C, 'log', 0.03, sigma_edge);
    imagesc(imclose(BW, ones(5)))
%     W = imgaussfilt(0.5*BW, sigma_blur);
elseif typ==3
    sigma_blur = scale*20;
    BW = edge(C, 'roberts', 0.05);
    %imagesc(BW)
    W = imgaussfilt(0.5*BW, sigma_blur);
end




end