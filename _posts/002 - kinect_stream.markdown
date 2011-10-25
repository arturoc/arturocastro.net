---
categories: ArtAndCode,3D,Kinect,Streaming,openFrameworks
date: 2011/10/25 15:10:00
title: Depth data steaming
---
![pointcloud](/images/kinectStream/img1.jpg)

Some days ago this [tweet](http://twitter.com/#!/JoelGethinLewis/status/126374532649979905) got me intrigued. Some hours later Joel asked for help to [@mrdoob](http://twitter.com/mrdoob) since him and [@marcinignac](http://twitter.com/marcinignac) did some pointcloud visualization in the browser using mrdoob's Three.js library during OFFF 2011. I had some code for streaming using gstreamer in openFrameworks so it was just a matter of joining the pieces.

[@joelgethinlewis](http://twitter.com/JoelGethinLewis) and [@roxlu](http://twitter.com/roxlu) were trying to make this work at [Art and code 2011]("http://artandcode.com/3d) which topic this year was DIY 3D sensing and visualization.

--more--

[@Roxlu](http://twitter.com/roxlu) almost had this running using ffmpeg, the main problem with this approach is that for each client connected to the server there was going to be a stream, and probably the server and the bandwidth weren't going to be enough. The key was to have the server only producing one stream and some online service streaming it to the clients. In the end we didn't manage to make this run because of problems with cross-site security in browsers so probably [@roxlu](http://twitter.com/roxlu)'s solution would have worked the same.

There's a great service for free streaming called [giss.tv](http://giss.tv). Yves one of the admins of the site has some python tools that actually use gstreamer. The same pipeline used by that tools with some modifications to get the depth info coming from the kinect worked without problem with [ofGstUtils](https://github.com/openframeworks/openFrameworks/blob/master/libs/openFrameworks/video/ofGstUtils.h).

Gstreamer has 2 elements which are really useful when you want to process custom data: appsrc, for feeding data into a pipeline and appsink for getting data out of it. appsink is used internally in OF to get data from cameras or video files and upload it to textures in the linux version of the video grabber and the video player.

Using appsrc is really easy to feed the depth data from the kinect into a pipeline and then stream it to [giss.tv](http://giss.tv). Since the video stream has color information (3 channels) and the depth data only 1 the red channel can be used to feed the depth data and the green one to send brightness, something like:

$$code(lang=c++)
for(int i=0;i<640*480;i++){
    pixels[i*3] = kinect.getDepthPixels()[i];
    pixels[i*3+1] = (kinect.getPixels()[i*3] 
        + kinect.getPixels()[i*3+1] 
        + kinect.getPixels()[i*3+2]) / 3;
    pixels[i*3+2] = 0;
}
// feed pixels into the gstreamer streaming pipeline
$$/code


The blue channel is unused here so it's even possible to send the raw depth data returned by kinect, which is 16bits, using r & g and b for brightness or do some kind of duplication of the depth data to have more chances of reconstructing it later avoiding compression artifacts.

In HTML5 you can get the pixel data of any element, for example a video and upload it to the graphics card in a texture using webGL. Then using some shaders [@mrdoob](http://twitter.com/mrdoob) and [@kcmic](http://twitter.com/kcmic) managed to separate the depth data from the brightness to generate a point cloud.

The main problems we had were with cross-site security in browsers which didn't allowed to use the stream directly from [giss.tv](http://giss.tv) so in the last minute we had to do a php script which read the stream and served it as if it was comming from the same server as the web page. This was a really ugly hack and as soon as 1000 petitions came when [@golan](http://twitter.com/golan) tweeted about the stream the server couldn't handle it.

The other problem was that theora compression (or any other video compression for that matter) is actually optimized for images not depth data so there was some really noticeable artifacts in the final point cloud. 

The source code is [here](http://github.com/arturoc/kinectStream)

--col2--

![chris sugrue](/images/kinectStream/img2.jpg)
[@chrissugrue](http://twitter.com/chrissugrue) talking about her lastest work [Base8](http://vimeo.com/30834797)

![golan and kyle](/images/kinectStream/img3.jpg)
[@golan](http://twitter.com/golan]) and [@kcmic](http://twitter.com/kcmic) preparing the stage

![compression artifacts](/images/kinectStream/img4.jpg)
Same image as above but the perspective is slightly different from that of the kinect, allowing to see the artifacts introduced by the theora compression in the depth data

![first transmission](/images/kinectStream/img5.jpg)
Raw depth image, the first data we managed to stream

