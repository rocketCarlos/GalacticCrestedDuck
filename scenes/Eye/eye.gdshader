shader_type canvas_item;

// Controla si el efecto de evaporación está activo
uniform bool enabled = false;

// Controla el progreso de la evaporación (0.0 a 1.0)
uniform float progress : hint_range(0.0, 1.0);

void fragment() {
    // Obtener el color original del sprite
    vec4 sprite_color = texture(TEXTURE, UV);

    // Solo procesar si está activado
    if (enabled){
		// Si el alfa del color es muy bajo, descártalo
	    if (sprite_color.a < 0.01) {
	        discard;
	    }

	    // Genera un valor aleatorio basado en la posición UV
	    float randomness = fract(sin(dot(UV, vec2(12.9898, 78.233))) * 43758.5453);

	    // Calcula el umbral de evaporación basado en el progreso
	    float threshold = progress + randomness * 0.2;

	    // Si el progreso es menor al umbral, descarta este píxel
	    if (threshold > 1.0) {
	        discard;
	    }

	    // Desplazamiento hacia arriba (evaporación)
	    float offset_y = progress * randomness * 0.50;

	    // Limita el desplazamiento a regiones válidas del sprite
	    vec2 displaced_uv = UV + vec2(0.0, offset_y);
	    if (displaced_uv.y < 0.0 || displaced_uv.y > 1.0) {
	        discard;
	    }

	    // Muestra el color desplazado (si está dentro del área válida)
	    vec4 offset_color = texture(TEXTURE, displaced_uv);

	    // Mezcla el color original con rojo antes de desaparecer
	    vec3 red_tint = mix(offset_color.rgb, vec3(1.0, 0.0, 0.0), progress);

	    // Aplica un desvanecimiento gradual al alfa
	    float final_alpha = offset_color.a * (1.0 - progress);

	    // Descarta píxeles con alfa muy bajo para evitar residuos
	    if (final_alpha < 0.01) {
	        discard;
	    }

	    // Define el color final
	    COLOR = vec4(red_tint, final_alpha);
			
		}
}
