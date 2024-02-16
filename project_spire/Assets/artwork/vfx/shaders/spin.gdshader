shader_type canvas_item;

uniform sampler2D circle_texture;
uniform float rotation_speed = 1.0; // Rotation speed (in radians per second)

varying float currentTime;

void fragment() {
	vec2 uv = VERTEX;
	uv = (UV - vec2(0.5, 0.5)) * 2.0;

	// Get the current time
	currentTime = TIME * rotation_speed;

	// Rotate the texture around the Y-axis
	mat2 rotation_matrix = mat2(vec2(cos(currentTime), -sin(currentTime)),vec2(sin(currentTime), cos(currentTime)));
	vec2 rotated_uv = rotation_matrix * uv;

	// Remap the UV coordinates back to the [0, 1] range
	rotated_uv = rotated_uv * 0.5 + vec2(0.5, 0.5);

	vec4 color = texture(circle_texture, rotated_uv);
	
	// Apply the texture color to the output
	COLOR = color;
}
