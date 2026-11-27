
Shader "Custom/ProceduralBalloon"
{
    Properties
    {
        _BaseColor ("Balloon Color", Color) = (0.8, 0.02, 0.04, 1)
        _LightDirection ("Light Direction", Vector) = (-0.5, 0.7, 1, 0)
        _Shininess ("Shininess", Range(1, 128)) = 32
        _SpecularStrength ("Shine Strength", Range(0, 2)) = 0.8
        _Ambient ("Ambient Light", Range(0, 1)) = 0.3
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
        }

        Pass
        {
            Cull Off

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float4 _LightDirection;
                float _Shininess;
                float _SpecularStrength;
                float _Ambient;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;

                output.positionCS =
                    TransformObjectToHClip(
                        input.positionOS.xyz
                    );

                output.uv = input.uv;

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                // Convert UV from [0, 1] to [-1, 1]
                float2 p = input.uv * 2.0 - 1.0;

                // Simulate a curved surface
                float z = sqrt(
                    saturate(1.0 - dot(p, p))
                );

                float3 normal = normalize(
                    float3(p.x, p.y, z)
                );

                float3 lightDir = normalize(
                    _LightDirection.xyz
                );

                // Diffuse lighting
                float diffuse = saturate(
                    dot(normal, lightDir)
                );

                // Virtual camera direction
                float3 viewDir = float3(0, 0, 1);

                float3 halfDir = normalize(
                    lightDir + viewDir
                );

                // Specular reflection
                float specular = pow(
                    saturate(dot(normal, halfDir)),
                    _Shininess
                ) * _SpecularStrength;

                // Combine lighting
                float3 color =
                _BaseColor.rgb * _Ambient
                + _BaseColor.rgb * diffuse
                + specular * _SpecularStrength;

                return half4(color, 1.0);
            }

            ENDHLSL
        }
    }
}
