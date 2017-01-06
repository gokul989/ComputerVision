function H = computeH(t1,t2)
movingPoints = t1;
fixedPoints = t2;
N = size(movingPoints,2);


A = zeros(2*N,9);

    for n = 1:N
	x1 = movingPoints(1,n);y1 = movingPoints(2,n);
	x2 = fixedPoints(1,n); y2 = fixedPoints(2,n);
    A(2*n-1,:) = [x1 y1 1 0 0 0 -1*x2*x1 -1*x2*y1 -1*x2];	
	A(2*n,:) = [0 0 0 1*x1 1*y1 1 -1*y2*x1 -1*y2*y1 -1*y2];
	
    end
    
    [U,D,V] = svd(A,0);
    H = reshape(V(:,9),3,3)';
    H = H./H(3,3);
end
    