Shader "Unlit/RayMarchLavaLamp"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR] _BottomColor ("BottomColor", Color) = (1,1,1,1)
        [HDR] _TopColor ("TopColor", Color) = (1,1,1,1)
        _BubbleScaleFactor ("Bubble Scale Factor", Float) = 0.1
        _BottomBubblePos ("Bottom Bubble Position", Vector) = (0, 0, 0)
        _BubbleMaxPos ("Bubble Max Pos", Vector) = (0.2, 0.6, 0.2)
        _BubbleMinPos ("Bubble Min Pos", Vector) = (-0.2, -1.4, -0.2)
        _BubbleTestPos ("Bubble Test Pos", Vector) = (0, 0, 0)
        _GradientYRange ("Gradient Y Range", Vector) = (0, 1, 0, 1) 
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" }
        ZWrite On
        ZTest Less
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _BottomColor;
            float4 _TopColor;
            float3 _BottomBubblePos;
            float3 _BubbleMaxPos;
            float3 _BubbleMinPos;
            float3 _BubbleTestPos;
            float2 _GradientYRange;
            float _BubbleScaleFactor;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
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

            float4 invLerp(float4 from, float4 to, float4 value){
                return (value - from) / (to - from);
            }
            
            float Bubble(float3 p, float2 xyPos, float scale,  float delay, float multiplier, bool isReversed)
            {
                float posScaler = 0.25f;
                float timeRemapped = sin(_Time.y * multiplier + delay) * 0.5 + 0.5;
                if (isReversed)
                {
                    timeRemapped = 1 - timeRemapped;
                }
                float yPositionBubble1 = lerp(_BubbleMinPos.y, _BubbleMaxPos.y, timeRemapped) * posScaler;
                float bubble = sdSphere(p, float3(xyPos.x ,yPositionBubble1, xyPos.x) , scale * _BubbleScaleFactor);
                return bubble;
            }
            
            
            float mapTheWorld(in float3 p)
            {
                p -= unity_ObjectToWorld._m03_m13_m23;

                float bottomBigSphere = sdSphere(p, float3(0, -0.425, 0), 1.5 * _BubbleScaleFactor);
                
                float bubble1 = Bubble(p, float2(0,0),0.25 ,0, 0.2, false);
                float bubble2 = Bubble(p, float2(0.05, 0), 0.17, 60, 0.3, true);
                float bubble3 = Bubble(p, float2(-0.06, 0), 0.19, 15, 0.4, false);
                float bubble4 = Bubble(p, float2(0.02, 0.05), 0.23, 90, 0.15, true);

                float b1ub2 = smoothUnion(bubble1, bubble2, 0.13);
                float b3ub4 = smoothUnion(bubble3, bubble4, 0.15);

                float allBubbles = smoothUnion(b1ub2, b3ub4, 0.15);
                return smoothUnion(bottomBigSphere, allBubbles, 0.25);
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



            float4 rayMarch(in float3 ray_origin, in float3 ray_distance)
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
                        float lerpY = invLerp(_GradientYRange.x, _GradientYRange.y, current_position.y);
                        float4 gradient = lerp(_BottomColor, _TopColor, lerpY);
                        
                        return gradient;
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
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 camera_pos = _WorldSpaceCameraPos;
                float3 ray_direction = normalize(i.worldPos - camera_pos);
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
