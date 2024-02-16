shader_type canvas_item;

uniform sampler2D inputTexture;
uniform float offsetXScale : hint_range(-2.0, 2.0) = 0.5;
uniform float offsetYScale : hint_range(-2.0, 2.0) = 0.5;
uniform vec2 rectSize;

void fragment() {
    vec2 aspectRatio = rectSize / max(rectSize.x, rectSize.y);
    vec2 uv = 1.5 * (2.0 * UV * aspectRatio - aspectRatio);
    vec2 offset = vec2(cos(TIME / 2.0) * offsetXScale, sin(TIME / 2.0) * offsetYScale);

    vec3 light_color = vec3(0.9, 0.65, 0.5);
    float light = 0.1 / distance(normalize(uv), uv);

    if (length(uv) < 1.0) {
        light *= 0.1 / distance(normalize(uv - offset), uv - offset);
    }

    vec4 sampledTexture = texture(inputTexture, UV);
    COLOR = vec4(light * light_color * sampledTexture.rgb, sampledTexture.a);
}
