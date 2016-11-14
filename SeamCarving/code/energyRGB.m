function res = energyRGB(I)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sum up the enery for each channel 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    res = zeros(size(I));
    [Rgx, Rgy] = gradient(I(:,:,1));
    [Ggx, Ggy] = gradient(I(:,:,2));
    [Bgx, Bgy] = gradient(I(:,:,3));
    res(:,:,1) = abs(Rgx)+abs(Rgy);
    res(:,:,2) = abs(Ggx)+abs(Ggy);
    res(:,:,3) = abs(Bgx)+abs(Bgy);
    res = sum(res,3);
end

function res = energyGrey(I)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% returns energy of all pixelels
% e = |dI/dx| + |dI/dy|
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [gx, gy] = gradient(I);
    gx = abs(gx);
    gy = abs(gy);
    res = gx + gy;
end

