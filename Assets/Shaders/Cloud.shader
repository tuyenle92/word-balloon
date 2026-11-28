
Shader "Custom/Cloud"
{
    Properties
    {
        _CloudColor ("Cloud Color", Color) = (1,1,1,1)
        _CloudDensity ("Cloud Density", Range(0,1)) = 0.5
        _EdgeSoftness ("Edge Softness", Range(0.001,0.1)) = 0.01
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
                float4 _CloudColor;
                float _CloudDensity;
                float _EdgeSoftness;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
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

                output.positionCS =
                    TransformObjectToHClip(input.positionOS.xyz);

                output.uv = input.uv;
                output.color = input.color;

                return output;
            }

            half4 frag (Varyings input) : SV_Target
            {
                float2 p = input.uv - 0.5;

                float d1 = Circle(p, float2(-0.28, -0.10), 0.18);
                float d2 = Circle(p, float2(-0.12,  0.02), 0.23);
                float d3 = Circle(p, float2( 0.12,  0.08), 0.25);
                float d4 = Circle(p, float2( 0.30, -0.08), 0.18);

                float d = min(min(d1, d2), min(d3, d4));

                float alpha = 1.0 - smoothstep(
                    -_EdgeSoftness,
                     _EdgeSoftness,
                     d
                );

                return half4(
                    _CloudColor.rgb * input.color.rgb,
                    alpha * _CloudDensity * _CloudColor.a * input.color.a
                );
            }
            ENDHLSL
        }
    }
}