function [u,v] = fftalign(A,B)

% N = min(size(A));

%  size(A)
% yidx = round(size(A,1)/2)-N/2 + 1 : round(size(A,1)/2)+ N/2;
% xidx = round(size(A,2)/2)-N/2 + 1 : round(size(A,2)/2)+ N/2;
% % [yidx(1) yidx(end)]
% A = A(yidx,xidx);
% B = B(yidx,xidx);

% A = A-min(A(:));
% B = B-min(B(:));
% A = A/max(A(:));
% B = B/max(B(:));



C = fftshift(real(ifft2(fft2(A).*fft2(rot90(B,2)))));
C = C - min(C(:));
% maskCenter = zeros(3,3);
% maskCenter(2,:) = 1;
% maskCenter(:,2) = 1;

% maskOuter = ones(5,5);
% maskOuter([2 3 4],[2 3 4]) = ~(maskCenter==1);
C(size(C,1)/2+[-1 0 1],size(C,2)/2+[-1 0 1]) = 0;
% C(size(C,1)/2+[-1 0 1],size(C,2)/2) = 0;
C = C/max(C(:));

bwProps = regionprops(logical(C > 0.6), C, 'PixelIdxList','WeightedCentroid');

for i=1:length(bwProps)
    [~,idx] = max(C(:));
    
    if (sum(bwProps(i).PixelIdxList == idx)>0)
%         2232
        ii = round(bwProps(i).WeightedCentroid(2));
        jj = round(bwProps(i).WeightedCentroid(1));
    end
    
end


subplot(1,3,1)
pcolor((A))
shading flat
daspect([1 1 1])
subplot(1,3,2)
pcolor((B))
shading flat
daspect([1 1 1])

subplot(1,3,3)

% C(C<0.6) = 0;
pcolor(C)
% colorbar
daspect([1 1 1])
shading flat
axis([size(C,2)/2+[-50 50] size(C,1)/2+[-50 50]])
hold on
plot(jj,ii,'r.','markersize',20)
title('FFT Corr')
% title([num2str(ii) ' | ' num2str(jj)]);
hold off


% subplot(1,4,4)
% hist(C(:))
% drawnow

u = size(A,1)/2-ii;
v = size(A,2)/2-jj;
end