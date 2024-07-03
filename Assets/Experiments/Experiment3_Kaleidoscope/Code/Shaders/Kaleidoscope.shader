Shader "Unlit/Kaleidoscope"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Rotation ("Rotation", Range(0, 360)) = 0
        _Color ("Color", Color) = (1,1,1,1)
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Rotation;
            float4 _Color;

            void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
            {
                Rotation = Rotation * (UNITY_PI/180.0f);
                UV -= Center;
                float s = sin(Rotation);
                float c = cos(Rotation);
                float2x2 rMatrix = float2x2(c, -s, s, c);
                rMatrix *= 0.5;
                rMatrix += 0.5;
                rMatrix = rMatrix * 2 - 1;
                UV.xy = mul(UV.xy, rMatrix);
                UV += Center;
                Out = UV;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float u = abs(i.uv.x - 0.5); // mirror effect on u
                float v = abs(i.uv.y - 0.5); // mirror effect on v
                float rotation = _Rotation;
                float4 color = _Color;
                float center = 0.5;
                float2 uv = 0;

                Unity_Rotate_Degrees_float(float2(u,v), center, rotation, uv);
                
                fixed4 col = tex2D(_MainTex, uv);
                col *= color;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}


