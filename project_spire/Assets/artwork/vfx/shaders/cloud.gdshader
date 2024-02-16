shader_type canvas_item;
uniform sampler2D cloud_texture : source_color;
uniform vec4 cloud_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float cloud_sharpness = 1.0;
uniform vec2 cloud_speed = vec2(0.005, 0.01);

void fragment() {
    vec2 uv = fract(UV + cloud_speed * TIME);
    vec4 tex = textureLod(cloud_texture, uv, 1.0);
    float cloud_noise = tex.r;
    vec3 final_color = mix(cloud_color.rgb, vec3(1.0), cloud_noise * cloud_sharpness);
//    COLOR = vec4(final_color, tex.a);
	COLOR = vec4(final_color, tex.a * cloud_color.a); // Multiply alpha for opacity
}