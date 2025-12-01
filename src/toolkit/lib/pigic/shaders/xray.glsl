//precision highp float;

varying vec3 normal; //Vertex Normal
varying vec3 vertColor; //Vertex Color
varying vec4 worldPosition;
varying vec4 viewPosition;
varying vec4 screenPosition;
varying vec4 project; //shadow projected vertex


#ifdef VERTEX

//Model and Camera
uniform mat4 projectionMatrix; //Camera Matrix (FOV, Aspect Ratio, etc.)
uniform mat4 viewMatrix; //Camera Transformation Matrix
uniform vec3 viewDir;
uniform vec3 viewPos;
uniform mat4 modelMatrix; //Model Transformaton Matrix
uniform mat4 modelMatrixInverse; //Inverse to calculate normals
attribute vec4 VertexNormal;


uniform bool animated;
attribute vec4 VertexWeight;
attribute vec4 VertexBone;
uniform mat4 u_pose[100]; //100 bones crashes web version, only set to whats absolutely necesary



vec4 position(mat4 transformProjection, vec4 vertexPosition)
{
    if (animated == true) {
        mat4 skeleton = u_pose[int(VertexBone.x*255.0)] * VertexWeight.x +
            u_pose[int(VertexBone.y*255.0)] * VertexWeight.y +
            u_pose[int(VertexBone.z*255.0)] * VertexWeight.z +
            u_pose[int(VertexBone.w*255.0)] * VertexWeight.w;
        vertexPosition = skeleton * vertexPosition;
    };

    normal = normalize(vec3(vec4(modelMatrixInverse*VertexNormal))); //interpolate normal
    
    worldPosition = modelMatrix * vertexPosition;
    viewPosition = viewMatrix * worldPosition;
    screenPosition = projectionMatrix * viewPosition;

    screenPosition.y *= -1.; // for canvas flip y thing
    return screenPosition;
}

#endif


#ifdef PIXEL

uniform Image mask;
uniform vec2 maskDimension;

mediump vec4 effect(mediump vec4 color, Image tex, mediump vec2 texcoord, mediump vec2 pixcoord)
{			
    vec4 texcolor = Texel(tex, texcoord);
    vec4 maskcolor = Texel(mask, pixcoord/maskDimension);
    if (texcolor.a == 0.0) { discard; };

    if (maskcolor.rgb == vec3(1.)) {
        return vec4(.2, .2, .2, 1.);
    } else {
        discard;
    }
}

#endif