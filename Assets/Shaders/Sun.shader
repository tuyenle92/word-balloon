Shader "Custom/Sun"
{
    Properties
    {
        _SunColor ("Sun Color", Color) = (1.0, 0.992, 0.949, 1.0)
         _EdgeSoftness ("Edge Softness", Range(0.001,0.1)) = 0.01
        _GlowColor ("Glow Color", Color) = (1.0, 0.902, 0.651, 1.0)
        _GlowStrength ("Glow Strength", Range(0, 1)) = 0.5
        _GlowFalloff ("Glow Falloff", Range(1, 50)) = 15.0
        _SunRadius ("Sun Radius", Range(0.01, 0.4)) = 0.15
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
        } 

        Pass
        {
            Cull Off
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _SunColor;
                float _EdgeSoftness;
                float4 _GlowColor;
                float _GlowStrength;
                float _GlowFalloff;
                float _SunRadius;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float4 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            float Circle(float2 p, float2 c, float r)
            {
                return length(p - c) - r;
            }
            

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = input.uv.xy;
                output.color = input.color;
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                float2 p = input.uv - 0.5;

                float d = Circle(p, float2(0, 0), _SunRadius);

                // Sun disc
                float disc = 1.0 - smoothstep(-_EdgeSoftness, _EdgeSoftness, d);

                // Atmospheric glow
                float glow = exp(-max(d, 0.0) * _GlowFalloff);
                glow *= _GlowStrength;

                // Fade glow before reaching the quad boundary
                float fade = 1.0 - smoothstep(0.35, 0.5, length(p));
                glow *= fade;

                // Transition from warm glow to white core
                float3 color = lerp(
                    _GlowColor.rgb,
                    _SunColor.rgb,
                    disc
                );

                float alpha = disc + glow * (1.0 - disc);

                return half4(color, alpha);
            }
            ENDHLSL
        }
    }
}
