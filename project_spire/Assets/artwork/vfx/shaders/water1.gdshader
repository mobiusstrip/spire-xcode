shader_type canvas_item;
uniform float water_level;
uniform vec3 waterColor;

float WaveMask(vec2 uv, float h, float t, float i) {
    vec2 st = uv;
    st.x += t;
    st.y=1.0-st.y;
    st.y +=-(sin(st.x*10.)*.5+.5)*i;

    float softness = 0.1; //def 0.001
    float c = smoothstep(h+softness, h ,st.y);
    return c;
}

float WaterMask(vec2 uv, float h, float t, float i) {
   float waterMask1 = WaveMask(uv, h, t*.4, i*0.05);
    float waterMask2 = WaveMask(uv, h, -t*.3, i*0.05);
    float waterMask3 = WaveMask(uv, h, t*.5, i*0.05);

    float waterMask = mix(waterMask1, waterMask2, .5);
    waterMask = mix(waterMask, waterMask3, .5);
    return waterMask;
}

void fragment()
{
    // UV.y = -UV.y
    vec2 uv = FRAGCOORD.xy/(1.0/SCREEN_PIXEL_SIZE.xy);
    
    float h = water_level;
    h *= 1.2;
  
    float o1 = sin(TIME*2.)*0.01;
    float o2 = sin(TIME*.1)*0.01;
    float o3 = sin(TIME)*0.01;
    
    float w1 = WaterMask(uv*vec2(1.,1.), o1+h-0.15, TIME, 1.);
    float w2 = WaterMask(uv*vec2(2.,1.), o2+h-0.06, TIME*.5, 0.8);
    float w3 = WaterMask(uv*vec2(3.,1.), o3+h, TIME*.3, 0.5);

    float w = mix(w1, w2,1);
    w = mix(w, w3, 2);

    COLOR = vec4(w * waterColor, w);
}

//.72 .65 .84 ccpurple
//.08 .65 .84 ccblue