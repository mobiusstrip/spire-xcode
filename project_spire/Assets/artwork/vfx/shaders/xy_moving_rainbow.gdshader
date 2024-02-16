shader_type canvas_item;

uniform sampler2D texture_input;
uniform float gradient_width = 0.2;
uniform float speed = 1.0;

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
    vec4 tex_color = texture(texture_input, UV);

    float t = TIME * speed;
    float gradient_position = 1.0 - gradient_width;
    float gradient_alpha = smoothstep(gradient_position, 1.0, UV.y);

    float hue = mod(UV.x + t, 1.0);
    vec3 rainbow_color = hsv2rgb(vec3(hue, 1.0, 1.0));

    vec4 final_color = mix(tex_color, vec4(rainbow_color, 1.0), gradient_alpha);
    COLOR = final_color;
}
