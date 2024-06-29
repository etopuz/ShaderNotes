Shader "Unlit/StancilMask"
{

    
    SubShader
    {
        Tags { "Queue"="Geometry-1" } // mask will be rendered first in queue
        ZWrite Off //  ZWrite should be off to see visible items behind mask
        ColorMask 0 // mask pixel are discarded in the frame buffer
        
        Stencil
        {
            Ref 2 // reference value for the stencil buffer
            Comp always // always pass the stencil test
            Pass Replace // replace the value in the stencil buffer with the reference value
        }
        

        // rest is unimportant for the mask
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return float4(0,0,0,0);
            }
            ENDCG
        }
    }
}
