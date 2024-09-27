#include <flutter/runtime_effect.glsl>

uniform float u_time;       // Time in seconds since load
uniform vec2 u_resolution;  // Canvas size (width,height)

out vec4 fragColor; // output colour for Flutter, like gl_FragColor

void main() {
    vec2 st = FlutterFragCoord().xy/u_resolution.xy;
    st.x *= u_resolution.x/u_resolution.y;

    vec3 color = vec3(0.);
    color = vec3(st.x,st.y,abs(sin(u_time)));

    fragColor = vec4(color,1.0);
}
