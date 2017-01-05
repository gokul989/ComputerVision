function fivefold(varargin)
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

temp = load('train.mat');
trainImgIds = 1:1775;
trainImgLabels = temp.lbs';
reshapeIds = reshape(trainImgIds,[5, 1775/5]);
accuracy = 0;

for iter = 1:5
    
testIndices = reshapeIds(iter, :);
trainIndices = setdiff(trainImgIds, testIndices);
imdb.images.set(testIndices) =  3;
imdb.images.set(trainIndices) = 1; 
 
[net, info] = cnn_train(net, imdb, @getBatch, trainOpts);
net.imageMean = imageMean ;
save('data/bbt3.mat', '-struct', 'net');

net = load('data/bbt3.mat') ;
net.layers{end}.type = 'softmax' ;

%im_ = bsxfun(@minus,im_,net.meta.normalization.averageImage) ; % may help

count =0;
for jj = 1:355
res = vl_simplenn(net,single(imdb.images.data(:,:,:,testIndices(:,jj))));

hh = res(end).x;
max = -1;index = -1;
for ii=1:8
    if(hh(:,:,ii) > max)
        max = hh(:,:,ii);
        index = ii;
    end
end
if(index == trainImgLabels(:,testIndices(:,jj)))
    count = count+1;
end

end
accuracy = accuracy + count/355;
end
accuracy = accuracy*100




function [im, labels] = getBatch(imdb, batch)
% --------------------------------------------------------------------
im = imdb.images.data(:,:,:,batch) ;
labels = imdb.images.label(1,batch) ;