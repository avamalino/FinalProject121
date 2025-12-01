#ifdef VERTEX

vec4 worldPosition;
vec4 screenPosition;

//Model and Camera
uniform mat4 projectionMatrix; //Camera Matrix (FOV, Aspect Ratio, etc.)
uniform mat4 viewMatrix; //Camera Transformation Matrix
uniform mat4 modelMatrix; //Model Transformaton Matrix
uniform mat4 modelMatrixInverse; //Inverse to calculate normals
attribute vec4 VertexNormal;

uniform bool animated;
attribute vec4 VertexWeight;
attribute vec4 VertexBone;
uniform mat4 u_pose[100]; //100 bones crashes web version, only set to whats absolutely necesary


//Shadow Map
uniform mat4 shadowProjectionMatrix;
uniform mat4 shadowViewMatrix;

uniform vec3 playerPosition;
uniform vec3 playerEyeDir;
uniform bool useOpacity;



vec4 position(mat4 transformProjection, vec4 vertexPosition)
{    
    if (animated == true) {
        mat4 skeleton = u_pose[int(VertexBone.x*255.0)] * VertexWeight.x +
            u_pose[int(VertexBone.y*255.0)] * VertexWeight.y +
            u_pose[int(VertexBone.z*255.0)] * VertexWeight.z +
            u_pose[int(VertexBone.w*255.0)] * VertexWeight.w;
        vertexPosition = skeleton * vertexPosition;
        mat4 transform = modelMatrixInverse * skeleton;
    };
    
    worldPosition = modelMatrix * vertexPosition;

    float curveAmount = 0.005;
    vec3 curvePosition = worldPosition.xyz;
    float dist = length(worldPosition.xz - playerPosition.xz);
    curvePosition.y -= curveAmount * pow(dist, 2.25);

    vec4 viewPosition = viewMatrix * vec4(curvePosition, 1.0);
    screenPosition = projectionMatrix * viewPosition;
    screenPosition.y *= -1.; // for canvas flip y thing

    return screenPosition;
}

#endif


#ifdef PIXEL


vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 pixcoord)
{
    //IGNORE ALPHA
    vec4 texcolor = Texel(tex, texcoord);
    if (texcolor.a == 0.0) { discard; };

    return texcolor * color;
}

#endif