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
uniform bool useShadow;

uniform Image groundTex;
uniform Image grassTex;
uniform Image brushTex;
uniform float _grassSpread = .1;
uniform float groundScale = 1.;
uniform float grassScale = 1.;

uniform bool useTriplanar;


vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 pixcoord)
{
    // // IGNORE ALPHA
    vec4 texcolor = Texel(tex, texcoord);
    if (texcolor.a == 0.0) { discard; }
    

    //STEPPED LIGHING (Cel Shading)
    vec3 n = normalize(worldNormal);
    vec3 normalColor = (n + vec3(1.0)) * 0.5; // Shift from [-1, 1] to [0, 1]
    
    vec3 lightDir = ambientVector; //Sun Light
    float diffuse = max(dot(lightDir, worldNormal), 0.0); //smooth lighting
    // Cel shading step function
    diffuse += ambientLightAdd;
    diffuse = clamp(diffuse, 0.0, 1.0);
    float levels = 3.; // Number of shading levels
    diffuse = floor(diffuse * levels) / levels;
    // shadow
    float angleFactor = max(0.0, 1.0 - dot(worldNormal, shadowMapDir)); // Approximation of angle effect
    float shadowBias = shadowBiasStrength * angleFactor;
    shadowBias = clamp(shadowBias, 0.0, 0.01);

    float pixelDist = (project.z-shadowBias)/project.w; //How far this pixel is from the camera
    vec2 shadowMapCoord = ((project.xy)/project.w); //Where this vertex is on the shadowMap
    float shadowMapPixelDist;
    float inShadow;

    //SHADOW SMOOTHING
    shadowMapPixelDist = Texel(shadowMapImage, shadowMapCoord).r;
    inShadow = mix(float(shadowMapPixelDist < pixelDist),0.0,1.0-float((shadowMapCoord.x >= 0.0) && (shadowMapCoord.y >= 0.0) && (shadowMapCoord.x <= 1.0) && (shadowMapCoord.y <= 1.0))); //0.0;

    //FINALIZE SHADOWS
    diffuse = min(1.0-inShadow*(1.0-ambientLight), diffuse); //shadow
    vec4 finalcolor = vec4(vec3(texcolor) * mix(shadowColor,vec3(1.0),max(diffuse, ambientLight)), 1.0);

    if (useTriplanar == true) {
        vec3 blendNormal = clamp(pow(worldNormal * 1.4, vec3(4.)), 0., 1.);

        // ground
        vec3 Xground = Texel(groundTex, worldPosition.zy / groundScale).xyz;
        vec3 Yground = Texel(groundTex, worldPosition.zx / groundScale).xyz;
        vec3 Zground = Texel(groundTex, worldPosition.xy / groundScale).xyz;
        vec3 blendedGround = Zground;
        blendedGround = mix(blendedGround, Xground, blendNormal.x);
        blendedGround = mix(blendedGround, Yground, blendNormal.y);
        // grass
        vec3 Xgrass = Texel(grassTex, worldPosition.zy / grassScale).xyz;
        vec3 Ygrass = Texel(grassTex, worldPosition.zx / grassScale).xyz;
        vec3 Zgrass = Texel(grassTex, worldPosition.xy / grassScale).xyz;
        vec3 blendedGrass = Zgrass;
        blendedGrass = mix(blendedGrass, Xgrass, blendNormal.x);
        blendedGrass = mix(blendedGrass, Ygrass, blendNormal.y);
        // brush
        vec3 Xbrush = Texel(brushTex, worldPosition.zy / groundScale).xyz;
        vec3 Ybrush = Texel(brushTex, worldPosition.zx / groundScale).xyz;
        vec3 Zbrush = Texel(brushTex, worldPosition.xy / groundScale).xyz;
        vec3 blendedBrush = Zbrush;
        blendedBrush = mix(blendedBrush, Xbrush, blendNormal.x);
        blendedBrush = mix(blendedBrush, Ybrush, blendNormal.y);

        // return vec4(vec3((dot(vertexNormal.xyz, vec3(worldNormal.y))<(-.3))), 1.);
        if (dot(vertexNormal.xyz, vec3(worldNormal.y)) >= _grassSpread) {
            if (texcolor.r < 1.) {
                vec4 finalcolor = vec4(mix(blendedGrass, blendedBrush, 1.-texcolor.r) * mix(shadowColor,vec3(1.0),max(diffuse, ambientLight)), 1.0);
                return finalcolor;
            } else {
                vec4 finalcolor = vec4(blendedGrass * mix(shadowColor,vec3(1.0),max(diffuse, ambientLight)), 1.0);
                return finalcolor;
            }
        } else {
            if (texcolor.r < 1.) {
                vec4 finalcolor = vec4(mix(blendedGround, blendedBrush, 1.-texcolor.r) * mix(shadowColor,vec3(1.0),max(diffuse, ambientLight)), 1.0);
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