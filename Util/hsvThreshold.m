function bw = hsvThreshold(frame,hsvLevels)
%HSVTHRESHOLD Summary of this function goes here
%   Detailed explanation goes here
    frame = rgb2hsv(frame);
    h = frame(:,:,1);
    s = frame(:,:,2);
    v = frame(:,:,3);
    hMask = h >= hsvLevels(1) & h <= hsvLevels(2);
    if (hsvLevels(1)<0)
        hMask = hMask | h >= (1+hsvLevels(1));
    end
    if (hsvLevels(2)>1)
        hMask = hMask | h <= (hsvLevels(2)-1);
    end
    sMask = s >= hsvLevels(3) & s <= hsvLevels(4);
    vMask = v >= hsvLevels(5) & v <= hsvLevels(6);
    
    bw = hMask & sMask & vMask;
end

