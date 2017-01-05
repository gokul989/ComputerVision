h = fspecial('gaussian',11,1);
I = im2double(imread('im8.png'));

laplacian = [0 1 0; 1 -4 1; 0 1 0];
laplacian1 = laplacian.*10;
%output = conv2(h,laplacian);

output2 = conv2(h,laplacian1);

A = conv2(I,output2,'same');
figure,imshow(A);

threshold = 0.68;
[m,n] = size(A);
final = zeros(m,n);
for i=1:m-1
    for j=1:n-1
        if((A(i,j)*A(i+1,j)<0 && abs(A(i,j)-A(i+1,j))>threshold) || (A(i,j)*A(i,j+1)<0 && abs(A(i,j)-A(i,j+1))>threshold))
            final(i,j) = 1;
        else
            final(i,j) = 0;
        end
    end
end

final = imregionalmax(final);
%figure,imshow(final);

[xi,yi] = find(final);
%rr = round(sqrt(m^2 + n^2));
rr = 80;
B = zeros(m,n,rr);

for count = 1:length(xi)
    for xa = 1:m
        for ya = 1:n
            r = sqrt(  (xi(count) - xa)^2 + (yi(count)- ya)^2  );
            r = round(r); 
            if(r>=1 && r<=rr)
            B(xa,ya,r) = B(xa,ya,r) + 1;
            end
        end
    end
end

%figure,imshow(B(:,:,50),[]);
z = max(max(max(B)));  

maxcircles = 30;
P =zeros(maxcircles,2);
R =zeros(maxcircles,1);

for i = 1 : maxcircles
    [maxValue,maxIndex] = max(B(:));    
    [p,q,r] = ind2sub(size(B), maxIndex);
    radius = r;
    cx = q;
    cy = p;
    P(i,:) = [cx cy];
    R(i,:) = [radius];
    B(p,q,r) = 0;    
end
 [F,G] = sort(R,'descend');
 P1 =[];
 R1 =[];
 g = F(1);
 P1(1,:) = P(G(1),:);
 R1(1,:) = F(1);
 t = 2;
 thresholdN = 7;
 for i = 2 : maxcircles
 if(F(i)< g-thresholdN)    
 P1(t,:) = P(G(i),:);
 R1(t,:) = F(i);
 g = F(i);
 t = t+1;
 end
 end

center = round(sum(P,1)./size(P,1))
radius = R1
    figure;imshow(I);
    hold on;
plot(center(1),center(2),'r+','MarkerSize',1)
    viscircles(P1,R1,'Color','r');
   
   
