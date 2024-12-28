precision highp float;

varying vec2 v_texcoord;  // Texture coordinates
uniform sampler2D tex;    // Texture sampler

void main() {
    // Get the color from the texture
    vec4 pixColor = texture2D(tex, v_texcoord);

    // Set green and blue channels to 0, keeping only the red
    vec3 color = vec3(pixColor.r, 0.0, 0.0);

    // Output the red-filtered color with the original alpha channel
    vec4 outCol = vec4(color, pixColor.a);

    gl_FragColor = outCol;
}
