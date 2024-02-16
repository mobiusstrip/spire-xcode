shader_type canvas_item;

// Shader uniform parameters
uniform sampler2D flag_texture;
uniform float wave_amplitude: hint_range(0.0, 1.0) = 0.1;
uniform float wave_frequency: hint_range(0.0, 10.0) = 2.0;
uniform float wave_speed: hint_range(-10.0, 10.0) = 2.0;
uniform float fixed_edge: hint_range(0.0, 1.0) = 0.1;

void vertex() {
    float time = TIME * wave_speed;
    float fixed_edge_position = fixed_edge;

    if (UV.x > fixed_edge_position) {
        float wave = sin((UV.x - fixed_edge_position) * wave_frequency * 3.14159 + time);
        VERTEX.y += wave_amplitude * wave;
    }
}

void fragment() {
    vec2 modified_uv = UV;
    float time = TIME * wave_speed;
    float fixed_edge_position = fixed_edge;

    if (modified_uv.x > fixed_edge_position) {
        float wave = sin((modified_uv.x - fixed_edge_position) * wave_frequency * 3.14159 + time);
        modified_uv.y -= wave_amplitude * wave;
    }

    COLOR = texture(flag_texture, modified_uv);
}
