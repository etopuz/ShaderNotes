Shader "Unlit/VertexGradient"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,0,1)
        _MinHeight ("Min Height", Float) = -1.0
        _MaxHeight ("Max Height", Float) = 1.0
        _GradientStrength ("Gradient Strength", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"
            "LightMode" = "ForwardBase"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertexClipSpace : SV_POSITION;
                float4 vertexObjectSpace : TEXCOORD0;
            };
            
            float4 _Color;
            float _GradientStrength;
            float _MinHeight;
            float _MaxHeight;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertexClipSpace = UnityObjectToClipPos(v.vertex);
                o.vertexObjectSpace = v.vertex;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float height = i.vertexObjectSpace.y;
                float gradient = saturate((height - _MinHeight) / (_MaxHeight - _MinHeight));
                fixed4 col = float4(_Color.xyz, 1.0);
                return float4(col.xyz * lerp(0, _GradientStrength, gradient), 1);
            }
            
            ENDCG
        }
    }
}
