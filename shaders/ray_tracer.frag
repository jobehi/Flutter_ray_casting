#include <flutter/runtime_effect.glsl>

uniform float u_time;       // Time in seconds since load
uniform vec2 u_resolution;  // Canvas size (width,height)
uniform vec2 u_mouse;       // Mouse position in pixels

out vec4 fragColor; // output colour for Flutter, like gl_FragColor

void main() {
    vec2 st = FlutterFragCoord().xy/u_resolution.xy;
    st.x *= u_resolution.x/u_resolution.y;

    vec3 color = vec3(0.);
    /// take the mouse position and use it to change the color
    /// as it wil be considered as the center of the gradient
    vec2 mouse = FlutterFragCoord().xy/u_mouse.xy;
    float dist = distance(st, mouse);
    color = vec3(mouse.x,mouse.y,abs(sin(u_time)));


    

    // return a dot depending on the position of the mouse
    float dot = smoothstep(0.01,0.0,dist);
    
    color = mix(color,vec3(1.),dot);

    fragColor = vec4(color,1.0);

}
