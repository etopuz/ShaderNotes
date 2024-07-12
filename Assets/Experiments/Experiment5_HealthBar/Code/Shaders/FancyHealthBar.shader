Shader "Unlit/FancyHealthBar"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Health ("Health", Range(0, 1)) = 1
        _BorderSize ("Border Size", Range(0, 0.2)) = 0.1
        _BorderColor ("Border Color", Color) = (0,0,0,1)
        _PulsateHealth ("Pulsate Health", Range(0, 1)) = 0.25
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
            float4 _MainTex_ST;
            float _Health;
            float _BorderSize;
            float4 _BorderColor;
            float _PulsateHealth;

            static float _circleRadius = 0.5;
            static float xyRatio = length(unity_ObjectToWorld._m00_m10_m20) / length(unity_ObjectToWorld._m01_m11_m21); 
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 pulsate(fixed4 col )
            {
                return col + 0.1 * sin(_Time.y * 5);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 strechedUV = i.uv;
                strechedUV.x *= (xyRatio); // strech uv with xy ratio
                
                float2 lCenter = float2(_circleRadius, _circleRadius);
                float2 rCenter = float2(xyRatio-_circleRadius, _circleRadius);

                float leftCircleOut = (_circleRadius - distance(lCenter, strechedUV)) * (strechedUV.x<lCenter.x); // left out of left circle
                float righCircleOut = (_circleRadius - distance(rCenter, strechedUV)) * (strechedUV.x>rCenter.x); // right out of right circle

                float isBorder = (abs(strechedUV.y * 2 - 1) > 1 - _BorderSize); // add upper and lower lines to border
                isBorder += (distance(lCenter, strechedUV)> _circleRadius - _BorderSize/2) * (strechedUV.x<lCenter.x); // add left arc to border
                isBorder += (distance(rCenter, strechedUV)> _circleRadius - _BorderSize/2) * (strechedUV.x>rCenter.x); // add right arc to border

                // discard pixels outside of the border
                clip(leftCircleOut);
                clip(righCircleOut);
                
                if(isBorder)
                {
                    return _BorderColor;
                }

                // discard pixels on the bar that shows damaged part
                clip(_Health - i.uv.x);

                // get color from texture, and assign color based on x of the texture
                fixed4 col = tex2D(_MainTex, float2(_Health, i.uv.y)); 

                if(_Health < _PulsateHealth)
                {
                    col = pulsate(col);
                }
                
                return col;
            }
            ENDCG
        }
    }
}
