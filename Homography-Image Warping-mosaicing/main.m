I = imread('hw3data\sbu1.jpg');
J = imread('hw3data\sbu2.jpg');

%cpselect(I,J);
%points1 = movingPoints';
%points2 = fixedPoints';

%%%% RANSAC %%%%%%% %%extra-credit%%
p = load('points.mat');
nPoints = size(p.points1,2);
inlierCount = -1;
Hfinal = eye(3);
cutoff = 5; %threshold for distance measure for inliers
for i=1:100
    count = 0;
    r4 = randperm(nPoints,4);
    t1 = [p.points1(:,r4(1)) p.points1(:,r4(2)) p.points1(:,r4(3)) p.points1(:,r4(4))];
    t2 = [p.points2(:,r4(1)) p.points2(:,r4(2)) p.points2(:,r4(3)) p.points2(:,r4(4))];
    H = computeH(t1,t2);
    for j=1:nPoints
        p1 = H*[p.points1(:,j);1];
        p1 = p1./p1(3);
        pp = abs(p1 - [p.points2(:,j);1]);
        sd = sum(pp); %manhattan distance
        if(sd<cutoff)
            count = count+1;
        end
    end
        if(count>inlierCount)
            inlierCount = count;
            Hfinal = H;
        end    
end
H = Hfinal;
%%% RANSAC %%%%%
[Iwarp,Imerge]= warpImage(I,J,H);
figure(1),imshow(Iwarp);
figure(2),imshow(Imerge);
imwrite(Iwarp,'sbu1_warped.jpg');
imwrite(Imerge,'sbu_merged.jpg');