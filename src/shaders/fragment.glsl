uniform vec4 resolution; 
uniform float uTime; 
varying vec2 vUv; 
uniform sampler2D uTexture; 
uniform vec3 uPositions[7]; 
uniform float uRadius[7]; 
uniform float uMotion[7]; 
float PI = 3.14159;

vec2 getMapcap(vec3 eye, vec3 normal) {
  vec3 reflected = reflect(eye, normal);
  float m = 2.8284271247461903 * sqrt( reflected.z+1.0 );
  return reflected.xy / m + 0.5;
}

float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

float sdSphere(vec3 p, float r) {
    return length(p)-r;
}

float sdf(vec3 p) {
    float wave = sin(uTime) * 0.5 + 0.5;

    float d = 1.0; 
    

     for(int i = 0; i < 7; i++) {
        float motion = wave * uMotion[i]; 
        vec3 offset = vec3(uPositions[i].x, uPositions[i].y + motion, uPositions[i].z); 
        float s = sdSphere(p + offset, uRadius[i]);  
        d = smin(d, s, 0.5);  
     }

    return d;
}

vec3 calcNormal(vec3 p){
    float eps = 0.0001; // or some other value
    vec2 h = vec2(eps,0);
    return normalize( vec3(sdf(p+h.xyy) - sdf(p-h.xyy),
                           sdf(p+h.yxy) - sdf(p-h.yxy),
                           sdf(p+h.yyx) - sdf(p-h.yyx) ) );
}

void main() {
    vec2 newUV = (vUv - vec2(0.5))*resolution.zw + vec2(0.5); 
    vec3 camPos = vec3(0.0, 0.0, 2.0); 
    vec3 ray = normalize(vec3((vUv - vec2(0.5))*resolution.zw, -1)); 

    vec3 rayPos = camPos; 
    float t = 0.0; 
    float tMax = 10.0; 

    for(int i = 0; i < 56; i++) {        
        vec3 pos = camPos + t*ray; 
        float h = sdf(pos); 
        if(h < 0.0001 || t > tMax) break; 
        t += h;
    }

    vec4 color = vec4(0.0); 

    if(t < tMax) {
        vec3 pos = camPos + t*ray;
      
        vec3 normal = calcNormal(pos);

        float diff = dot(vec3(1.0), normal); 
        vec2 matcapUV = getMapcap(ray, normal);

        color = texture2D(uTexture, matcapUV);

        float fresnel = pow(1.0 + dot(ray, normal), 1.0); 

        color = mix(color, vec4(1.0, 0.8, 0.6, 1.0), fresnel);
    }

    gl_FragColor = color; 
}

