Shader "Custom/Sky"
{
    Properties
    {
        _ZenithColor ("Zenith Color", Color) = (0.157, 0.475, 0.773, 1)
        _HorizonColor ("Horizon Color", Color) = (0.863, 0.933, 0.969, 1)
        _GradientPower ("Gradient Power", Range(0.1, 5)) = 0.65
        _HazeColor ("Haze Color", Color) = (0.96, 0.97, 0.98, 1)
        _HazeStrength ("Haze Strength", Range(0, 1)) = 0.6
        _HazeFalloff ("Haze Falloff", Float) = 5.0
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
                float4 _ZenithColor;
                float4 _HorizonColor;
                float _GradientPower;
                float4 _HazeColor;
                float _HazeStrength;
                float _HazeFalloff;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = input.uv.xy;
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                float t = pow(saturate(input.uv.y), _GradientPower);
                float haze = exp(-input.uv.y * _HazeFalloff);
                float3 skyColor = lerp(_HorizonColor.rgb, _ZenithColor.rgb, t);
                skyColor = lerp(skyColor, _HazeColor.rgb, haze * _HazeStrength);


                float3 zenithColor = lerp(
                    _NightZenithColor.rgb,
                    _DayZenithColor.rgb,
                    _Daylight
                );

                float3 horizonColor = lerp(
                    _NightHorizonColor.rgb,
                    _DayHorizonColor.rgb,
                    _Daylight
                );


                return half4(skyColor, 1.0);
            }
            ENDHLSL
        }
    }
}
