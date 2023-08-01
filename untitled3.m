% 创建视频读取对象
videoFile = "C:\Users\YG\Desktop\行人检测.mp4";
videoReader = VideoReader(videoFile);

% 创建行人检测器对象
detector = peopleDetectorACF();

% 创建图像显示窗口
figure;

% 设置危险区域（多边形区域顶点坐标）
dangerZone = [100, 150; 200, 150; 200, 250; 100, 250]; % [x1, y1; x2, y2; x3, y3; x4, y4]

% 设置报警阈值
alarmThreshold = 0.5;

% 创建视频写入对象（用于保存结果）
outputVideoFile ="D:\文件\xrjc.mp4";
outputVideoWriter = VideoWriter(outputVideoFile, 'MPEG-4');
open(outputVideoWriter);

%通过 while 循环逐帧读取视频的每一帧
while hasFrame(videoReader)

% 读取视频当前帧
frame = readFrame(videoReader);

% 对图像（当前帧）进行预处理
processedImg = frame;

% 使用行人检测器检测行人，并获取检测结果的边界框和置信度
[bboxes, scores] = detect(detector, processedImg);
% 根据置信度筛选检测结果，选择置信度大于阈值的行人
selectedIdx = scores > alarmThreshold;

%根据筛选结果更新边界框
bboxes = bboxes(selectedIdx, :);
% 在图像中标注行人区域
detectedImg = insertObjectAnnotation(frame, 'rectangle', bboxes, scores(selectedIdx));
% 在图像中标注危险区域
detectedImg = insertShape(detectedImg, 'polygon', dangerZone, 'LineWidth', 2, 'Color', 'r');
% 显示标注后的图像
imshow(detectedImg);
% 检测是否有人进入危险区域
for i = 1:size(bboxes, 1) %遍历每个检测到的行人边界框
personBox = bboxes(i, :); %获取当前行人边界框
if isInsidePolygon(personBox, dangerZone) %判断行人是否进入危险区域
% 如果行人进入危险区域，则触发报警并显示警告信息
disp('警告: 有人进入危险区域!');
end
end
% 将标注后的图像写入结果视频
writeVideo(outputVideoWriter, detectedImg);
end %结束当前循环，继续下一帧的处理

% 释放资源
close(outputVideoWriter); %关闭视频写入对象，完成结果视频的写入
release(videoReader); %释放视频读取对象和资源

%定义一个辅助函数 isInsidePolygon，用于判断一个点是否在多边形内部
function inside = isInsidePolygon(point, polygon)
% 判断点是否在多边形内（射线法）
x = point(1);
y = point(2); %获取点的 x 和 y 坐标
n = size(polygon, 1); %获取多边形的顶点个数
inside = false; %初始化判断结果为 false
p1 = polygon(1, :); %获取多边形的第一个顶点
for i = 1:n + 1 %遍历多边形的每条边，包括首尾相连的边
p2 = polygon(mod(i, n) + 1, :); %获取当前边的终点

%判断点的 y 坐标是否在边的 y 坐标范围内
if y > min(p1(2), p2(2)) && y <= max(p1(2), p2(2))

%判断点的 x 坐标是否小于等于边的最大 x 坐标
if x <= max(p1(1), p2(1))

%检查当前边是否不是水平线段
if p1(2) ~= p2(2)

%计算射线与边的交点的 x 坐标
xinters = (y - p1(2)) * (p2(1) - p1(1)) / (p2(2) - p1(2)) + p1(1);
%判断点是否在边的左侧
if p1(1) == p2(1) || x <= xinters

inside = ~inside; %更新判断结果为 true
end
end
end
end
p1 = p2; %将当前边的终点作为下一条边的起点
end %结束当前循环，返回到第75行继续遍历下一条边
end %结束辅助函数 isInsidePolygon 的定义