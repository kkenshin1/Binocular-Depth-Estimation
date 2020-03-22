clc;
clear;

%% 加载2张立体图像
left = imread('iml1545.jpg');
right = imread('imr1545.jpg');
sizeI = size(left);

% 显示复合图像
zero = zeros(sizeI(1), sizeI(2));
channelRed = left(:,:,1);
channelBlue = right(:,:,3);
composite = cat(3, channelRed, zero, channelBlue);

figure(1);
subplot(2,3,1);
imshow(left);
axis image;
title('左图');

subplot(2,3,2);
imshow(right);
axis image;
title('右图');

subplot(2,3,3);
imshow(composite);
axis image;
title('重叠图');

%% 基本的块匹配

% 通过估计子像素的块匹配计算视差
disp('运行基本的块匹配~');

% 启动定时器
tic();

% 平均3个颜色通道值将RGB图像转换为灰度图像
leftI = mean(left, 3);
rightI = mean(right, 3);


% SHD
%  bitsUint8 = 8;
% leftI = im2uint8(leftI./255.0);
% rightI = im2uint8(rightI./255.0);


% DbasicSubpixel将保存块匹配的结果，元素值为单精度32位浮点数
DbasicSubpixel = zeros(size(leftI), 'single');

% 获得图像大小
[imgHeight, imgWidth] = size(leftI);

% 视差范围定义离第1幅图像中的块位置多少像素远来搜索其它图像中的匹配块。
disparityRange = 50;

% 定义块匹配的块大小
halfBlockSize = 5;
blockSize = 2 * halfBlockSize + 1;

% 对于图像中的每行（m）像素
for (m = 1 : imgHeight)
    	
	% 为模板和块设置最小/最大块边界
	% 比如：第1行，minr = 1 且 maxr = 4
    minr = max(1, m - halfBlockSize);
    maxr = min(imgHeight, m + halfBlockSize);
	
    % 对于图像中的每列（n）像素
    for (n = 1 : imgWidth)
        
        % 为模板设置最小/最大边界
        % 比如：第1列，minc = 1 且 maxc = 4
		minc = max(1, n - halfBlockSize);
        maxc = min(imgWidth, n + halfBlockSize);
        
        % 将模板位置定义为搜索边界，限制搜索使其不会超出图像边界 
		% 'mind'为能够搜索至左边的最大像素数；'maxd'为能够搜索至右边的最大像素数
		% 这里仅需要向右搜索，所以mind为0
		% 对于要求双向搜索的图像，设置mind为max(-disparityRange, 1 - minc)
		mind = 0; 
        maxd = min(disparityRange, imgWidth - maxc);

		% 选择右边的图像块用作模板
        template = rightI(minr:maxr, minc:maxc);
		
		% 获得本次搜索的图像块数
		numBlocks = maxd - mind + 1;
		
		% 创建向量来保存块偏差
		blockDiffs = zeros(numBlocks, 1);
        
		% 计算模板和每块的偏差
		for (i = mind : maxd)
		
			%选择左边图像距离为'i'处的块
			block = leftI(minr:maxr, (minc + i):(maxc + i));
		
			% 计算块的基于1的索引放进'blockDiffs'向量
			blockIndex = i - mind + 1;
		    
            %{
            % NCC（Normalized Cross Correlation）
            ncc = 0;
            nccNumerator = 0;
            nccDenominator = 0;
            nccDenominatorRightWindow = 0;
            nccDenominatorLeftWindow = 0;
            %}
            
            % 计算模板和块间差的绝对值的和（SAD）作为结果
            for (j = minr : maxr)
                for (k = minc : maxc)
                    
                    % SAD（Sum of Absolute Differences）
                    blockDiff = abs(rightI(j, k) - leftI(j, k + i));
                    blockDiffs(blockIndex, 1) = blockDiffs(blockIndex, 1) + blockDiff;
                    
                    
                    %{
                    % NCC
                    nccNumerator = nccNumerator + (rightI(j, k) * leftI(j, k + i));
                    nccDenominatorLeftWindow = nccDenominatorLeftWindow + (leftI(j, k + i) * leftI(j, k + i));
                    nccDenominatorRightWindow = nccDenominatorRightWindow + (rightI(j, k) * rightI(j, k));
                    %}
                end
            end
            
            % SAD
            blockDiffs(blockIndex, 1) = sum(sum(abs(template - block)));
            
            
            %{
            % NCC
            nccDenominator = sqrt(nccDenominatorRightWindow * nccDenominatorLeftWindow);
            ncc = nccNumerator / nccDenominator;
            blockDiffs(blockIndex, 1) = ncc;
            %}
            
            %{
            % SHD（Sum of Hamming Distances）
            blockXOR = bitxor(template, block);
            distance = uint8(zeros(maxr - minr + 1, maxc - minc + 1));
            for (k = 1 : bitsUint8)
                distance = distance + bitget(blockXOR, k);
            end
            blockDiffs(blockIndex, 1) = sum(sum(distance));
            %}
		end
		
		% SAD值排序找到最近匹配（最小偏差），这里仅需要索引列表

        % SAD/SSD/SHD
        [temp, sortedIndeces] = sort(blockDiffs, 'ascend');

        %{
        % NCC
        [temp, sortedIndeces] = sort(blockDiffs, 'descend');
        %}
        % 获得最近匹配块的基于1的索引
		bestMatchIndex = sortedIndeces(1, 1);
		
        % 将该块基于1的索引恢复为偏移量
		% 这是基本的块匹配产生的最后的视差结果
		d = bestMatchIndex + mind - 1;
		
        
		% 通过插入计算视差的子像素估计
		% 子像素估计要求用左右边的块, 所以如果最佳匹配块在搜索窗的边缘则忽略估计
		if ((bestMatchIndex == 1) || (bestMatchIndex == numBlocks))
			% 忽略子像素估计并保存初始视差值
			DbasicSubpixel(m, n) = d;
		else
			% 取最近匹配块（C2）的SAD值和最近的邻居（C1和C3）
			C1 = blockDiffs(bestMatchIndex - 1);
			C2 = blockDiffs(bestMatchIndex);
			C3 = blockDiffs(bestMatchIndex + 1);
			
			% 调整视差：估计最佳匹配位置的子像素位置
			DbasicSubpixel(m, n) = d - (0.5 * (C3 - C1) / (C1 - (2 * C2) + C3));
        end
        
        %{
        DbasicSubpixel(m, n) = d;
        %}
    end

	% 每10行更新过程
	if (mod(m, 10) == 0)
		fprintf('图像行：%d / %d (%.0f%%)\n', m, imgHeight, (m / imgHeight) * 100);
    end		
end

% 显示计算时间
elapsed = toc();
fprintf('计算视差图花费 %.2f min.\n', elapsed / 60.0);

%% 显示视差图
fprintf('显示视差图~\n');

% 切换到图像4
subplot(2,3,4);
% 第2个参数为空矩阵，从而告诉imshow用数据的最小/最大值，并且映射数据范围来显示颜色
imshow(DbasicSubpixel, []);
title('视差图');

%中值滤波，窗口选择25*25较为合适
DbasicSubpixel_2 = medfilt2(DbasicSubpixel,[25 25]);
subplot(2,3,5);
imshow(DbasicSubpixel_2,[]);
title('滤波后');

% 去掉颜色图会显示灰度视差图
% colormap('jet');
% colorbar;



