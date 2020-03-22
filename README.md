# Binocular-Depth-Estimation
Binocular stereo matching has always been a research hotspot of binocular vision. Binocular cameras capture left and right viewpoint images of the same scene, using stereo matching matching algorithms to obtain disparity maps and depth maps.

Here, it is assumed that the camera has been corrected, and the test image used is only searched horizontally.

The main algorithm flow is as follows：

```flow
st=>start: 读取图像
op1=>operation: 代价计算
op2=>operation: 代价聚合
op3=>operation: 视差选择
op4=>operation: 视差细化
e=>end: 结束
st(right)->op1(right)->op2
op2(bottom)->op3
op3(left)->op4(left)->e
```
