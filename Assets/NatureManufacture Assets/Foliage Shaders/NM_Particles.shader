Shader "NatureManufacture/URP/NM_Particles"
{
    Properties
    {
        _AlphaClipThreshold("Alpha Clip Threshold", Range(0, 1)) = 1
        [ToggleUI]_ReadAlbedo("Read Albedo", Float) = 1
        [NoScaleOffset]_ParticleMask("Particle (RGB) Mask (A)", 2D) = "white" {}
        _TilingandOffset("Tiling and Offset", Vector) = (1, 1, 0, 0)
        _ParticleColor("Particle Color (RGB) Alpha (A)", Color) = (1, 1, 1, 1)
        [NoScaleOffset]_ParticleNormal("Particle Normal", 2D) = "white" {}
        _ParticleNormalScale("Particle Normal Scale", Float) = 1
        _AO("_AO", Range(0, 1)) = 1
        Metallic("Metallic", Range(0, 1)) = 0
        _Smoothness("Smoothness", Range(0, 1)) = 1
        _CullFarStart("Cull Far Start", Float) = 40
        _CullFarDistance("Cull Far Distance", Float) = 80
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "DisableBatching"="False"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _FORWARD_PLUS
        #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define ATTRIBUTES_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float4 color;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
             float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
             float4 tangentWS : INTERP4;
             float4 texCoord0 : INTERP5;
             float4 color : INTERP6;
             float4 fogFactorAndVertexLight : INTERP7;
             float3 positionWS : INTERP8;
             float3 normalWS : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.color.xyzw = input.color;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.color = input.color.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaClipThreshold;
        float _ReadAlbedo;
        float4 _ParticleMask_TexelSize;
        float4 _TilingandOffset;
        float4 _ParticleColor;
        float4 _ParticleNormal_TexelSize;
        float _ParticleNormalScale;
        float _AO;
        float Metallic;
        float _Smoothness;
        float _CullFarStart;
        float _CullFarDistance;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParticleMask);
        SAMPLER(sampler_ParticleMask);
        TEXTURE2D(_ParticleNormal);
        SAMPLER(sampler_ParticleNormal);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_9b33c3a3dd587d81bcaadf5c3e8e2139_Out_0_Boolean = _ReadAlbedo;
            float4 _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4 = _ParticleColor;
            UnityTexture2D _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_ParticleMask);
            float4 _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4 = _TilingandOffset;
            float _Split_0f89628531900280a6fdfeed464d7db0_R_1_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[0];
            float _Split_0f89628531900280a6fdfeed464d7db0_G_2_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[1];
            float _Split_0f89628531900280a6fdfeed464d7db0_B_3_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[2];
            float _Split_0f89628531900280a6fdfeed464d7db0_A_4_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[3];
            float4 _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4_Vector4;
            float3 _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5_Vector3;
            float2 _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6_Vector2;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_B_3_Float, _Split_0f89628531900280a6fdfeed464d7db0_A_4_Float, 0, 0, _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4_Vector4, _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5_Vector3, _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6_Vector2);
            float4 _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4_Vector4;
            float3 _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5_Vector3;
            float2 _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6_Vector2;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_R_1_Float, _Split_0f89628531900280a6fdfeed464d7db0_G_2_Float, 0, 0, _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4_Vector4, _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5_Vector3, _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6_Vector2);
            float4 _UV_426d4b83acf75988818b968670a6c706_Out_0_Vector4 = IN.uv0;
            float2 _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Combine_a4549e90842d0d89a5980eed4127a17b_RG_6_Vector2, (_UV_426d4b83acf75988818b968670a6c706_Out_0_Vector4.xy), _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2_Vector2);
            float2 _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2;
            Unity_Add_float2(_Combine_b5e51e12d953b181b56901d50c50cd23_RG_6_Vector2, _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2_Vector2, _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2);
            float4 _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D.tex, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D.samplerstate, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2) );
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_R_4_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.r;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_G_5_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.g;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_B_6_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.b;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.a;
            float4 _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4, _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2_Vector4);
            float4 _Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3_Vector4;
            Unity_Branch_float4(_Property_9b33c3a3dd587d81bcaadf5c3e8e2139_Out_0_Boolean, _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2_Vector4, _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4, _Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3_Vector4);
            float4 _Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3_Vector4, IN.VertexColor, _Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2_Vector4);
            UnityTexture2D _Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_ParticleNormal);
            float4 _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0_Texture2D.tex, _Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0_Texture2D.samplerstate, _Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0_Texture2D.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2) );
            _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0_Vector4);
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_R_4_Float = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0_Vector4.r;
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_G_5_Float = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0_Vector4.g;
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_B_6_Float = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0_Vector4.b;
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_A_7_Float = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0_Vector4.a;
            float _Property_4bd339f3ffc5228c9432f9e4e283a729_Out_0_Float = _ParticleNormalScale;
            float3 _NormalStrength_d97258b37529438aab592806c892e47e_Out_2_Vector3;
            Unity_NormalStrength_float((_SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0_Vector4.xyz), _Property_4bd339f3ffc5228c9432f9e4e283a729_Out_0_Float, _NormalStrength_d97258b37529438aab592806c892e47e_Out_2_Vector3);
            float _Property_be59c3635ef71989b75c052aecf52145_Out_0_Float = Metallic;
            float _Property_548711527280108ba78da51c84df9cdd_Out_0_Float = _Smoothness;
            float _Property_68e6b5b8cb4009839a4e9ab06935bddb_Out_0_Float = _AO;
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_R_1_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[0];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_G_2_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[1];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_B_3_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[2];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_A_4_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[3];
            float _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2_Float;
            Unity_Multiply_float_float(_Split_b3351ea0323f53819c49f9ebc3297dfd_A_4_Float, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7_Float, _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2_Float);
            float _Split_23be1e5860e84d8aa9ab147605cf804c_R_1_Float = IN.VertexColor[0];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_G_2_Float = IN.VertexColor[1];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_B_3_Float = IN.VertexColor[2];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_A_4_Float = IN.VertexColor[3];
            float _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2_Float, _Split_23be1e5860e84d8aa9ab147605cf804c_A_4_Float, _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2_Float);
            float _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2_Float;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2_Float);
            float _Property_560bbe7f2d950d86813d2af8016de375_Out_0_Float = _CullFarStart;
            float _Subtract_5373207144af5c888442613c746c85a5_Out_2_Float;
            Unity_Subtract_float(_Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2_Float, _Property_560bbe7f2d950d86813d2af8016de375_Out_0_Float, _Subtract_5373207144af5c888442613c746c85a5_Out_2_Float);
            float _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0_Float = _CullFarDistance;
            float _Divide_009a8503c50859889678476fb7b96335_Out_2_Float;
            Unity_Divide_float(_Subtract_5373207144af5c888442613c746c85a5_Out_2_Float, _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0_Float, _Divide_009a8503c50859889678476fb7b96335_Out_2_Float);
            float _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1_Float;
            Unity_Saturate_float(_Divide_009a8503c50859889678476fb7b96335_Out_2_Float, _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1_Float);
            float _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3_Float;
            Unity_Clamp_float(_Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1_Float, 0, 1, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3_Float);
            float _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2_Float, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3_Float, _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2_Float);
            float _Property_e8300f3c175a8584b8b8045b9854d400_Out_0_Float = _AlphaClipThreshold;
            surface.BaseColor = (_Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2_Vector4.xyz);
            surface.NormalTS = _NormalStrength_d97258b37529438aab592806c892e47e_Out_2_Vector3;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = _Property_be59c3635ef71989b75c052aecf52145_Out_0_Float;
            surface.Smoothness = _Property_548711527280108ba78da51c84df9cdd_Out_0_Float;
            surface.Occlusion = _Property_68e6b5b8cb4009839a4e9ab06935bddb_Out_0_Float;
            surface.Alpha = _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2_Float;
            surface.AlphaClipThreshold = _Property_e8300f3c175a8584b8b8045b9854d400_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define ATTRIBUTES_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float4 color;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
             float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
             float4 tangentWS : INTERP4;
             float4 texCoord0 : INTERP5;
             float4 color : INTERP6;
             float4 fogFactorAndVertexLight : INTERP7;
             float3 positionWS : INTERP8;
             float3 normalWS : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.color.xyzw = input.color;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.color = input.color.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaClipThreshold;
        float _ReadAlbedo;
        float4 _ParticleMask_TexelSize;
        float4 _TilingandOffset;
        float4 _ParticleColor;
        float4 _ParticleNormal_TexelSize;
        float _ParticleNormalScale;
        float _AO;
        float Metallic;
        float _Smoothness;
        float _CullFarStart;
        float _CullFarDistance;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParticleMask);
        SAMPLER(sampler_ParticleMask);
        TEXTURE2D(_ParticleNormal);
        SAMPLER(sampler_ParticleNormal);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_9b33c3a3dd587d81bcaadf5c3e8e2139_Out_0_Boolean = _ReadAlbedo;
            float4 _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4 = _ParticleColor;
            UnityTexture2D _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_ParticleMask);
            float4 _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4 = _TilingandOffset;
            float _Split_0f89628531900280a6fdfeed464d7db0_R_1_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[0];
            float _Split_0f89628531900280a6fdfeed464d7db0_G_2_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[1];
            float _Split_0f89628531900280a6fdfeed464d7db0_B_3_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[2];
            float _Split_0f89628531900280a6fdfeed464d7db0_A_4_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[3];
            float4 _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4_Vector4;
            float3 _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5_Vector3;
            float2 _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6_Vector2;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_B_3_Float, _Split_0f89628531900280a6fdfeed464d7db0_A_4_Float, 0, 0, _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4_Vector4, _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5_Vector3, _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6_Vector2);
            float4 _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4_Vector4;
            float3 _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5_Vector3;
            float2 _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6_Vector2;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_R_1_Float, _Split_0f89628531900280a6fdfeed464d7db0_G_2_Float, 0, 0, _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4_Vector4, _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5_Vector3, _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6_Vector2);
            float4 _UV_426d4b83acf75988818b968670a6c706_Out_0_Vector4 = IN.uv0;
            float2 _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Combine_a4549e90842d0d89a5980eed4127a17b_RG_6_Vector2, (_UV_426d4b83acf75988818b968670a6c706_Out_0_Vector4.xy), _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2_Vector2);
            float2 _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2;
            Unity_Add_float2(_Combine_b5e51e12d953b181b56901d50c50cd23_RG_6_Vector2, _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2_Vector2, _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2);
            float4 _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D.tex, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D.samplerstate, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2) );
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_R_4_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.r;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_G_5_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.g;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_B_6_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.b;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.a;
            float4 _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4, _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2_Vector4);
            float4 _Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3_Vector4;
            Unity_Branch_float4(_Property_9b33c3a3dd587d81bcaadf5c3e8e2139_Out_0_Boolean, _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2_Vector4, _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4, _Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3_Vector4);
            float4 _Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3_Vector4, IN.VertexColor, _Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2_Vector4);
            UnityTexture2D _Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_ParticleNormal);
            float4 _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0_Texture2D.tex, _Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0_Texture2D.samplerstate, _Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0_Texture2D.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2) );
            _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0_Vector4);
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_R_4_Float = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0_Vector4.r;
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_G_5_Float = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0_Vector4.g;
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_B_6_Float = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0_Vector4.b;
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_A_7_Float = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0_Vector4.a;
            float _Property_4bd339f3ffc5228c9432f9e4e283a729_Out_0_Float = _ParticleNormalScale;
            float3 _NormalStrength_d97258b37529438aab592806c892e47e_Out_2_Vector3;
            Unity_NormalStrength_float((_SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0_Vector4.xyz), _Property_4bd339f3ffc5228c9432f9e4e283a729_Out_0_Float, _NormalStrength_d97258b37529438aab592806c892e47e_Out_2_Vector3);
            float _Property_be59c3635ef71989b75c052aecf52145_Out_0_Float = Metallic;
            float _Property_548711527280108ba78da51c84df9cdd_Out_0_Float = _Smoothness;
            float _Property_68e6b5b8cb4009839a4e9ab06935bddb_Out_0_Float = _AO;
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_R_1_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[0];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_G_2_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[1];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_B_3_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[2];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_A_4_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[3];
            float _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2_Float;
            Unity_Multiply_float_float(_Split_b3351ea0323f53819c49f9ebc3297dfd_A_4_Float, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7_Float, _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2_Float);
            float _Split_23be1e5860e84d8aa9ab147605cf804c_R_1_Float = IN.VertexColor[0];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_G_2_Float = IN.VertexColor[1];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_B_3_Float = IN.VertexColor[2];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_A_4_Float = IN.VertexColor[3];
            float _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2_Float, _Split_23be1e5860e84d8aa9ab147605cf804c_A_4_Float, _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2_Float);
            float _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2_Float;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2_Float);
            float _Property_560bbe7f2d950d86813d2af8016de375_Out_0_Float = _CullFarStart;
            float _Subtract_5373207144af5c888442613c746c85a5_Out_2_Float;
            Unity_Subtract_float(_Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2_Float, _Property_560bbe7f2d950d86813d2af8016de375_Out_0_Float, _Subtract_5373207144af5c888442613c746c85a5_Out_2_Float);
            float _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0_Float = _CullFarDistance;
            float _Divide_009a8503c50859889678476fb7b96335_Out_2_Float;
            Unity_Divide_float(_Subtract_5373207144af5c888442613c746c85a5_Out_2_Float, _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0_Float, _Divide_009a8503c50859889678476fb7b96335_Out_2_Float);
            float _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1_Float;
            Unity_Saturate_float(_Divide_009a8503c50859889678476fb7b96335_Out_2_Float, _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1_Float);
            float _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3_Float;
            Unity_Clamp_float(_Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1_Float, 0, 1, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3_Float);
            float _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2_Float, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3_Float, _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2_Float);
            float _Property_e8300f3c175a8584b8b8045b9854d400_Out_0_Float = _AlphaClipThreshold;
            surface.BaseColor = (_Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2_Vector4.xyz);
            surface.NormalTS = _NormalStrength_d97258b37529438aab592806c892e47e_Out_2_Vector3;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = _Property_be59c3635ef71989b75c052aecf52145_Out_0_Float;
            surface.Smoothness = _Property_548711527280108ba78da51c84df9cdd_Out_0_Float;
            surface.Occlusion = _Property_68e6b5b8cb4009839a4e9ab06935bddb_Out_0_Float;
            surface.Alpha = _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2_Float;
            surface.AlphaClipThreshold = _Property_e8300f3c175a8584b8b8045b9854d400_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
             float4 color;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
             float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 color : INTERP1;
             float3 positionWS : INTERP2;
             float3 normalWS : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.color.xyzw = input.color;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.color = input.color.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaClipThreshold;
        float _ReadAlbedo;
        float4 _ParticleMask_TexelSize;
        float4 _TilingandOffset;
        float4 _ParticleColor;
        float4 _ParticleNormal_TexelSize;
        float _ParticleNormalScale;
        float _AO;
        float Metallic;
        float _Smoothness;
        float _CullFarStart;
        float _CullFarDistance;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParticleMask);
        SAMPLER(sampler_ParticleMask);
        TEXTURE2D(_ParticleNormal);
        SAMPLER(sampler_ParticleNormal);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4 = _ParticleColor;
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_R_1_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[0];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_G_2_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[1];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_B_3_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[2];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_A_4_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[3];
            UnityTexture2D _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_ParticleMask);
            float4 _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4 = _TilingandOffset;
            float _Split_0f89628531900280a6fdfeed464d7db0_R_1_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[0];
            float _Split_0f89628531900280a6fdfeed464d7db0_G_2_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[1];
            float _Split_0f89628531900280a6fdfeed464d7db0_B_3_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[2];
            float _Split_0f89628531900280a6fdfeed464d7db0_A_4_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[3];
            float4 _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4_Vector4;
            float3 _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5_Vector3;
            float2 _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6_Vector2;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_B_3_Float, _Split_0f89628531900280a6fdfeed464d7db0_A_4_Float, 0, 0, _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4_Vector4, _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5_Vector3, _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6_Vector2);
            float4 _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4_Vector4;
            float3 _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5_Vector3;
            float2 _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6_Vector2;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_R_1_Float, _Split_0f89628531900280a6fdfeed464d7db0_G_2_Float, 0, 0, _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4_Vector4, _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5_Vector3, _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6_Vector2);
            float4 _UV_426d4b83acf75988818b968670a6c706_Out_0_Vector4 = IN.uv0;
            float2 _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Combine_a4549e90842d0d89a5980eed4127a17b_RG_6_Vector2, (_UV_426d4b83acf75988818b968670a6c706_Out_0_Vector4.xy), _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2_Vector2);
            float2 _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2;
            Unity_Add_float2(_Combine_b5e51e12d953b181b56901d50c50cd23_RG_6_Vector2, _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2_Vector2, _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2);
            float4 _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D.tex, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D.samplerstate, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2) );
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_R_4_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.r;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_G_5_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.g;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_B_6_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.b;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.a;
            float _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2_Float;
            Unity_Multiply_float_float(_Split_b3351ea0323f53819c49f9ebc3297dfd_A_4_Float, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7_Float, _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2_Float);
            float _Split_23be1e5860e84d8aa9ab147605cf804c_R_1_Float = IN.VertexColor[0];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_G_2_Float = IN.VertexColor[1];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_B_3_Float = IN.VertexColor[2];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_A_4_Float = IN.VertexColor[3];
            float _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2_Float, _Split_23be1e5860e84d8aa9ab147605cf804c_A_4_Float, _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2_Float);
            float _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2_Float;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2_Float);
            float _Property_560bbe7f2d950d86813d2af8016de375_Out_0_Float = _CullFarStart;
            float _Subtract_5373207144af5c888442613c746c85a5_Out_2_Float;
            Unity_Subtract_float(_Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2_Float, _Property_560bbe7f2d950d86813d2af8016de375_Out_0_Float, _Subtract_5373207144af5c888442613c746c85a5_Out_2_Float);
            float _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0_Float = _CullFarDistance;
            float _Divide_009a8503c50859889678476fb7b96335_Out_2_Float;
            Unity_Divide_float(_Subtract_5373207144af5c888442613c746c85a5_Out_2_Float, _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0_Float, _Divide_009a8503c50859889678476fb7b96335_Out_2_Float);
            float _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1_Float;
            Unity_Saturate_float(_Divide_009a8503c50859889678476fb7b96335_Out_2_Float, _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1_Float);
            float _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3_Float;
            Unity_Clamp_float(_Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1_Float, 0, 1, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3_Float);
            float _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2_Float, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3_Float, _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2_Float);
            float _Property_e8300f3c175a8584b8b8045b9854d400_Out_0_Float = _AlphaClipThreshold;
            surface.Alpha = _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2_Float;
            surface.AlphaClipThreshold = _Property_e8300f3c175a8584b8b8045b9854d400_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "MotionVectors"
            Tags
            {
                "LightMode" = "MotionVectors"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask RG
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.5
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_MOTION_VECTORS
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float4 uv0 : TEXCOORD0;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
             float4 color;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
             float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 color : INTERP1;
             float3 positionWS : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.color.xyzw = input.color;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.color = input.color.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaClipThreshold;
        float _ReadAlbedo;
        float4 _ParticleMask_TexelSize;
        float4 _TilingandOffset;
        float4 _ParticleColor;
        float4 _ParticleNormal_TexelSize;
        float _ParticleNormalScale;
        float _AO;
        float Metallic;
        float _Smoothness;
        float _CullFarStart;
        float _CullFarDistance;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParticleMask);
        SAMPLER(sampler_ParticleMask);
        TEXTURE2D(_ParticleNormal);
        SAMPLER(sampler_ParticleNormal);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4 = _ParticleColor;
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_R_1_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[0];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_G_2_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[1];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_B_3_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[2];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_A_4_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[3];
            UnityTexture2D _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_ParticleMask);
            float4 _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4 = _TilingandOffset;
            float _Split_0f89628531900280a6fdfeed464d7db0_R_1_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[0];
            float _Split_0f89628531900280a6fdfeed464d7db0_G_2_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[1];
            float _Split_0f89628531900280a6fdfeed464d7db0_B_3_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[2];
            float _Split_0f89628531900280a6fdfeed464d7db0_A_4_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[3];
            float4 _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4_Vector4;
            float3 _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5_Vector3;
            float2 _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6_Vector2;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_B_3_Float, _Split_0f89628531900280a6fdfeed464d7db0_A_4_Float, 0, 0, _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4_Vector4, _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5_Vector3, _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6_Vector2);
            float4 _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4_Vector4;
            float3 _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5_Vector3;
            float2 _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6_Vector2;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_R_1_Float, _Split_0f89628531900280a6fdfeed464d7db0_G_2_Float, 0, 0, _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4_Vector4, _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5_Vector3, _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6_Vector2);
            float4 _UV_426d4b83acf75988818b968670a6c706_Out_0_Vector4 = IN.uv0;
            float2 _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Combine_a4549e90842d0d89a5980eed4127a17b_RG_6_Vector2, (_UV_426d4b83acf75988818b968670a6c706_Out_0_Vector4.xy), _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2_Vector2);
            float2 _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2;
            Unity_Add_float2(_Combine_b5e51e12d953b181b56901d50c50cd23_RG_6_Vector2, _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2_Vector2, _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2);
            float4 _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D.tex, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D.samplerstate, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2) );
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_R_4_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.r;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_G_5_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.g;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_B_6_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.b;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.a;
            float _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2_Float;
            Unity_Multiply_float_float(_Split_b3351ea0323f53819c49f9ebc3297dfd_A_4_Float, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7_Float, _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2_Float);
            float _Split_23be1e5860e84d8aa9ab147605cf804c_R_1_Float = IN.VertexColor[0];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_G_2_Float = IN.VertexColor[1];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_B_3_Float = IN.VertexColor[2];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_A_4_Float = IN.VertexColor[3];
            float _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2_Float, _Split_23be1e5860e84d8aa9ab147605cf804c_A_4_Float, _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2_Float);
            float _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2_Float;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2_Float);
            float _Property_560bbe7f2d950d86813d2af8016de375_Out_0_Float = _CullFarStart;
            float _Subtract_5373207144af5c888442613c746c85a5_Out_2_Float;
            Unity_Subtract_float(_Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2_Float, _Property_560bbe7f2d950d86813d2af8016de375_Out_0_Float, _Subtract_5373207144af5c888442613c746c85a5_Out_2_Float);
            float _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0_Float = _CullFarDistance;
            float _Divide_009a8503c50859889678476fb7b96335_Out_2_Float;
            Unity_Divide_float(_Subtract_5373207144af5c888442613c746c85a5_Out_2_Float, _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0_Float, _Divide_009a8503c50859889678476fb7b96335_Out_2_Float);
            float _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1_Float;
            Unity_Saturate_float(_Divide_009a8503c50859889678476fb7b96335_Out_2_Float, _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1_Float);
            float _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3_Float;
            Unity_Clamp_float(_Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1_Float, 0, 1, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3_Float);
            float _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2_Float, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3_Float, _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2_Float);
            float _Property_e8300f3c175a8584b8b8045b9854d400_Out_0_Float = _AlphaClipThreshold;
            surface.Alpha = _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2_Float;
            surface.AlphaClipThreshold = _Property_e8300f3c175a8584b8b8045b9854d400_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/MotionVectorPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float4 color;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
             float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 tangentWS : INTERP0;
             float4 texCoord0 : INTERP1;
             float4 color : INTERP2;
             float3 positionWS : INTERP3;
             float3 normalWS : INTERP4;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.color.xyzw = input.color;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.color = input.color.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaClipThreshold;
        float _ReadAlbedo;
        float4 _ParticleMask_TexelSize;
        float4 _TilingandOffset;
        float4 _ParticleColor;
        float4 _ParticleNormal_TexelSize;
        float _ParticleNormalScale;
        float _AO;
        float Metallic;
        float _Smoothness;
        float _CullFarStart;
        float _CullFarDistance;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParticleMask);
        SAMPLER(sampler_ParticleMask);
        TEXTURE2D(_ParticleNormal);
        SAMPLER(sampler_ParticleNormal);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_ParticleNormal);
            float4 _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4 = _TilingandOffset;
            float _Split_0f89628531900280a6fdfeed464d7db0_R_1_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[0];
            float _Split_0f89628531900280a6fdfeed464d7db0_G_2_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[1];
            float _Split_0f89628531900280a6fdfeed464d7db0_B_3_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[2];
            float _Split_0f89628531900280a6fdfeed464d7db0_A_4_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[3];
            float4 _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4_Vector4;
            float3 _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5_Vector3;
            float2 _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6_Vector2;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_B_3_Float, _Split_0f89628531900280a6fdfeed464d7db0_A_4_Float, 0, 0, _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4_Vector4, _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5_Vector3, _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6_Vector2);
            float4 _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4_Vector4;
            float3 _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5_Vector3;
            float2 _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6_Vector2;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_R_1_Float, _Split_0f89628531900280a6fdfeed464d7db0_G_2_Float, 0, 0, _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4_Vector4, _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5_Vector3, _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6_Vector2);
            float4 _UV_426d4b83acf75988818b968670a6c706_Out_0_Vector4 = IN.uv0;
            float2 _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Combine_a4549e90842d0d89a5980eed4127a17b_RG_6_Vector2, (_UV_426d4b83acf75988818b968670a6c706_Out_0_Vector4.xy), _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2_Vector2);
            float2 _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2;
            Unity_Add_float2(_Combine_b5e51e12d953b181b56901d50c50cd23_RG_6_Vector2, _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2_Vector2, _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2);
            float4 _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0_Texture2D.tex, _Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0_Texture2D.samplerstate, _Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0_Texture2D.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2) );
            _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0_Vector4);
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_R_4_Float = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0_Vector4.r;
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_G_5_Float = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0_Vector4.g;
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_B_6_Float = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0_Vector4.b;
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_A_7_Float = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0_Vector4.a;
            float _Property_4bd339f3ffc5228c9432f9e4e283a729_Out_0_Float = _ParticleNormalScale;
            float3 _NormalStrength_d97258b37529438aab592806c892e47e_Out_2_Vector3;
            Unity_NormalStrength_float((_SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0_Vector4.xyz), _Property_4bd339f3ffc5228c9432f9e4e283a729_Out_0_Float, _NormalStrength_d97258b37529438aab592806c892e47e_Out_2_Vector3);
            float4 _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4 = _ParticleColor;
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_R_1_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[0];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_G_2_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[1];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_B_3_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[2];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_A_4_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[3];
            UnityTexture2D _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_ParticleMask);
            float4 _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D.tex, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D.samplerstate, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2) );
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_R_4_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.r;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_G_5_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.g;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_B_6_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.b;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.a;
            float _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2_Float;
            Unity_Multiply_float_float(_Split_b3351ea0323f53819c49f9ebc3297dfd_A_4_Float, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7_Float, _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2_Float);
            float _Split_23be1e5860e84d8aa9ab147605cf804c_R_1_Float = IN.VertexColor[0];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_G_2_Float = IN.VertexColor[1];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_B_3_Float = IN.VertexColor[2];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_A_4_Float = IN.VertexColor[3];
            float _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2_Float, _Split_23be1e5860e84d8aa9ab147605cf804c_A_4_Float, _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2_Float);
            float _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2_Float;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2_Float);
            float _Property_560bbe7f2d950d86813d2af8016de375_Out_0_Float = _CullFarStart;
            float _Subtract_5373207144af5c888442613c746c85a5_Out_2_Float;
            Unity_Subtract_float(_Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2_Float, _Property_560bbe7f2d950d86813d2af8016de375_Out_0_Float, _Subtract_5373207144af5c888442613c746c85a5_Out_2_Float);
            float _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0_Float = _CullFarDistance;
            float _Divide_009a8503c50859889678476fb7b96335_Out_2_Float;
            Unity_Divide_float(_Subtract_5373207144af5c888442613c746c85a5_Out_2_Float, _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0_Float, _Divide_009a8503c50859889678476fb7b96335_Out_2_Float);
            float _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1_Float;
            Unity_Saturate_float(_Divide_009a8503c50859889678476fb7b96335_Out_2_Float, _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1_Float);
            float _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3_Float;
            Unity_Clamp_float(_Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1_Float, 0, 1, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3_Float);
            float _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2_Float, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3_Float, _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2_Float);
            float _Property_e8300f3c175a8584b8b8045b9854d400_Out_0_Float = _AlphaClipThreshold;
            surface.NormalTS = _NormalStrength_d97258b37529438aab592806c892e47e_Out_2_Vector3;
            surface.Alpha = _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2_Float;
            surface.AlphaClipThreshold = _Property_e8300f3c175a8584b8b8045b9854d400_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define ATTRIBUTES_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
             float4 color;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
             float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 texCoord1 : INTERP1;
             float4 texCoord2 : INTERP2;
             float4 color : INTERP3;
             float3 positionWS : INTERP4;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.texCoord2.xyzw = input.texCoord2;
            output.color.xyzw = input.color;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.texCoord2 = input.texCoord2.xyzw;
            output.color = input.color.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaClipThreshold;
        float _ReadAlbedo;
        float4 _ParticleMask_TexelSize;
        float4 _TilingandOffset;
        float4 _ParticleColor;
        float4 _ParticleNormal_TexelSize;
        float _ParticleNormalScale;
        float _AO;
        float Metallic;
        float _Smoothness;
        float _CullFarStart;
        float _CullFarDistance;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParticleMask);
        SAMPLER(sampler_ParticleMask);
        TEXTURE2D(_ParticleNormal);
        SAMPLER(sampler_ParticleNormal);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_9b33c3a3dd587d81bcaadf5c3e8e2139_Out_0_Boolean = _ReadAlbedo;
            float4 _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4 = _ParticleColor;
            UnityTexture2D _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_ParticleMask);
            float4 _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4 = _TilingandOffset;
            float _Split_0f89628531900280a6fdfeed464d7db0_R_1_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[0];
            float _Split_0f89628531900280a6fdfeed464d7db0_G_2_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[1];
            float _Split_0f89628531900280a6fdfeed464d7db0_B_3_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[2];
            float _Split_0f89628531900280a6fdfeed464d7db0_A_4_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[3];
            float4 _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4_Vector4;
            float3 _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5_Vector3;
            float2 _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6_Vector2;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_B_3_Float, _Split_0f89628531900280a6fdfeed464d7db0_A_4_Float, 0, 0, _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4_Vector4, _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5_Vector3, _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6_Vector2);
            float4 _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4_Vector4;
            float3 _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5_Vector3;
            float2 _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6_Vector2;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_R_1_Float, _Split_0f89628531900280a6fdfeed464d7db0_G_2_Float, 0, 0, _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4_Vector4, _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5_Vector3, _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6_Vector2);
            float4 _UV_426d4b83acf75988818b968670a6c706_Out_0_Vector4 = IN.uv0;
            float2 _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Combine_a4549e90842d0d89a5980eed4127a17b_RG_6_Vector2, (_UV_426d4b83acf75988818b968670a6c706_Out_0_Vector4.xy), _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2_Vector2);
            float2 _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2;
            Unity_Add_float2(_Combine_b5e51e12d953b181b56901d50c50cd23_RG_6_Vector2, _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2_Vector2, _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2);
            float4 _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D.tex, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D.samplerstate, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2) );
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_R_4_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.r;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_G_5_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.g;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_B_6_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.b;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.a;
            float4 _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4, _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2_Vector4);
            float4 _Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3_Vector4;
            Unity_Branch_float4(_Property_9b33c3a3dd587d81bcaadf5c3e8e2139_Out_0_Boolean, _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2_Vector4, _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4, _Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3_Vector4);
            float4 _Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3_Vector4, IN.VertexColor, _Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2_Vector4);
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_R_1_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[0];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_G_2_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[1];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_B_3_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[2];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_A_4_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[3];
            float _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2_Float;
            Unity_Multiply_float_float(_Split_b3351ea0323f53819c49f9ebc3297dfd_A_4_Float, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7_Float, _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2_Float);
            float _Split_23be1e5860e84d8aa9ab147605cf804c_R_1_Float = IN.VertexColor[0];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_G_2_Float = IN.VertexColor[1];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_B_3_Float = IN.VertexColor[2];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_A_4_Float = IN.VertexColor[3];
            float _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2_Float, _Split_23be1e5860e84d8aa9ab147605cf804c_A_4_Float, _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2_Float);
            float _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2_Float;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2_Float);
            float _Property_560bbe7f2d950d86813d2af8016de375_Out_0_Float = _CullFarStart;
            float _Subtract_5373207144af5c888442613c746c85a5_Out_2_Float;
            Unity_Subtract_float(_Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2_Float, _Property_560bbe7f2d950d86813d2af8016de375_Out_0_Float, _Subtract_5373207144af5c888442613c746c85a5_Out_2_Float);
            float _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0_Float = _CullFarDistance;
            float _Divide_009a8503c50859889678476fb7b96335_Out_2_Float;
            Unity_Divide_float(_Subtract_5373207144af5c888442613c746c85a5_Out_2_Float, _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0_Float, _Divide_009a8503c50859889678476fb7b96335_Out_2_Float);
            float _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1_Float;
            Unity_Saturate_float(_Divide_009a8503c50859889678476fb7b96335_Out_2_Float, _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1_Float);
            float _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3_Float;
            Unity_Clamp_float(_Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1_Float, 0, 1, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3_Float);
            float _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2_Float, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3_Float, _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2_Float);
            float _Property_e8300f3c175a8584b8b8045b9854d400_Out_0_Float = _AlphaClipThreshold;
            surface.BaseColor = (_Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2_Vector4.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2_Float;
            surface.AlphaClipThreshold = _Property_e8300f3c175a8584b8b8045b9854d400_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
             float4 color;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
             float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 color : INTERP1;
             float3 positionWS : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.color.xyzw = input.color;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.color = input.color.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaClipThreshold;
        float _ReadAlbedo;
        float4 _ParticleMask_TexelSize;
        float4 _TilingandOffset;
        float4 _ParticleColor;
        float4 _ParticleNormal_TexelSize;
        float _ParticleNormalScale;
        float _AO;
        float Metallic;
        float _Smoothness;
        float _CullFarStart;
        float _CullFarDistance;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParticleMask);
        SAMPLER(sampler_ParticleMask);
        TEXTURE2D(_ParticleNormal);
        SAMPLER(sampler_ParticleNormal);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4 = _ParticleColor;
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_R_1_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[0];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_G_2_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[1];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_B_3_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[2];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_A_4_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[3];
            UnityTexture2D _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_ParticleMask);
            float4 _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4 = _TilingandOffset;
            float _Split_0f89628531900280a6fdfeed464d7db0_R_1_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[0];
            float _Split_0f89628531900280a6fdfeed464d7db0_G_2_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[1];
            float _Split_0f89628531900280a6fdfeed464d7db0_B_3_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[2];
            float _Split_0f89628531900280a6fdfeed464d7db0_A_4_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[3];
            float4 _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4_Vector4;
            float3 _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5_Vector3;
            float2 _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6_Vector2;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_B_3_Float, _Split_0f89628531900280a6fdfeed464d7db0_A_4_Float, 0, 0, _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4_Vector4, _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5_Vector3, _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6_Vector2);
            float4 _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4_Vector4;
            float3 _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5_Vector3;
            float2 _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6_Vector2;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_R_1_Float, _Split_0f89628531900280a6fdfeed464d7db0_G_2_Float, 0, 0, _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4_Vector4, _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5_Vector3, _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6_Vector2);
            float4 _UV_426d4b83acf75988818b968670a6c706_Out_0_Vector4 = IN.uv0;
            float2 _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Combine_a4549e90842d0d89a5980eed4127a17b_RG_6_Vector2, (_UV_426d4b83acf75988818b968670a6c706_Out_0_Vector4.xy), _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2_Vector2);
            float2 _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2;
            Unity_Add_float2(_Combine_b5e51e12d953b181b56901d50c50cd23_RG_6_Vector2, _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2_Vector2, _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2);
            float4 _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D.tex, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D.samplerstate, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2) );
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_R_4_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.r;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_G_5_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.g;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_B_6_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.b;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.a;
            float _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2_Float;
            Unity_Multiply_float_float(_Split_b3351ea0323f53819c49f9ebc3297dfd_A_4_Float, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7_Float, _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2_Float);
            float _Split_23be1e5860e84d8aa9ab147605cf804c_R_1_Float = IN.VertexColor[0];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_G_2_Float = IN.VertexColor[1];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_B_3_Float = IN.VertexColor[2];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_A_4_Float = IN.VertexColor[3];
            float _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2_Float, _Split_23be1e5860e84d8aa9ab147605cf804c_A_4_Float, _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2_Float);
            float _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2_Float;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2_Float);
            float _Property_560bbe7f2d950d86813d2af8016de375_Out_0_Float = _CullFarStart;
            float _Subtract_5373207144af5c888442613c746c85a5_Out_2_Float;
            Unity_Subtract_float(_Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2_Float, _Property_560bbe7f2d950d86813d2af8016de375_Out_0_Float, _Subtract_5373207144af5c888442613c746c85a5_Out_2_Float);
            float _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0_Float = _CullFarDistance;
            float _Divide_009a8503c50859889678476fb7b96335_Out_2_Float;
            Unity_Divide_float(_Subtract_5373207144af5c888442613c746c85a5_Out_2_Float, _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0_Float, _Divide_009a8503c50859889678476fb7b96335_Out_2_Float);
            float _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1_Float;
            Unity_Saturate_float(_Divide_009a8503c50859889678476fb7b96335_Out_2_Float, _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1_Float);
            float _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3_Float;
            Unity_Clamp_float(_Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1_Float, 0, 1, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3_Float);
            float _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2_Float, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3_Float, _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2_Float);
            float _Property_e8300f3c175a8584b8b8045b9854d400_Out_0_Float = _AlphaClipThreshold;
            surface.Alpha = _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2_Float;
            surface.AlphaClipThreshold = _Property_e8300f3c175a8584b8b8045b9854d400_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
             float4 color;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
             float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 color : INTERP1;
             float3 positionWS : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.color.xyzw = input.color;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.color = input.color.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaClipThreshold;
        float _ReadAlbedo;
        float4 _ParticleMask_TexelSize;
        float4 _TilingandOffset;
        float4 _ParticleColor;
        float4 _ParticleNormal_TexelSize;
        float _ParticleNormalScale;
        float _AO;
        float Metallic;
        float _Smoothness;
        float _CullFarStart;
        float _CullFarDistance;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParticleMask);
        SAMPLER(sampler_ParticleMask);
        TEXTURE2D(_ParticleNormal);
        SAMPLER(sampler_ParticleNormal);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4 = _ParticleColor;
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_R_1_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[0];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_G_2_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[1];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_B_3_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[2];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_A_4_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[3];
            UnityTexture2D _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_ParticleMask);
            float4 _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4 = _TilingandOffset;
            float _Split_0f89628531900280a6fdfeed464d7db0_R_1_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[0];
            float _Split_0f89628531900280a6fdfeed464d7db0_G_2_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[1];
            float _Split_0f89628531900280a6fdfeed464d7db0_B_3_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[2];
            float _Split_0f89628531900280a6fdfeed464d7db0_A_4_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[3];
            float4 _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4_Vector4;
            float3 _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5_Vector3;
            float2 _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6_Vector2;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_B_3_Float, _Split_0f89628531900280a6fdfeed464d7db0_A_4_Float, 0, 0, _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4_Vector4, _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5_Vector3, _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6_Vector2);
            float4 _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4_Vector4;
            float3 _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5_Vector3;
            float2 _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6_Vector2;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_R_1_Float, _Split_0f89628531900280a6fdfeed464d7db0_G_2_Float, 0, 0, _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4_Vector4, _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5_Vector3, _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6_Vector2);
            float4 _UV_426d4b83acf75988818b968670a6c706_Out_0_Vector4 = IN.uv0;
            float2 _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Combine_a4549e90842d0d89a5980eed4127a17b_RG_6_Vector2, (_UV_426d4b83acf75988818b968670a6c706_Out_0_Vector4.xy), _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2_Vector2);
            float2 _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2;
            Unity_Add_float2(_Combine_b5e51e12d953b181b56901d50c50cd23_RG_6_Vector2, _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2_Vector2, _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2);
            float4 _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D.tex, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D.samplerstate, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2) );
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_R_4_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.r;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_G_5_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.g;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_B_6_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.b;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.a;
            float _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2_Float;
            Unity_Multiply_float_float(_Split_b3351ea0323f53819c49f9ebc3297dfd_A_4_Float, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7_Float, _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2_Float);
            float _Split_23be1e5860e84d8aa9ab147605cf804c_R_1_Float = IN.VertexColor[0];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_G_2_Float = IN.VertexColor[1];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_B_3_Float = IN.VertexColor[2];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_A_4_Float = IN.VertexColor[3];
            float _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2_Float, _Split_23be1e5860e84d8aa9ab147605cf804c_A_4_Float, _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2_Float);
            float _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2_Float;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2_Float);
            float _Property_560bbe7f2d950d86813d2af8016de375_Out_0_Float = _CullFarStart;
            float _Subtract_5373207144af5c888442613c746c85a5_Out_2_Float;
            Unity_Subtract_float(_Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2_Float, _Property_560bbe7f2d950d86813d2af8016de375_Out_0_Float, _Subtract_5373207144af5c888442613c746c85a5_Out_2_Float);
            float _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0_Float = _CullFarDistance;
            float _Divide_009a8503c50859889678476fb7b96335_Out_2_Float;
            Unity_Divide_float(_Subtract_5373207144af5c888442613c746c85a5_Out_2_Float, _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0_Float, _Divide_009a8503c50859889678476fb7b96335_Out_2_Float);
            float _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1_Float;
            Unity_Saturate_float(_Divide_009a8503c50859889678476fb7b96335_Out_2_Float, _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1_Float);
            float _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3_Float;
            Unity_Clamp_float(_Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1_Float, 0, 1, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3_Float);
            float _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2_Float, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3_Float, _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2_Float);
            float _Property_e8300f3c175a8584b8b8045b9854d400_Out_0_Float = _AlphaClipThreshold;
            surface.Alpha = _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2_Float;
            surface.AlphaClipThreshold = _Property_e8300f3c175a8584b8b8045b9854d400_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
             float4 color;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
             float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 color : INTERP1;
             float3 positionWS : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.color.xyzw = input.color;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.color = input.color.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _AlphaClipThreshold;
        float _ReadAlbedo;
        float4 _ParticleMask_TexelSize;
        float4 _TilingandOffset;
        float4 _ParticleColor;
        float4 _ParticleNormal_TexelSize;
        float _ParticleNormalScale;
        float _AO;
        float Metallic;
        float _Smoothness;
        float _CullFarStart;
        float _CullFarDistance;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParticleMask);
        SAMPLER(sampler_ParticleMask);
        TEXTURE2D(_ParticleNormal);
        SAMPLER(sampler_ParticleNormal);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_9b33c3a3dd587d81bcaadf5c3e8e2139_Out_0_Boolean = _ReadAlbedo;
            float4 _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4 = _ParticleColor;
            UnityTexture2D _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_ParticleMask);
            float4 _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4 = _TilingandOffset;
            float _Split_0f89628531900280a6fdfeed464d7db0_R_1_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[0];
            float _Split_0f89628531900280a6fdfeed464d7db0_G_2_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[1];
            float _Split_0f89628531900280a6fdfeed464d7db0_B_3_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[2];
            float _Split_0f89628531900280a6fdfeed464d7db0_A_4_Float = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0_Vector4[3];
            float4 _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4_Vector4;
            float3 _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5_Vector3;
            float2 _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6_Vector2;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_B_3_Float, _Split_0f89628531900280a6fdfeed464d7db0_A_4_Float, 0, 0, _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4_Vector4, _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5_Vector3, _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6_Vector2);
            float4 _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4_Vector4;
            float3 _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5_Vector3;
            float2 _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6_Vector2;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_R_1_Float, _Split_0f89628531900280a6fdfeed464d7db0_G_2_Float, 0, 0, _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4_Vector4, _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5_Vector3, _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6_Vector2);
            float4 _UV_426d4b83acf75988818b968670a6c706_Out_0_Vector4 = IN.uv0;
            float2 _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Combine_a4549e90842d0d89a5980eed4127a17b_RG_6_Vector2, (_UV_426d4b83acf75988818b968670a6c706_Out_0_Vector4.xy), _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2_Vector2);
            float2 _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2;
            Unity_Add_float2(_Combine_b5e51e12d953b181b56901d50c50cd23_RG_6_Vector2, _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2_Vector2, _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2);
            float4 _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D.tex, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D.samplerstate, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0_Texture2D.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2_Vector2) );
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_R_4_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.r;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_G_5_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.g;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_B_6_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.b;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7_Float = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4.a;
            float4 _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0_Vector4, _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2_Vector4);
            float4 _Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3_Vector4;
            Unity_Branch_float4(_Property_9b33c3a3dd587d81bcaadf5c3e8e2139_Out_0_Boolean, _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2_Vector4, _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4, _Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3_Vector4);
            float4 _Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3_Vector4, IN.VertexColor, _Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2_Vector4);
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_R_1_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[0];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_G_2_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[1];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_B_3_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[2];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_A_4_Float = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0_Vector4[3];
            float _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2_Float;
            Unity_Multiply_float_float(_Split_b3351ea0323f53819c49f9ebc3297dfd_A_4_Float, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7_Float, _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2_Float);
            float _Split_23be1e5860e84d8aa9ab147605cf804c_R_1_Float = IN.VertexColor[0];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_G_2_Float = IN.VertexColor[1];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_B_3_Float = IN.VertexColor[2];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_A_4_Float = IN.VertexColor[3];
            float _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2_Float, _Split_23be1e5860e84d8aa9ab147605cf804c_A_4_Float, _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2_Float);
            float _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2_Float;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2_Float);
            float _Property_560bbe7f2d950d86813d2af8016de375_Out_0_Float = _CullFarStart;
            float _Subtract_5373207144af5c888442613c746c85a5_Out_2_Float;
            Unity_Subtract_float(_Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2_Float, _Property_560bbe7f2d950d86813d2af8016de375_Out_0_Float, _Subtract_5373207144af5c888442613c746c85a5_Out_2_Float);
            float _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0_Float = _CullFarDistance;
            float _Divide_009a8503c50859889678476fb7b96335_Out_2_Float;
            Unity_Divide_float(_Subtract_5373207144af5c888442613c746c85a5_Out_2_Float, _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0_Float, _Divide_009a8503c50859889678476fb7b96335_Out_2_Float);
            float _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1_Float;
            Unity_Saturate_float(_Divide_009a8503c50859889678476fb7b96335_Out_2_Float, _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1_Float);
            float _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3_Float;
            Unity_Clamp_float(_Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1_Float, 0, 1, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3_Float);
            float _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2_Float, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3_Float, _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2_Float);
            float _Property_e8300f3c175a8584b8b8045b9854d400_Out_0_Float = _AlphaClipThreshold;
            surface.BaseColor = (_Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2_Vector4.xyz);
            surface.Alpha = _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2_Float;
            surface.AlphaClipThreshold = _Property_e8300f3c175a8584b8b8045b9854d400_Out_0_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}