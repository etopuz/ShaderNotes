Shader "Unlit/RayMarch4Spheres"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float sdSphere(in float3 p, in float3 c, float r)
            {
	            return length(p - c) - r;
            }

            float sdBox(in float3 p, in float3 b)
            {
                float3 d = abs(p) - b;
                return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
            }

            float2x2 rotate2d(float angle)
            {
                float s = sin(angle);
                float c = cos(angle);

                return float2x2(
                    c, -s, 
                    s,  c
                );
            }
            
            float smoothUnion(float d1, float d2, float k)
            {
                float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
                return lerp(d2, d1, h) - k * h * (1.0 - h);
            }

            
            float mapTheWorld(in float3 p)
            {
                float displacement = sin(10 * p.x) * cos(10 * p.y) * sin(10 * p.z) * _SinTime.w * 0.05;

                float sphereMaxGo = 5;
                float sphereMoveSpeed = 1.5;
                float sphereAnimPos = sin(_Time.y * sphereMoveSpeed) * sphereMaxGo;
                float r = 1.5f;
   
                float sphere_0 = sdSphere(p, float3(sphereAnimPos,0,0), r);
                float sphere_1 = sdSphere(p, -float3(sphereAnimPos,0,0), r);
                float sphere_2 = sdSphere(p, float3(0,sphereAnimPos,0), r);
                float sphere_3 = sdSphere(p, -float3(0,sphereAnimPos,0), r);
                
                float union1 = smoothUnion(sphere_0, sphere_1, 2);
                float union2 = smoothUnion(sphere_2, sphere_3, 2);
                float union3 = smoothUnion(union1, union2, 1);
                
                return union3 + displacement;
            }

            float3 getNormal(in float3 p)
            {
                const float e = 0.001;
                float3 normal = float3(
                    mapTheWorld(p + float3(e, 0, 0)) - mapTheWorld(p - float3(e, 0, 0)),
                    mapTheWorld(p + float3(0, e, 0)) - mapTheWorld(p - float3(0, e, 0)),
                    mapTheWorld(p + float3(0, 0, e)) - mapTheWorld(p - float3(0, 0, e))
                );

                return normalize(normal);
            }

            float3 rayMarch(in float3 ray_origin, in float3 ray_distance)
            {
                float distance_traveled = 0.0;

                const int NUMBER_OF_STEPS = 32;
                const float MINIMUM_HIT_DISTANCE = 0.001;
                const float MAXIMUM_TRACE_DISTANCE = 100.0;

                for (int i = 0; i < NUMBER_OF_STEPS; ++i)
                {
                    float3 current_position = ray_origin + distance_traveled * ray_distance;
                    float distance_to_closest = mapTheWorld(current_position);

                    if (distance_to_closest < MINIMUM_HIT_DISTANCE)
                    {
                        float3 normal = getNormal(current_position);
                        float diffuse = max(0, dot(normal, _WorldSpaceLightPos0));
                        return abs(ray_distance * 2) * diffuse;
                    }
                    
                    if (distance_traveled > MAXIMUM_TRACE_DISTANCE) 
                    {
                        break;
                    }
                    
                    distance_traveled += distance_to_closest;
                }
                
                return -1;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv_remap = i.uv * 2.0 - 1.0;
                float3 camera_pos = _WorldSpaceCameraPos;
                float3 ray_direction = normalize(float3(uv_remap, 1));
                float3 color = rayMarch(camera_pos, ray_direction);
                
                if (color.x == -1)
                {
                    discard;
                }
                
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
