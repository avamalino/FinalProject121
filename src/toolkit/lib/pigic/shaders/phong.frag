varying vec4 worldPosition;
varying vec4 viewPosition;
varying vec4 screenPosition;
varying vec3 vertexNormal;
varying vec4 vertexColor;

uniform vec3 ambientVector;
uniform float ambientLight;
uniform float ambientLightAdd;
vec3 shadowColor = vec3(0.0,0.2,0.6);


vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 pixcoord) {
    vec4 texcolor = Texel(tex, texcoord);
    texcolor = texcolor*color; //apply color
    
    // get rid of transparent pixels
    if (texcolor.a == 0.0) {
        discard;
    }

    //SMOOTH LIGHING (Phong Shading)
    vec3 lightDir = ambientVector; //Sun Light
    float diffuse = max(dot(lightDir, vertexNormal), 0.0) + ambientLightAdd; //smooth lighting
    diffuse = clamp(diffuse, 0.0, 1.0);

    //FINALIZE SHADOWS
    vec4 finalcolor = vec4(vec3(texcolor) * mix(shadowColor, vec3(1.0), max(diffuse, ambientLight)), 1.0);
    return finalcolor;
}