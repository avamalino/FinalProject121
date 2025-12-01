// #pragma language glsl3

// #ifdef GL_ES
// precision highp float;
// #endif

varying vec3 worldNormal;
varying vec4 vertexNormal;
varying vec3 vertColor; //Vertex Color
varying vec4 worldPosition;
varying vec4 viewPosition;
varying vec4 screenPosition;
varying vec4 project; //shadow projected vertex

#ifdef VERTEX

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


mat4 Bias = mat4( // change projected depth values from -1 - 1 to 0 - 1
	0.5, 0.0, 0.0, 0.5,
	0.0, 0.5, 0.0, 0.5,
	0.0, 0.0, 0.5, 0.5,
	0.0, 0.0, 0.0, 1.0
	);

vec4 position(mat4 transformProjection, vec4 vertexPosition)
{
    worldNormal = normalize(vec3(vec4(modelMatrixInverse*VertexNormal))); //interpolate normal
    
    if (animated == true) {
        mat4 skeleton = u_pose[int(VertexBone.x*255.0)] * VertexWeight.x +
            u_pose[int(VertexBone.y*255.0)] * VertexWeight.y +
            u_pose[int(VertexBone.z*255.0)] * VertexWeight.z +
            u_pose[int(VertexBone.w*255.0)] * VertexWeight.w;
        vertexPosition = skeleton * vertexPosition;
        mat4 transform = modelMatrixInverse * skeleton;
        worldNormal = normalize(mat3(transform) * vec3(VertexNormal));
    };

    vertexNormal = VertexNormal;
    
    // project = vec4(shadowProjectionMatrix * shadowViewMatrix * modelMatrix * vertexPosition * Bias); //projected position on shadowMap

    worldPosition = modelMatrix * vertexPosition;

    float curveAmount = 0.005;
    vec3 curvePosition = worldPosition.xyz;
    float dist = length(worldPosition.xz - playerPosition.xz);
    curvePosition.y -= curveAmount * pow(dist, 2.25);

    viewPosition = viewMatrix * vec4(curvePosition, 1.0);
    screenPosition = projectionMatrix * viewPosition;
    screenPosition.y *= -1.; // for canvas flip y thing

    return screenPosition;
}

#endif


#ifdef PIXEL


//Lighting
uniform float ambientLight;
uniform float ambientLightAdd;
uniform vec3 ambientVector; //Sun Light

vec3 shadowColor = vec3(0.9, 0.9, 0.9);
// vec4 lightColor = vec4(1.0,0.0,0.0,1.0);

//Shadow Map
uniform vec3 shadowMapDir; //should be the same as ambientVector, but for this game im stylizing the lighting
uniform Image shadowMapImage;


uniform float shadowBiasStrength; //Fixes Shadow Acne
uniform float slopeScaledBiasStrength;//0.001; // Slope-scaled bias strength

uniform bool useShadow;


vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 pixcoord)
{
    //IGNORE ALPHA
    vec4 texcolor = Texel(tex, texcoord);
    if (texcolor.a == 0.0) { discard; };
    texcolor = texcolor*color; //apply color

    if (useShadow) {
        float slope = tan(acos(dot(worldNormal, shadowMapDir))); // Slope of the surface relative to light
        float slopeScaledBias = slope * slopeScaledBiasStrength; // Slope-scaled bias
        float constantBias = shadowBiasStrength; // Constant bias
        float shadowBias = constantBias + slopeScaledBias; // Combined bias

        float pixelDist = (project.z-shadowBias)/project.w; //How far this pixel is from the camera
        vec2 shadowMapCoord = ((project.xy)/project.w); //Where this vertex is on the shadowMap
        float shadowMapPixelDist;
        float inShadow;

        //SHADOW SMOOTHING
        shadowMapPixelDist = Texel(shadowMapImage, shadowMapCoord).r;
        inShadow = mix(float(shadowMapPixelDist < pixelDist),0.0,1.0-float((shadowMapCoord.x >= 0.0) && (shadowMapCoord.y >= 0.0) && (shadowMapCoord.x <= 1.0) && (shadowMapCoord.y <= 1.0))); //0.0;

        // //FINALIZE SHADOWS
        vec4 finalcolor = vec4(vec3(texcolor) * mix(shadowColor, vec3(1.0), 1.0 - inShadow), 1.0);
        return finalcolor;
    } else {
        return texcolor;
    }
}

#endif