function Q2222(varargin)
setup;
imdb = load('Train_final.mat') ;
imdb.images.data = single(imdb.images.data);
f=1/100 ;
net.layers = {} ;

net.layers{end+1} = struct('type', 'conv', ...
                           'filters', f*randn(1,1,4096,8, 'single'), ...
                           'biases', zeros(1, 8, 'single'), ...
                           'stride', 1, ...
                           'pad', 0) ;

net.layers{end+1} = struct('type', 'softmaxloss') ;

%net = vl_simplenn_tidy(net) ;
trainOpts.batchSize = 10 ;
trainOpts.numEpochs = 15 ;
trainOpts.continue = true ;
%trainOpts.useGpu = false;
trainOpts.learningRate = 0.001 ;
trainOpts.expDir = 'data/cnn3' ;
trainOpts = vl_argparse(trainOpts, varargin);

% Take the average image out
imageMean = mean(imdb.images.data(:)) ;
imdb.images.data = imdb.images.data - imageMean ;

[net,info] = cnn_train(net, imdb, @getBatch, trainOpts) ;
net.imageMean = imageMean ;
save('data/bbt3.mat', '-struct', 'net');



% Load the CNN learned before
net = load('data/bbt3.mat') ;
net.layers{end}.type = 'softmax' ;
im_ = load('FT_test.mat');
%im_ = bsxfun(@minus,im_,net.meta.normalization.averageImage) ; % may help
output =zeros(1600,1);
testD = load('test.mat');
testids = zeros(1600,1);
for jj = 1:1600
   testids(jj,1) = testD.imIds(jj); 
end
for jj = 1:1600
res = vl_simplenn(net,single(im_.feature_vectors_test(:,:,:,jj)));

hh = res(end).x;
max = -1;index = -1;
for ii=1:8
    if(hh(:,:,ii) > max)
        max = hh(:,:,ii);
        index = ii;
    end
end
output(jj,1) = index;
end
final_output = [testids,output];
csvwrite('110849636.csv',final_output) %final csv output goes here.ImgIds and Prediction title are added manually


function [im, labels] = getBatch(imdb, batch)
% --------------------------------------------------------------------
im = imdb.images.data(:,:,:,batch) ;
labels = imdb.images.label(1,batch) ;
