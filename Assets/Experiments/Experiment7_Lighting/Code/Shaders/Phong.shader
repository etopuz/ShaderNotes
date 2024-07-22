Shader "Unlit/Phong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Gloss ("Gloss", Float) = 0.5
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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float3 normalDir = normalize(i.normal);
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 cameraDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 reflected = reflect(-lightDir, normalDir);
                float3 phongSpecular = saturate(dot(reflected, cameraDir));

                phongSpecular = pow(phongSpecular, _Gloss);
                
                return float4(col+phongSpecular.xxx, 1.0);
                
                return col;
            }
            ENDCG
        }
    }
}
