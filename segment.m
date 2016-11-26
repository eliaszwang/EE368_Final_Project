function W = segment(C)

typ = 1;

if typ==1
    sigma = 20;
    BW = edge(C, 'log', 0, sigma);
    W = imgaussfilt(100*BW,30);
end














end