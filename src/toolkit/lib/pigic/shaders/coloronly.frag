vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 pixcoord)
{			
    vec4 texcolor = Texel(tex, texcoord);
    if (texcolor.a == 0.0) { discard; };

    return color;
}