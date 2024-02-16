shader_type canvas_item;


const int MAX_ITER =8;
const float TILING_FACTOR= 1.0;
const vec3 resolution=vec3(1170,2532,1110);

float waterHighlight(vec2 p, float time, float foaminess)
{
    vec2 i = vec2(p);
	float c = 0.0;
    float foaminess_factor = mix(1.0, 6.0, foaminess);
	float inten = .005 * foaminess_factor;

	for (int n = 0; n < MAX_ITER; n++) 
	{
		float t = time * (1.0 - (3.5 / float(n+1)));
		i = p + vec2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
		c += 1.0/length(vec2(p.x / (sin(i.x+t)),p.y / (cos(i.y+t))));
	}
	c = 0.2 + c / (inten * float(MAX_ITER));
	c = 1.17-pow(c, 1.4);
    c = pow(abs(c), 8.0);
	return c / sqrt(foaminess_factor);
}

uniform float water_x;
uniform float water_y;
uniform float water_z;


void fragment()
{
	vec4 color=texture(TEXTURE,UV);
	float time = TIME * 0.1+23.0;
	vec2 uv = FRAGCOORD.xy / resolution.xy;
	vec2 uv_square = vec2(uv.x * resolution.x / resolution.y, uv.y);
    float dist_center = pow(2.0*length(uv - 0.5), 2.0);
    
    float foaminess = smoothstep(0.4, 1.8, dist_center);
    float clearness = 0.1 + 0.9*smoothstep(0.1, 0.5, dist_center);
    
	vec2 p = mod(uv_square*TAU*TILING_FACTOR, TAU)-250.0;
    
    float c = waterHighlight(p, time, foaminess);
    
    vec3 water_color = vec3(0.415686, 0.662745, 0.866667);
	
	color.rgb = vec3(c);
    color.rgb = clamp(color.rgb + water_color, 0,1);
    
    color.rgb = mix(water_color, color.rgb, clearness);

	COLOR = vec4(color.rgb, 1.0);
}
//vec3 water_color = vec3(water_x,water_y,water_z);
//vec3 water_color = vec3(0.8, 0.2, 0.2);WATERMELON
//vec3 water_color = vec3(0.0, 0.35, 0.5);OG
//vec3 water_color = vec3(0.6, 0.35, 0.5);PINK
//vec3 water_color = vec3(0, 0.5, 0.5);CANDYCRUSHBLUE
//vec3 water_color = vec3(.41, .34, .79);PURPLECUSH
//vec3 water_color = vec3(.87, .84, .82)CLOUD;
////vec3 water_color = vec3(., ., .);