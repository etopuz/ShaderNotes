Shader "Unlit/SimpleHealthBar"
{
    Properties
    {
        _Health ("Health",  Range(0,1)) = 1
        
        [Header(Start)]
        _StartColor ("StartColor", Color) = (1,0,0,1)
        _StartThreshold ("StartThreshold", Range(0, 1)) = 0.2
        
        [Header(End)]
        _EndColor ("EndColor", Color) = (0,1,0,1)
        _EndThreshold ("EndThreshold", Range(0, 1)) = 0.8
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
            
            fixed4 _StartColor;
            fixed4 _EndColor;
            float _Health;
            float _StartThreshold;
            float _EndThreshold;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float weight = (_Health < _StartThreshold) ? 0 : _Health;
                weight = (_Health > _EndThreshold) ? 1 : weight;
                fixed4 color = lerp(_StartColor, _EndColor, weight) * (i.uv.x < _Health);
                return color;
            }
            
            ENDCG
        }
    }
}
