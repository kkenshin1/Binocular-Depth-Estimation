# Binocular-Depth-Estimation
Binocular stereo matching has always been a research hotspot of binocular vision. Binocular cameras capture left and right viewpoint images of the same scene, using stereo matching matching algorithms to obtain disparity maps and depth maps.

### Algorithm Flow:
First import the left and right images, and set a reasonable search window and template size. Take each pixel as the center and use fixed-size pixels as templates. It is assumed that the camera has been corrected, so it searches only horizontally. Move the left image template continuously in the search window to calculate the cost of the left and right templates. After the cost is obtained, the signal-to-noise ratio of the result is increased by accumulating pixel information, that is, the cost aggregation process. Here we optimize the coordinates of the smallest generation value in the window, and use parabolic fitting to update the parallax value. Finally, the disparity map obtained is refined (using median filtering) to eliminate part of the noise generated in the disparity map.
![image]https://github.com/MJ-Jiang/Binocular-Depth-Estimation/blob/master/img-storage/algorithm_flow.png
