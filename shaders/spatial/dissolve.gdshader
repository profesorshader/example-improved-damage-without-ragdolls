shader_type spatial;
//render_mode unshaded;

uniform float t = 0.0; // animation 0 = start, 1 = end
uniform vec3 color_base : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 color_edge : source_color = vec3(1.0, 0.0, 0.0);
uniform float edge_size = 0.025;

uniform sampler2D noise_tex;
uniform float noise_scale = 1.0;

uniform vec3 axis = vec3(0.0, 1.0, 0.0);

varying vec3 local_nrm;

void vertex() {
	local_nrm = NORMAL;
}

void fragment() {
	// get value based on dot product against normal
	float d = dot(local_nrm, axis); // value from -1 to 1	
	d = clamp((d + 1.0) * 0.5, 0.0, 1.0); // convert to 0 to 1
	
	// add UV based noise
	float noise = texture(noise_tex, UV * noise_scale).r;
	float value = d + noise; // value from 1 to 2
	value = clamp(value * 0.5, 0.0, 1.0); // convert to 0 to 1
	
	if (value < t)
		discard;
		
	value = smoothstep(t, 1.0, value); // (re)convert to 0 to 1	
		
	float mix_val = smoothstep(0.0, edge_size, value);
	
	ALBEDO = vec3(0.0);
	EMISSION = mix(color_edge, color_base, mix_val); 
}
