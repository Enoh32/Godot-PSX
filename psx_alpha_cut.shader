shader_type spatial; 
render_mode skip_vertex_transform, cull_disabled, diffuse_lambert, specular_disabled, vertex_lighting;

uniform vec4 tint_color : hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D diffuse_tex : hint_albedo;

uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 uv_offset = vec2(0.0, 0.0);

const float cull_far = 32.0;
// Uncomment for fixed-res snapping
//const vec2 resolution = vec2(160.0, 120.0);

void vertex() {
	UV = UV * uv_scale + uv_offset;
	
	// Comment for fixed-res snapping
	vec2 resolution = VIEWPORT_SIZE * 0.5;
	
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	NORMAL = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	
	vec4 v = (PROJECTION_MATRIX * vec4(VERTEX, 1.0));
	v.xy = v.w * round(resolution * v.xy / v.w) / resolution;
	VERTEX = (INV_PROJECTION_MATRIX * v).xyz;
	
	// Affine texture-mapping
	UV *= VERTEX.z;
	
	// Culling
	float vdepth = -VERTEX.z;
	if(vdepth < 0.0 || vdepth > cull_far){
		VERTEX = vec3(0.0);
	}
	vdepth = round(vdepth * 8.0)/8.0;
}

void fragment() {
	vec4 tex = texture(diffuse_tex, UV / VERTEX.z);
	ALBEDO = tex.rgb * COLOR.rgb * tint_color.rgb;
	ALPHA = tex.a;
	ALPHA_SCISSOR = 0.5;
	
	SPECULAR = 0.0;
	ROUGHNESS = 1.0;
	METALLIC = 0.0;
}