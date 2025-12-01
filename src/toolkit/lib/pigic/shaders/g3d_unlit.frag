varying vec4 worldPosition;
varying vec4 viewPosition;
varying vec4 screenPosition;
varying vec3 vertexNormal;
varying vec4 vertexColor;



vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 pixcoord) {
    vec4 texcolor = Texel(tex, texcoord);
    
    // get rid of transparent pixels
    if (texcolor.a == 0.0) {
        discard;
    }
    return texcolor * color;
}