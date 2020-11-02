shader_type spatial; 
render_mode skip_vertex_transform, diffuse_lambert, specular_disabled, vertex_lighting;

uniform vec4 tint_color : hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D diffuse_tex : hint_albedo;

const float cull_dist = 16.0;

uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 uv_offset = vec2(0.0, 0.0);
varying vec4 vertex_coordinates;

void vertex() {
	UV = UV * uv_scale + uv_offset;
	vec2 resolution = VIEWPORT_SIZE * 0.5;
	
	float vertex_distance = length((MODELVIEW_MATRIX * vec4(VERTEX, 1.0)));
	
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	NORMAL = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	
	float vPos_w = (PROJECTION_MATRIX * vec4(VERTEX, 1.0)).w;
	VERTEX.xy = vPos_w * round(resolution * VERTEX.xy / vPos_w) / resolution;
	
	float vz = VERTEX.z;
	vertex_coordinates = vec4(UV * vz, vz, .0);
	
	if(vertex_distance >= cull_dist){
		VERTEX = vec3(0.0);
	}
}

void fragment() {
	vec2 vc = vertex_coordinates.xy / vertex_coordinates.z;
	vec4 tex = texture(diffuse_tex, vc);
	
	ALBEDO = tex.rgb * COLOR.rgb * tint_color.rgb;
}