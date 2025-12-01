#pragma language glsl3

#ifdef GL_ES
precision highp float;
#endif

varying vec3 worldNormal;
varying vec4 vertexNormal;
varying vec3 vertColor; //Vertex Color
varying vec4 worldPosition;
varying vec4 viewPosition;
varying vec4 screenPosition;
varying vec4 project; //shadow projected vertex
// varying vec3 viewDirection;
varying float opacity;

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
    
    project = vec4(shadowProjectionMatrix * shadowViewMatrix * modelMatrix * vertexPosition * Bias); //projected position on shadowMap

    worldPosition = modelMatrix * vertexPosition;

    float curveAmount = 0.0;//0.00005;
    vec3 curvePosition = worldPosition.xyz;
    float dist = length(worldPosition.xz - playerPosition.xz);
    curvePosition.y -= curveAmount * pow(dist, 2.25);

    viewPosition = viewMatrix * vec4(curvePosition, 1.0);
    screenPosition = projectionMatrix * viewPosition;
    screenPosition.y *= -1.; // for canvas flip y thing

    // viewDirection = normalize(eyePosition.xyz - worldPosition.xyz);

    if (useOpacity) {
        vec3 playerVertDir = normalize(worldPosition.xyz - playerPosition);
        float opacityDot = dot(playerVertDir, playerEyeDir);
        opacity = 1.0 - clamp(opacityDot, 0.0, 1.0);
    } else {
        opacity = 1.0;
    }

    return screenPosition;
}

#endif


#ifdef PIXEL


//Lighting
uniform float ambientLight;
uniform float ambientLightAdd;
uniform vec3 ambientVector; //Sun Light

vec3 shadowColor = vec3(0.0,0.0,0.0);
// vec4 lightColor = vec4(1.0,0.0,0.0,1.0);

//Shadow Map
uniform vec3 shadowMapDir; //should be the same as ambientVector, but for this game im stylizing the lighting
uniform Image shadowMapImage;


uniform float shadowBiasStrength; //Fixes Shadow Acne
uniform float slopeScaledBiasStrength;//0.001; // Slope-scaled bias strength

// uniform bool useShadow = true;

uniform int dither[64];
// const int dither[64] = int[](
//         0, 32,  8, 40,  2, 34, 10, 42,  
//     48, 16, 56, 24, 50, 18, 58, 26,  
//     12, 44,  4, 36, 14, 46,  6, 38,  
//     60, 28, 52, 20, 62, 30, 54, 22,  
//         3, 35, 11, 43,  1, 33,  9, 41,  
//     51, 19, 59, 27, 49, 17, 57, 25,  
//     15, 47,  7, 39, 13, 45,  5, 37,  
//     63, 31, 55, 23, 61, 29, 53, 21
// );

float find_closest(int x, int y, float c0) {
    // Ensure x and y are within range to avoid out-of-bounds access
    // if (x < 0 || x >= 8 || y < 0 || y >= 8) {
    //     return 0.0;
    // }

    int index = x + y * 8;  // Convert (x, y) to 1D index
    float limit = float(dither[index] + 1) / 64.0;

    return (c0 < limit) ? 0.0f : 1.0f;
}

float PCF(vec2 shadowMapCoord, float pixelDist, float bias) {
    float shadow = 0.0;
    vec2 texelSize = vec2(1.0 / textureSize(shadowMapImage, 0));
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            float shadowMapPixelDist = Texel(shadowMapImage, shadowMapCoord + vec2(x, y) * texelSize).r;
            shadow += (shadowMapPixelDist < pixelDist - bias) ? 0.0 : 1.0;
        }
    }
    return shadow / 9.0; // Average of 9 samples
}

float ManualBilinearPCF(vec2 shadowMapCoord, float pixelDist, float bias) {
    vec2 texelSize = vec2(1.0) / textureSize(shadowMapImage, 0);
    vec2 f = fract(shadowMapCoord * textureSize(shadowMapImage, 0)); // Interpolation weights
    vec2 base = (shadowMapCoord - f * texelSize); // Get the base texel

    // Sample 4 nearby depth values
    float d00 = Texel(shadowMapImage, base).r;
    float d10 = Texel(shadowMapImage, base + vec2(texelSize.x, 0)).r;
    float d01 = Texel(shadowMapImage, base + vec2(0, texelSize.y)).r;
    float d11 = Texel(shadowMapImage, base + texelSize).r;

    // Bilinear interpolation
    float depth = mix(mix(d00, d10, f.x), mix(d01, d11, f.x), f.y);

    return (depth < pixelDist - bias) ? 0.0 : 1.0;
}

mediump vec4 effect(mediump vec4 color, Image tex, mediump vec2 texcoord, mediump vec2 pixcoord) {


    // return vec4(worldNormal, 1.);
    //IGNORE ALPHA
    vec4 texcolor = Texel(tex, texcoord);
    if (texcolor.a == 0.0) { discard; };
    texcolor = texcolor*color; //apply color

    // return vertexNormal;
    vec3 n = normalize(worldNormal);
    vec3 normalColor = (n + vec3(1.0)) * 0.5; // Shift from [-1, 1] to [0, 1]

    //STEPPED LIGHING (Cel Shading)
    vec3 lightDir = ambientVector; //Sun Light
    float diffuse = max(dot(lightDir, normalColor), 0.0); //smooth lighting
    // Cel shading step function
    diffuse += ambientLightAdd;
    diffuse = clamp(diffuse, 0.0, 1.0);
    // float levels = 5.; // Number of shading levels
    // diffuse = floor(diffuse * levels) / levels;
    
    float slope = tan(acos(dot(worldNormal, shadowMapDir))); // Slope of the surface relative to light
    float slopeScaledBias = slope * slopeScaledBiasStrength; // Slope-scaled bias
    float constantBias = shadowBiasStrength; // Constant bias
    float shadowBias = constantBias + slopeScaledBias; // Combined bias

    float pixelDist = (project.z-shadowBias) / project.w; //How far this pixel is from the camera
    vec2 shadowMapCoord = ((project.xy) / project.w); //Where this vertex is on the shadowMap
    float shadowMapPixelDist;
    float inShadow;

    //SHADOW SMOOTHING
    shadowMapPixelDist = Texel(shadowMapImage, shadowMapCoord).r;
    inShadow = mix(float(shadowMapPixelDist < pixelDist), 0.0, 1.0 - float((shadowMapCoord.x >= 0.0) && (shadowMapCoord.y >= 0.0) && (shadowMapCoord.x <= 1.0) && (shadowMapCoord.y <= 1.0))); //0.0;

    // inShadow = (1. - PCF(shadowMapCoord, pixelDist, shadowBias));
    // inShadow = step(0.1, inShadow);

    //FINALIZE SHADOWS
    diffuse = min(1.0 - inShadow * (1.0 - ambientLight), diffuse); //shadow
    if (opacity < 1.0) {
        vec2 xy = pixcoord.xy * 1.0;
        int x = int(mod(xy.x, 8.0));
        int y = int(mod(xy.y, 8.0));

        float finalOpacity = find_closest(x, y, opacity);
        if (finalOpacity == 0.0) {
            discard;
        }
    }
    vec4 finalcolor = vec4(vec3(texcolor) * mix(shadowColor, vec3(1.0), max(diffuse, ambientLight)), 1.0);
    return finalcolor;
}

#endif
