% The model should be in the same folder with the code
% BBT dataset, imagenet-vgg network,test.mat,train.mat are assumed to be in
% same directory

%values for patching each image
A = [1 1;33 1;16 115;1 231;16 231];

net = load('imagenet-vgg-verydeep-16.mat') ;
net = vl_simplenn_tidy(net) ;

imagefiles = dir('*.jpg');
nfiles = length(imagefiles);   % Number of files found

% extract feature vectors for training imageset
feature_vectors_train = zeros(1,1,4096,1777);
for ii=1:1777
     currentfilename = imagefiles(ii).name;
   currentimage = imread(currentfilename);
   currentimage = single(currentimage);
currentimage = imresize(currentimage,0.727272);
repr = zeros(1,1,4096);
    for jj =1 : 10
        if(jj <=5)
            b = A(jj,1);
            c = A(jj,2);
        else
            b = A(jj-5,1);
            c = A(jj-5,2);
        end
        X = currentimage(b:224+b-1,c:224+c-1,:);
        
        res = vl_simplenn(net,X) ;
        repr = repr + res(36).x;
        if(jj == 5)
            currentimage = flip(currentimage,2);
        end
    end
    repr = repr./ 10;
    feature_vectors_train(:,:,:,ii) = repr;
end

size(feature_vectors_train)
save('FT_Train.mat','feature_vectors_train');

% extract feature vectors for test imageset
testL = load('test.mat');
feature_vectors_test = zeros(1,1,4096,1600);
for ii=1:1600
      iid = testL.imIds(ii);
     currentfilename = imagefiles(iid).name;
   currentimage = imread(currentfilename);
   currentimage = single(currentimage);
currentimage = imresize(currentimage,0.727272);
repr = zeros(1,1,4096);
    for jj =1 : 10
        if(jj <=5)
            b = A(jj,1);
            c = A(jj,2);
        else
            b = A(jj-5,1);
            c = A(jj-5,2);
        end
        X = currentimage(b:224+b-1,c:224+c-1,:);
       
        res = vl_simplenn(net,X) ;
        repr = repr + res(36).x;
        if(jj == 5)
            currentimage = flip(currentimage,2);
        end
    end
    repr = repr./ 10;
    feature_vectors_test(:,:,:,ii) = repr;
end
 
size(feature_vectors_test)
save('FT_test.mat','feature_vectors_test');


% prepare the data in the format required for the cnntrain
nnn = load('train.mat');
n1 = load('FT_Train.mat');
id = nnn.imIds';
label = nnn.lbs';
images.data = single(n1.feature_vectors_train);
images.id = id;
images.label = label;
images.set = ones(1,1777);
save('Train_final.mat','images');

