
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
                float4 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float seed : TEXCOORD1;
                float4 color : COLOR;
            };

            float Circle(float2 p, float2 c, float r)
            {
                return length(p - c) - r;
            }

            float Random(float seed)
            {
                return frac(sin(seed * 127.1) * 43758.5453);
            }

            float RandomRange(float seed, float minValue, float maxValue)
            {
                return lerp(minValue, maxValue, Random(seed));
            }


            float RandomCircle(float2 p, float2 c, float r, float seed)
            {
                c.x += RandomRange(seed + 1.0, -0.05, 0.05);
                c.y += RandomRange(seed + 2.0, -0.05, 0.05);

                r += RandomRange(seed + 3.0, -0.03, 0.03);

                return Circle(p, c, r);
            }

            Varyings vert(Attributes input)
            {
                Varyings output;

                output.positionCS =
                    TransformObjectToHClip(input.positionOS.xyz);

                output.uv = input.uv.xy;
                output.color = input.color;
                output.seed = input.uv.z * 1000.0;

                return output;
            }

            half4 frag (Varyings input) : SV_Target
            {
                float2 p = (input.uv - 0.5) * 1.2;
                float seed = input.seed;

                float d1 = RandomCircle(p, float2(-0.28, -0.10), 0.18, seed);
                float d2 = RandomCircle(p, float2(-0.12,  0.02), 0.23, seed + 3.0);
                float d3 = RandomCircle(p, float2( 0.12,  0.08), 0.25, seed + 6.0);
                float d4 = RandomCircle(p, float2( 0.30, -0.08), 0.18, seed + 9.0);

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

