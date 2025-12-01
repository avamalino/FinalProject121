#ifdef VERTEX

uniform mat4 projectionMatrix;
uniform mat4 modelMatrix;
uniform mat4 viewMatrix;

uniform bool animated;
attribute vec4 VertexWeight;
attribute vec4 VertexBone;
uniform mat4 u_pose[100]; //100 bones crashes web version, only set to whats absolutely necesary


vec4 position(mat4 transformProjection, vec4 vertexPosition) {
    if (animated == true) {
        mat4 skeleton = u_pose[int(VertexBone.x*255.0)] * VertexWeight.x +
            u_pose[int(VertexBone.y*255.0)] * VertexWeight.y +
            u_pose[int(VertexBone.z*255.0)] * VertexWeight.z +
            u_pose[int(VertexBone.w*255.0)] * VertexWeight.w;
        vertexPosition = skeleton * vertexPosition;
    };

    vec4 screenPosition =  projectionMatrix * viewMatrix * modelMatrix * vertexPosition;
    return screenPosition;
}

#endif

#ifdef PIXEL

vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 pixcoord)
{
    vec4 texcolor = Texel(tex, texcoord);
    if (texcolor.a == 0.0) { discard; }
    return texcolor;
}

#endif