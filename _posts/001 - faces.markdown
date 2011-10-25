---
categories: WorkInProgress,FaceTracking,FaceSubstitution,openFrameworks
date: 2011/10/25 13:40:00
title: Faces. How it works.
---
An idea i'm working on with <a href="http://kylemcdonald.net">Kyle McDonald</a>

<iframe src="http://player.vimeo.com/video/29279198?title=0&amp;byline=0&amp;portrait=0" width="480" height="360" frameborder="0" webkitAllowFullScreen allowFullScreen></iframe>


--more--

Faces works mainly thanks to Jason Saragih's library for face tracking which can be found <a href="http://web.mac.com/jsaragih/FaceTracker/FaceTracker.html">here</a> 

To make it easier to use <a href="http://kylemcdonald.net">Kyle McDonald</a> developed some months ago the OF addon <a href="https://github.com/kylemcdonald/ofxFaceTracker">ofxFaceTracker</a>. This addon returns a mesh which vertexes match the facial features found in a picture of a face. To understand better how it works take a look at this video which shows the raw output of Jason's library:

<iframe src="http://player.vimeo.com/video/26193188?title=0&amp;byline=0&amp;portrait=0" width="480" height="360" frameborder="0" webkitAllowFullScreen allowFullScreen></iframe>

The returned vertexes are always the same in the same order for every face, which makes it extremely easy to get the face in a photo and adapt it to match a face found in a video.

In openGL, if you pass a mesh and a texture for that mesh to the graphics card, moving the vertexes makes the texture stretch or srink accordingly. So to adapt the face in the photo to the one in the video you just need to move the vertexes of the mesh in the photo to match the ones in the video, indeed you just need to use the mesh of the video with the texture and texture coordinates of the photo, something like:

$$code(lang=c++)
void testApp::update(){
    for(int i=0;i<meshVideo.getNumVertices();i++){
        meshVideo.addTexCoord(meshPhoto.getVertex(i));
    }
}

void testApp::draw(){
    video.draw(0,0);
    photo.getTextureReference().bind();
    meshVideo.draw();
    photo.getTextureReference().unbind();
}

$$/code

Something like this will make the result look very unatural cause skin tones and lighting are usually different in the photo and the video. To correct for that we use some color interpolation. To put it simple we take the color for each vertex in the photo and in the video make an average and use that as the color for the mesh that is going to be drawn. The graphics card does the rest by interpolating the color of each vertex to the rest of the texture. (The actual algorithm is a little bit more complex than this)

$$code(lang=c++)
for(int i=0;i<meshVideo.getNumVertices();i++){
    ofColor colorPhoto = photo.getPixelsRef().getColor(meshPhoto.getVertex(i));
    ofColor colorVideo = video.getPixelsRef().getColor(meshVideo.getVertex(i));
    ofFloatColor dstColor = (colorPhoto + colorVideo)*0.5
    meshVideo.addColorCoord(dstColor);
}
$$/code

The source code and osx binaries can be found in <a href="http://github.com/arturoc/FaceSubstitution">my github</a>. Take into account that this cannot be used commercially since Jason's Face Tracking library can only be used for research purposes.
