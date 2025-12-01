varying vec4 worldPosition;
varying vec4 viewPosition;
varying vec4 screenPosition;
varying vec3 vertexNormal;
varying vec4 vertexColor;


vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords)
{
    // Normalize the vertex normal (in case it's not already normalized)
    vec3 normal = normalize(vertexNormal);
    // Map the normal's XYZ components to RGB color
    vec3 normalColor = (normal + vec3(1.0)) * 0.5; // Shift from [-1, 1] to [0, 1]
    // Output the color based on the normal
    return vec4(normalColor, 1.0);
}

