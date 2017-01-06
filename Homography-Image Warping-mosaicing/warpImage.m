function [Iwarp, Imerge] = warpImage(Iin, Iref, H)
%% %%%%%%%%%%%%%%%%warp and mosaic------------------------------
I = Iin;
J = Iref;
row= size(I,1);
col = size(I,2);
warpOutput1 = uint8([]);
cornerCoordinates= [1 1 1;
                    1 row 1
                    col row 1
                    col 1 1]';
%% calc the bounds of new image size - forward mapping
newBounds = H*cornerCoordinates;
newBounds(1,:) = newBounds(1,:)./newBounds(3,:);
newBounds(2,:) = newBounds(2,:)./newBounds(3,:);


Xmin = ceil(min(newBounds(1,:)));
Xmax = ceil(max(newBounds(1,:)));
Ymin = ceil(min(newBounds(2,:)));
Ymax = ceil(max(newBounds(2,:)));

%% fill the warped image pixels with the image1 pixels - inverse mapping
[U,V] = meshgrid(Xmin:Xmax,Ymin:Ymax);
newrows  = size(U,1);
newcols = size(U,2);
Hinv = inv(H);
u = U(:);
v = V(:);
temp = [u';v';ones(1,size(u,1))];
M = Hinv*temp;
M(1,:) = M(1,:)./M(3,:);
M(2,:) = M(2,:)./M(3,:);
U(:)=M(1,:)';
V(:)=M(2,:)';
for i=1:3
    warpOutput1(newrows, newcols,i) = 1;
end
for i=1:3
    warpOutput1(:,:,i) = interp2(single(I(:,:,i)),U,V,'linear');
end

%imshow(warpOutput1)
Iwarp = warpOutput1;
%% mosaicing
%warp the image2 to similar image dimensions as of warped image1
temp = [u';v';ones(1,size(u,1))];
M = eye(3)*temp;
M(1,:) = M(1,:)./M(3,:);
M(2,:) = M(2,:)./M(3,:);
U(:)=M(1,:)';
V(:)=M(2,:)';
warpOutput2 = uint8([]);
for i =1:3
    warpOutput2(newrows, newcols,i) = 1;
end
for i =1:3
    warpOutput2(:,:,i) = interp2(single(J(:,:,i)),U,V,'linear');
end
%imshow(warpOutput2)

% using max also gives a reasonably accurate mosaic
%alternateMosaic=max(warpOutput1,warpOutput2);

%% using image intersection operation also gives the mosaic
for i =1:3
    for j=1:size(warpOutput2,1)
        for k = 1:size(warpOutput2,2)
            if(warpOutput1(j,k,i)>0)
                warpOutput2(j,k,i)=warpOutput1(j,k,i);
            end
        end
    end
end
Imerge = warpOutput2;
end