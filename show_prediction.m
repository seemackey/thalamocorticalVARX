function show_prediction(x,y,yest)

clf
ydim = size(y,2);
xdim = size(x,2);
for i=1:ydim
    subplot(2,2,1); plot(x); title('External Inputs');
    subplot(2,2,2); plot(y); title('Recursive Input');
    subplot(2,ydim,ydim*1+i);
    plot([y(:,i) yest(:,i)]) % compare original to estimated output
    title(['Target and estimated output ' num2str(i)])
end

end