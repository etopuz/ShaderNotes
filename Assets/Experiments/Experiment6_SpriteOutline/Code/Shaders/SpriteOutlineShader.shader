Shader "Unlit/SpriteOutlineShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        [Header(Outline)]
        [Space(10)]
        [Toggle(OUTLINE_ENABLED)] _OutlineEnabled ("Enabled", Float) = 1
        _OutlineColor ("Color", Color) = (1,1,1,1)
        _OutlineWidth ("Width", Range(0.1,1) ) = 0.1
    }
    SubShader
    {
        Tags {
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        
        Blend SrcAlpha OneMinusSrcAlpha
        
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature OUTLINE_ENABLED

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
            float4 _OutlineColor;
            float _OutlineWidth;
            float _OutLineEnabled;

            float remap(float value, float min1, float max1, float min2, float max2)
            {
                float perc = (value - min1) / (max1 - min1);
                return (perc * (max2 - min2) + min2);
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
                float snappedWidth = remap(_OutlineWidth, 0.1, 1, 0.001, 0.003);
                fixed4 mainColor = tex2D(_MainTex, i.uv);
                
                #ifndef OUTLINE_ENABLED
                    return mainColor;
                #endif
                
                fixed4 outline = tex2D(_MainTex, float2(i.uv.x + snappedWidth, i.uv.y));
                outline += tex2D(_MainTex, float2(i.uv.x, i.uv.y + + snappedWidth));
                outline += tex2D(_MainTex, float2(i.uv.x - snappedWidth, i.uv.y));
                outline += tex2D(_MainTex, float2(i.uv.x, i.uv.y- snappedWidth));

                return step(0.001, outline.a) * _OutlineColor * (step(0.99, 1 - mainColor.a)) + mainColor;

                /*outline *= step(0.9999, 1 - mainColor);
                outline = step(0.001, outline.a);
                
                
                return (outline * _OutlineColor + mainColor);*/

            }

            
            ENDCG
        }
        
/*        Pass
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
            float4 _Color;
            float _Width;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 mainColor = tex2D(_MainTex, i.uv);
                return mainColor;
                
                // return mainColor;
            }

            
            ENDCG
        }*/

       
    }
}
