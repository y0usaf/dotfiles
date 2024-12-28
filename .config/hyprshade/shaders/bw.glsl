
precision highp float;

varying vec2 v_texcoord;  // Texture coordinates
uniform sampler2D tex;    // Texture sampler

void main() {
    // Get the color from the texture
    vec4 pixColor = texture2D(tex, v_texcoord);

    // Calculate the grayscale luminance using weighted values for RGB
    float gray = dot(pixColor.rgb, vec3(0.299, 0.587, 0.114));

    // Output the grayscale color, keeping the original alpha channel
    vec4 outCol = vec4(vec3(gray), pixColor.a);

    gl_FragColor = outCol;
}
