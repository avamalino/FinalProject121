#pragma language glsl3

varying vec3 worldNormal;
varying vec4 vertexNormal;
varying vec3 vertColor;
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

//Shadow Map
uniform mat4 shadowProjectionMatrix;
uniform mat4 shadowViewMatrix;

mat4 Bias = mat4( // change projected depth values from -1 - 1 to 0 - 1
	0.5, 0.0, 0.0, 0.5,
	0.0, 0.5, 0.0, 0.5,
	0.0, 0.0, 0.5, 0.5,
	0.0, 0.0, 0.0, 1.0
	);

vec4 position(mat4 transformProjection, vec4 vertexPosition)
{
    worldNormal = normalize(vec3(vec4(modelMatrixInverse*VertexNormal))); //interpolate normal
    vertexNormal = VertexNormal;
    
    project = vec4(shadowProjectionMatrix * shadowViewMatrix * modelMatrix * vertexPosition * Bias); //projected position on shadowMap

    worldPosition = modelMatrix * vertexPosition;
    viewPosition = viewMatrix * worldPosition;
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

vec3 shadowColor = vec3(0.0,0.2,0.6);
vec4 lightColor = vec4(1.0,0.0,0.0,1.0);

//Shadow Map
uniform vec3 shadowMapDir; //should be the same as ambientVector, but for this game im stylizing the lighting
uniform Image shadowMapImage;

float shadowBiasStrength = 0.0005; //Fixes Shadow Acne
float slopeScaledBiasStrength = 0.0001; // Slope-scaled bias strength

uniform Image groundTex;
uniform Image grassTex;
uniform Image brushTex;
uniform float groundScale;
uniform float grassScale;
uniform float yTransition;

uniform bool useTriplanar;
uniform vec3 centerPoint;
float shadowFactor;

// uniform vec3 cameraPosition;


// Percentage-Closer Filtering (PCF) for softer shadows
// float PCF(vec2 shadowMapCoord, float pixelDist, float bias) {
//     float shadow = 0.0;
//     vec2 texelSize = vec2(1.0 / textureSize(shadowMapImage, 0));
//     for (int x = -1; x <= 1; x++) {
//         for (int y = -1; y <= 1; y++) {
//             float shadowMapPixelDist = Texel(shadowMapImage, shadowMapCoord + vec2(x, y) * texelSize).r;
//             shadow += (shadowMapPixelDist < pixelDist - bias) ? 0.0 : 1.0;
//         }
//     }
//     return shadow / 9.0; // Average of 9 samples
// }


vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 pixcoord)
{
    // IGNORE ALPHA
    vec4 texcolor = Texel(tex, texcoord);
    if (texcolor.a == 0.0) { discard; }
    texcolor = texcolor*color; //apply color

    //SMOOTH LIGHING
    vec3 n = normalize(worldNormal);
    vec3 normalColor = (n + vec3(1.0)) * 0.5; // Shift from [-1, 1] to [0, 1]
    
    vec3 lightDir = ambientVector; //Sun Light
    float diffuse = max(dot(lightDir, worldNormal), 0.0); //smooth lighting
    diffuse += ambientLightAdd;
    diffuse = clamp(diffuse, 0.0, 1.0);

    //     vec3 viewDir = normalize(cameraPosition.xyz - worldPosition.xyz);
    // // return vec4(vec3(viewDir + 1.0) * 0.5, 1.0);
    // return vec4(vec3(viewDir), 1.);

    // shadow
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
    // inShadow = (1. - PCF(shadowMapCoord, pixelDist, shadowBias));
    if (inShadow > 0.) {
        // fading out far shadow
        float maxDist = 40.;
        float fadeDist = 10.;
        float dist = sqrt((centerPoint.x - worldPosition.x) * (centerPoint.x - worldPosition.x) +
                            (centerPoint.y - worldPosition.y) * (centerPoint.y - worldPosition.y) + 
                            (centerPoint.z - worldPosition.z) * (centerPoint.z - worldPosition.z));
        dist = dist - maxDist;
        shadowFactor = dist / fadeDist;
        shadowFactor = 1. - clamp(shadowFactor, 0., 1.);
        inShadow *= shadowFactor;
    }

    //FINALIZE SHADOWS
    diffuse = min(1.0-inShadow*(1.0-ambientLight), diffuse); //shadow
    vec4 finalcolor = vec4(vec3(texcolor) * mix(shadowColor,vec3(1.0),max(diffuse, ambientLight)), 1.0);

    if (useTriplanar == true) {
        vec3 blendNormal = clamp(pow(worldNormal * 1.4, vec3(4.)), 0., 1.);
        if (worldPosition.y > yTransition) {
            // grass
            vec3 Xgrass = Texel(grassTex, worldPosition.zy / grassScale).xyz;
            vec3 Ygrass = Texel(grassTex, worldPosition.zx / grassScale).xyz;
            vec3 Zgrass = Texel(grassTex, worldPosition.xy / grassScale).xyz;
            vec3 blendedGrass = Zgrass;
            blendedGrass = mix(blendedGrass, Xgrass, blendNormal.x);
            blendedGrass = mix(blendedGrass, Ygrass, blendNormal.y);
            
            if (texcolor.r > 0.) {
                // brush
                vec3 Xbrush = Texel(brushTex, worldPosition.zy / groundScale).xyz;
                vec3 Ybrush = Texel(brushTex, worldPosition.zx / groundScale).xyz;
                vec3 Zbrush = Texel(brushTex, worldPosition.xy / groundScale).xyz;
                vec3 blendedBrush = Zbrush;
                blendedBrush = mix(blendedBrush, Xbrush, blendNormal.x);
                blendedBrush = mix(blendedBrush, Ybrush, blendNormal.y);

                vec4 finalcolor = vec4(mix(blendedGrass, blendedBrush, step(.1, texcolor.r)) * mix(shadowColor,vec3(1.0),max(diffuse, ambientLight)), 1.0);
                return finalcolor;
            } else {
                vec4 finalcolor = vec4(blendedGrass * mix(shadowColor,vec3(1.0),max(diffuse, ambientLight)), 1.0);
                return finalcolor;
            }
        } else {
            // ground
            vec3 Xground = Texel(groundTex, worldPosition.zy / groundScale).xyz;
            vec3 Yground = Texel(groundTex, worldPosition.zx / groundScale).xyz;
            vec3 Zground = Texel(groundTex, worldPosition.xy / groundScale).xyz;
            vec3 blendedGround = Zground;
            blendedGround = mix(blendedGround, Xground, blendNormal.x);
            blendedGround = mix(blendedGround, Yground, blendNormal.y);
            
            if (texcolor.r > 0.) {
                // brush
                vec3 Xbrush = Texel(brushTex, worldPosition.zy / groundScale).xyz;
                vec3 Ybrush = Texel(brushTex, worldPosition.zx / groundScale).xyz;
                vec3 Zbrush = Texel(brushTex, worldPosition.xy / groundScale).xyz;
                vec3 blendedBrush = Zbrush;
                blendedBrush = mix(blendedBrush, Xbrush, blendNormal.x);
                blendedBrush = mix(blendedBrush, Ybrush, blendNormal.y);
                
                vec4 finalcolor = vec4(mix(blendedGround, blendedBrush, texcolor.r) * mix(shadowColor,vec3(1.0),max(diffuse, ambientLight)), 1.0);
                return finalcolor;
            } else {
                vec4 finalcolor = vec4(blendedGround * mix(shadowColor,vec3(1.0),max(diffuse, ambientLight)), 1.0);
                return finalcolor;
            }
        }
    } else {
        return finalcolor;
    }
}
#endif