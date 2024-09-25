Shader "Unlit/UV_Distortion"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Noise ("Noise", 2D) = "white" {}
        _AnimationSpeed ("Speed", Float) = 1
        _DistortionStrength ("DistortionStrength", Range(0, 1)) = 1
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _Noise;
            float4 _MainTex_ST;
            float _AnimationSpeed;
            float _DistortionStrength;

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
                float speed = _AnimationSpeed * _Time;
                float2 distortion_uv = speed.xx + i.uv;
                fixed2 distortion = (tex2D(_Noise, distortion_uv) * 2 - 1) * _DistortionStrength;
                fixed4 col = tex2D(_MainTex, i.uv + distortion);
                return col;
            }
            ENDCG
        }
    }
}
