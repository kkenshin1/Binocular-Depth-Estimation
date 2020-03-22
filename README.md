# Binocular-Depth-Estimation
Binocular stereo matching has always been a research hotspot of binocular vision. Binocular cameras capture left and right viewpoint images of the same scene, using stereo matching matching algorithms to obtain disparity maps and depth maps.

## Algorithm Flow:
> First import the left and right images, and set a reasonable search window and template size. Take each pixel as the center and use fixed-size pixels as templates. It is assumed that the camera has been corrected, so it searches only horizontally. Move the left image template continuously in the search window to calculate the cost of the left and right templates. After the cost is obtained, the signal-to-noise ratio of the result is increased by accumulating pixel information, that is, the cost aggregation process. Here we optimize the coordinates of the smallest generation value in the window, and use parabolic fitting to update the parallax value. Finally, the disparity map obtained is refined (use median filter) to eliminate part of the noise generated in the disparity map.

<div align=center><img src="https://github.com/MJ-Jiang/Binocular-Depth-Estimation/blob/master/img-storage/algorithm_flow.png" width="50%" height="50%"/></div>


### Cost Calculation
> We choose three different cost functions for calculation and select the minimum cost in the search window as the parallax
* Sum of Absolute Differences(SAD):  
<img src="https://github.com/MJ-Jiang/Binocular-Depth-Estimation/blob/master/img-storage/SAD.png" width="40%" height="40%"/>

* Normalized Cross Correlation(NCC):  
<img src="https://github.com/MJ-Jiang/Binocular-Depth-Estimation/blob/master/img-storage/NCC.png" width="40%" height="40%"/>

* Sum of Hamming Distances(SHD)：  
<img src="https://github.com/MJ-Jiang/Binocular-Depth-Estimation/blob/master/img-storage/SHD.png" width="40%" height="40%"/>


### Cost Aggregation and Parallax Refinement
The parallax value obtained above is an integer. In order to obtain higher accuracy,we use the minimum cost value and two adjacent cost values to fit the parabola.  
<div align=center><img src="https://github.com/MJ-Jiang/Binocular-Depth-Estimation/blob/master/img-storage/curve_fitting.jpeg" width="60%" height="60%"/></div>

Use the following formula to fit the parabola and update the parallax  
<img src="https://github.com/MJ-Jiang/Binocular-Depth-Estimation/blob/master/img-storage/parallax.png" width="30%" height="30%"/>

d2 - parallax calculated by cost calculation  
dset - the updated parallax  
C2 - Minimum cost  
C1,C3 - the left and the right cost between minimun cost  


## Result
> Template size: 11*11
> Parallax range: 50

The result of using SAD as cost function:  
<img src="https://github.com/MJ-Jiang/Binocular-Depth-Estimation/blob/master/img-storage/SAD_result.jpg" width="70%" height="70%"/>

The result of using NCC as cost function:  
<img src="https://github.com/MJ-Jiang/Binocular-Depth-Estimation/blob/master/img-storage/NCC_result.jpg" width="70%" height="70%"/>

The result of using SHD as cost function:  
<img src="https://github.com/MJ-Jiang/Binocular-Depth-Estimation/blob/master/img-storage/SHD_result.jpg" width="70%" height="70%"/>

Program run time (rough calculation, SHD>SAD>NCC) :
| function | SAD  | NCC | SHD |
| :--:     | :--: |:--: |:--: |
| time     | 2.18min | 0.91min | 3.99min |


## Reference
\[1][双目立体匹配步骤详解](https://www.cnblogs.com/ethan-li/p/10216647.html)  
\[2][双camera景深计算](https://www.cnblogs.com/jukan/p/6952243.html)
