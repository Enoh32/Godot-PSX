shader_type spatial; 
render_mode skip_vertex_transform, cull_disabled, diffuse_lambert, specular_disabled, vertex_lighting;

uniform vec4 tint_color : hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D diffuse_tex : hint_albedo;
uniform float speed : hint_range(0.5, 8.0) = 1.5;
uniform float shade_strength : hint_range(0.0, 1.0) = 0.25;
uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 uv_offset = vec2(0.0, 0.0);

const float WAVE_AMP = 1.0/8.0;
varying float shading;

const float cull_far = 32.0;
// Uncomment for fixed-res snapping
//const vec2 resolution = vec2(160.0, 120.0);

void vertex() {
	UV = UV * uv_scale + uv_offset;
	
	// Comment for fixed-res snapping
	vec2 resolution = VIEWPORT_SIZE * 0.5;
	
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	NORMAL = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	
	// Deform
	vec3 v_world = (CAMERA_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float wave_speed = TIME * speed;
	vec2 deform = vec2(sin(v_world.z+wave_speed), sin(v_world.x+wave_speed));
	v_world.xz += deform * WAVE_AMP;
	VERTEX = (INV_CAMERA_MATRIX * vec4(v_world, 1.0)).xyz;
	
	// Shading
	float l = length(deform);
	shading = mix(1.0, l * l, shade_strength);
	
	vec4 v = (PROJECTION_MATRIX * vec4(VERTEX, 1.0));
	v.xy = v.w * round(resolution * v.xy / v.w) / resolution;
	VERTEX = (INV_PROJECTION_MATRIX * v).xyz;
	
	//Affine texture-mapping
	UV *= VERTEX.z;
	
	// Culling
	float vdepth = -VERTEX.z;
	if(vdepth < 0.0 || vdepth > cull_far){
		VERTEX = vec3(0.0);
	}
}

void fragment() {
	vec4 tex = texture(diffuse_tex, UV / VERTEX.z);
	
	// DITHER TRANSPARENCY
	ALPHA = mod(FRAGCOORD.x+FRAGCOORD.y, 2.0);
	ALPHA_SCISSOR = 0.5;
	
	ALBEDO = tex.rgb * tint_color.rgb * shading;
}