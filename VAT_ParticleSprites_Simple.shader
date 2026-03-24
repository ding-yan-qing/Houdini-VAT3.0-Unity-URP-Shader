Shader "Custom/VAT_ParticleSprites_Simple"
{
    Properties
    {
        [ToggleUI]_B_autoPlayback("Auto Playback", Float) = 1
        _gameTimeAtFirstFrame("Game Time at First Frame", Float) = 0
        _displayFrame("Display Frame", Float) = 1
        _playbackSpeed("Playback Speed", Float) = 1
        _houdiniFPS("Houdini FPS", Float) = 60
        [ToggleUI]_B_interpolate("Interframe Interpolation", Float) = 0
        [ToggleUI]_B_interpolateCol("Interpolate Color", Float) = 0
        [ToggleUI]_B_interpolateSpareCol("Interpolate Spare Color", Float) = 0
        [ToggleUI]_B_surfaceNormals("Support Surface Normal Maps", Float) = 1
        [ToggleUI]_B_twoSidedNorms("Two Sided Normals", Float) = 0
        [NoScaleOffset]_posTexture("Position Texture", 2D) = "white" {}
        [NoScaleOffset]_posTexture2("Position Texture 2", 2D) = "white" {}
        [NoScaleOffset]_colTexture("Color Texture", 2D) = "white" {}
        [NoScaleOffset]_spareColTexture("Spare Color Texture", 2D) = "white" {}
        [ToggleUI]_B_pscaleAreInPosA("Particle Scales Are in Position Alpha", Float) = 1
        _globalPscaleMul("Global Particle Scale Multiplier", Float) = 1
        _widthBaseScale("Particle Width Base Scale", Float) = 0.2
        _heightBaseScale("Particle Height Base Scale", Float) = 0.2
        _particleTexUScale("Particle Texture U Scale", Float) = 1
        _particleTexVScale("Particle Texture V Scale", Float) = 1
        [ToggleUI]_B_spinFromHeading("Compute Spin from Heading Vector", Float) = 0
        _scaleByVelAmount("Scale by Velocity Amount", Float) = 1
        _spinPhase("Particle Spin Phase", Float) = 0
        [ToggleUI]_B_hideOverlappingOrigin("Hide Particles Overlapping Object Origin", Float) = 1
        _originRadius("Origin Effective Radius", Float) = 0.02
        [Toggle(_B_LOAD_COL_TEX)]_B_LOAD_COL_TEX("Load Color Texture", Float) = 1
        [Toggle(_B_CAN_SPIN)]_B_CAN_SPIN("Particles Can Spin", Float) = 0
        [Toggle(_B_LOAD_NORM_TEX)]_B_LOAD_NORM_TEX("Load Surface Normal Map", Float) = 0
        [Toggle(_B_LOAD_POS_TWO_TEX)]_B_LOAD_POS_TWO_TEX("Positions Require Two Textures", Float) = 0
        _frameCount("Frame Count", Float) = 0
        _boundMaxX("Bound Max X", Float) = 0
        _boundMaxY("Bound Max Y", Float) = 0
        _boundMaxZ("Bound Max Z", Float) = 0
        _boundMinX("Bound Min X", Float) = 0
        _boundMinY("Bound Min Y", Float) = 0
        _boundMinZ("Bound Min Z", Float) = 0
        [NonModifiableTextureData][Normal][NoScaleOffset]_SampleTexture2D_72ab43ee7e5b4ff3acd5a9fb57f150dc_Texture_1_Texture2D("Texture2D", 2D) = "bump" {}
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
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue"="Geometry"
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
        Blend One Zero
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
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _FORWARD_PLUS
        #pragma shader_feature_local_vertex _ _B_LOAD_POS_TWO_TEX
        #pragma shader_feature_local_vertex _ _B_CAN_SPIN
        #pragma shader_feature_local _ _B_LOAD_COL_TEX
        #pragma shader_feature_local_fragment _ _B_LOAD_NORM_TEX
        
        #if defined(_B_LOAD_POS_TWO_TEX) && defined(_B_CAN_SPIN) && defined(_B_LOAD_COL_TEX) && defined(_B_LOAD_NORM_TEX)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_B_LOAD_POS_TWO_TEX) && defined(_B_CAN_SPIN) && defined(_B_LOAD_COL_TEX)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_B_LOAD_POS_TWO_TEX) && defined(_B_CAN_SPIN) && defined(_B_LOAD_NORM_TEX)
            #define KEYWORD_PERMUTATION_2
        #elif defined(_B_LOAD_POS_TWO_TEX) && defined(_B_CAN_SPIN)
            #define KEYWORD_PERMUTATION_3
        #elif defined(_B_LOAD_POS_TWO_TEX) && defined(_B_LOAD_COL_TEX) && defined(_B_LOAD_NORM_TEX)
            #define KEYWORD_PERMUTATION_4
        #elif defined(_B_LOAD_POS_TWO_TEX) && defined(_B_LOAD_COL_TEX)
            #define KEYWORD_PERMUTATION_5
        #elif defined(_B_LOAD_POS_TWO_TEX) && defined(_B_LOAD_NORM_TEX)
            #define KEYWORD_PERMUTATION_6
        #elif defined(_B_LOAD_POS_TWO_TEX)
            #define KEYWORD_PERMUTATION_7
        #elif defined(_B_CAN_SPIN) && defined(_B_LOAD_COL_TEX) && defined(_B_LOAD_NORM_TEX)
            #define KEYWORD_PERMUTATION_8
        #elif defined(_B_CAN_SPIN) && defined(_B_LOAD_COL_TEX)
            #define KEYWORD_PERMUTATION_9
        #elif defined(_B_CAN_SPIN) && defined(_B_LOAD_NORM_TEX)
            #define KEYWORD_PERMUTATION_10
        #elif defined(_B_CAN_SPIN)
            #define KEYWORD_PERMUTATION_11
        #elif defined(_B_LOAD_COL_TEX) && defined(_B_LOAD_NORM_TEX)
            #define KEYWORD_PERMUTATION_12
        #elif defined(_B_LOAD_COL_TEX)
            #define KEYWORD_PERMUTATION_13
        #elif defined(_B_LOAD_NORM_TEX)
            #define KEYWORD_PERMUTATION_14
        #else
            #define KEYWORD_PERMUTATION_15
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        #define _NORMALMAP 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        #define _NORMAL_DROPOFF_OS 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        #define ATTRIBUTES_NEED_TEXCOORD2
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        #define VARYINGS_NEED_NORMAL_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        #define VARYINGS_NEED_TANGENT_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        #define VARYINGS_NEED_SHADOW_COORD
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        #define VARYINGS_NEED_CULLFACE
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        
        
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
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float4 uv1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float4 uv2 : TEXCOORD2;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float4 tangentWS;
            #endif
            #if defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float2 staticLightmapUV;
            #endif
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float2 dynamicLightmapUV;
            #endif
            #endif
            #if !defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float3 sh;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float4 fogFactorAndVertexLight;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float4 shadowCoord;
            #endif
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float4 Color_ToFragment;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float2 ParticleUV_ToFragment;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float3 WorldSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float3 WorldSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float FaceSign;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float4 Color_ToFragment;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float2 ParticleUV_ToFragment;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float4 uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float3 TimeParameters;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float2 staticLightmapUV : INTERP0;
            #endif
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #endif
            #if !defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float3 sh : INTERP2;
            #endif
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float4 shadowCoord : INTERP3;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float4 tangentWS : INTERP4;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float4 fogFactorAndVertexLight : INTERP5;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float4 Color_ToFragment : INTERP6;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float4 packed_positionWS_ParticleUV_ToFragmentx : INTERP7;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float4 packed_normalWS_ParticleUV_ToFragmenty : INTERP8;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
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
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.Color_ToFragment.xyzw = input.Color_ToFragment;
            output.packed_positionWS_ParticleUV_ToFragmentx.xyz = input.positionWS;
            output.packed_positionWS_ParticleUV_ToFragmentx.w = input.ParticleUV_ToFragment.x;
            output.packed_normalWS_ParticleUV_ToFragmenty.xyz = input.normalWS;
            output.packed_normalWS_ParticleUV_ToFragmenty.w = input.ParticleUV_ToFragment.y;
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
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.Color_ToFragment = input.Color_ToFragment.xyzw;
            output.positionWS = input.packed_positionWS_ParticleUV_ToFragmentx.xyz;
            output.ParticleUV_ToFragment.x = input.packed_positionWS_ParticleUV_ToFragmentx.w;
            output.normalWS = input.packed_normalWS_ParticleUV_ToFragmenty.xyz;
            output.ParticleUV_ToFragment.y = input.packed_normalWS_ParticleUV_ToFragmenty.w;
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
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _SampleTexture2D_72ab43ee7e5b4ff3acd5a9fb57f150dc_Texture_1_Texture2D_TexelSize;
        float _gameTimeAtFirstFrame;
        float _B_interpolate;
        float _B_interpolateCol;
        float _B_interpolateSpareCol;
        float _B_autoPlayback;
        float _displayFrame;
        float _B_surfaceNormals;
        float4 _posTexture_TexelSize;
        float4 _posTexture2_TexelSize;
        float4 _colTexture_TexelSize;
        float4 _spareColTexture_TexelSize;
        float _playbackSpeed;
        float _houdiniFPS;
        float _frameCount;
        float _boundMaxX;
        float _boundMaxY;
        float _boundMaxZ;
        float _boundMinX;
        float _boundMinY;
        float _boundMinZ;
        float _B_twoSidedNorms;
        float _B_pscaleAreInPosA;
        float _globalPscaleMul;
        float _widthBaseScale;
        float _heightBaseScale;
        float _particleTexUScale;
        float _particleTexVScale;
        float _B_spinFromHeading;
        float _scaleByVelAmount;
        float _spinPhase;
        float _B_hideOverlappingOrigin;
        float _originRadius;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_SampleTexture2D_72ab43ee7e5b4ff3acd5a9fb57f150dc_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_72ab43ee7e5b4ff3acd5a9fb57f150dc_Texture_1_Texture2D);
        TEXTURE2D(_posTexture);
        SAMPLER(sampler_posTexture);
        TEXTURE2D(_posTexture2);
        SAMPLER(sampler_posTexture2);
        TEXTURE2D(_colTexture);
        SAMPLER(sampler_colTexture);
        TEXTURE2D(_spareColTexture);
        SAMPLER(sampler_spareColTexture);
        
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
        
        void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
        {
             float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
             Out = lerp(Min, Max, randomno);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Comparison_LessOrEqual_float(float A, float B, out float Out)
        {
            Out = A <= B ? 1 : 0;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        void Unity_Ceiling_float(float In, out float Out)
        {
            Out = ceil(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Floor_float(float In, out float Out)
        {
            Out = floor(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Fraction_float(float In, out float Out)
        {
            Out = frac(In);
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Modulo_float(float A, float B, out float Out)
        {
            Out = fmod(A, B);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Comparison_GreaterOrEqual_float(float A, float B, out float Out)
        {
            Out = A >= B ? 1 : 0;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Cosine_float(float In, out float Out)
        {
            Out = cos(In);
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Sign_float(float In, out float Out)
        {
            Out = sign(In);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        struct Bindings_VATParticleSpritesSSG_0c58eccff9a0bb343a88b72ec3ca197c_float
        {
        half4 uv0;
        half4 uv1;
        };
        
        void SG_VATParticleSpritesSSG_0c58eccff9a0bb343a88b72ec3ca197c_float(float Boolean_c6d95f0261604ee2b8dc25eb23063490, float _Game_Time_at_First_Frame, float Vector1_74248139a46a4241857eb5ea760cd76e, float Vector1_616132c8d66348e59f938fc7754536ce, float Vector1_779a70dd0d5f497682265941a24919dc, float _Interframe_Interpolation, float _Interpolate_Color, float _Interpolate_Spare_Color, float Boolean_452ee7b85a19421f84aedbe953332219, UnityTexture2D Texture2D_3449ceac7550445ab7147121e9c2dda7, UnityTexture2D Texture2D_754e74d5eb0c4d92affb773f974ae100, UnityTexture2D Texture2D_e2d9e8f7eef04f15ad7d3a47dcf08a66, UnityTexture2D Texture2D_dc3c6e2909694510a2bce97b5d611620, float _Particle_Scales_Are_in_Position_Alpha, float _Global_Particle_Scale_Multiplier, float _Particle_Width_Base_Scale, float _Particle_Height_Base_Scale, float _Particle_Texture_U_Scale, float _Particle_Texture_V_Scale, float _Compute_Spin_from_Heading_Vector, float _Scale_by_Velocity_Amount, float _Particle_Spin_Phase, float _Hide_Particles_Overlapping_Object_Origin, float _Origin_Effective_Radius, float Vector1_408ce11275b14434bf1948469ee3966c, float Vector1_ccbea577a96e404faf689f6aec5b88a1, float Vector1_dd8d8ffd66fb4dc8b22b2f2bf50a8045, float Vector1_777dc7214cdf45828b8dd360191bde10, float Vector1_d98d868368384a49a83c61a9e9723b40, float Vector1_1256f3f5f1ae4569984c02d8e880fbc1, float Vector1_4373686283fd4fe0a811860575a0582b, float _Input_Time, float _Per_Particle_Random_Velocity_Scale, float _Per_Particle_Random_Spin_Speed, float _Additional_Particle_Scale_Uniform_Multiplier, float3 Vector3_d2bfcc1e36e143fb8998c41bd35e34ce, int _View_Space_XY_Vector_Source, int _Spin_Phase_Source, Bindings_VATParticleSpritesSSG_0c58eccff9a0bb343a88b72ec3ca197c_float IN, out float3 Out_Position_1, out float3 Out_Normal_2, out float3 Out_Tangent_3, out float3 Out_ColorRGB_4, out float Out_ColorAlpha_6, out float4 Out_SpareColorRGBA_5, out float2 Out_ParticleTextureUV_19, out float Out_SamplingVThisFrame_8, out float Out_SamplingVNextFrame_9, out float3 Out_ParticleLocalPositionThisFrame_10, out float3 Out_ParticleLocalPositionNextFrame_11, out float Out_DataInPositionAlphaThisFrame_12, out float Out_DataInPositionAlphaNextFrame_13, out float4 Out_ColorRGBAThisFrame_17, out float4 Out_ColorRGBANextFrame_14, out float4 Out_SpareColorRGBAThisFrame_18, out float4 Out_SpareColorRGBANextFrame_15, out float Out_InterframeInterpolationAlpha_16, out float Out_AnimationProgressThisFrame_21, out float Out_AnimationProgressNextFrame_22, out float3 Out_ParticleLocalPositionFinal_20)
        {
        float4 _UV_6862cbe6995046fc899d32f8ba0baa6d_Out_0_Vector4 = IN.uv1;
        float _Split_f0e64cc1768d45dd8b151ea65f78fde0_R_1_Float = _UV_6862cbe6995046fc899d32f8ba0baa6d_Out_0_Vector4[0];
        float _Split_f0e64cc1768d45dd8b151ea65f78fde0_G_2_Float = _UV_6862cbe6995046fc899d32f8ba0baa6d_Out_0_Vector4[1];
        float _Split_f0e64cc1768d45dd8b151ea65f78fde0_B_3_Float = _UV_6862cbe6995046fc899d32f8ba0baa6d_Out_0_Vector4[2];
        float _Split_f0e64cc1768d45dd8b151ea65f78fde0_A_4_Float = _UV_6862cbe6995046fc899d32f8ba0baa6d_Out_0_Vector4[3];
        float _Comparison_05395f032a9d41f883deb216f4f78844_Out_2_Boolean;
        Unity_Comparison_LessOrEqual_float(_Split_f0e64cc1768d45dd8b151ea65f78fde0_G_2_Float, 0.1, _Comparison_05395f032a9d41f883deb216f4f78844_Out_2_Boolean);
        float4 _UV_4b2e28addcd64cb8a84ecef97f051c7d_Out_0_Vector4 = IN.uv0;
        float _Split_93694a90fa074f4ca9b406827dd0f959_R_1_Float = _UV_4b2e28addcd64cb8a84ecef97f051c7d_Out_0_Vector4[0];
        float _Split_93694a90fa074f4ca9b406827dd0f959_G_2_Float = _UV_4b2e28addcd64cb8a84ecef97f051c7d_Out_0_Vector4[1];
        float _Split_93694a90fa074f4ca9b406827dd0f959_B_3_Float = _UV_4b2e28addcd64cb8a84ecef97f051c7d_Out_0_Vector4[2];
        float _Split_93694a90fa074f4ca9b406827dd0f959_A_4_Float = _UV_4b2e28addcd64cb8a84ecef97f051c7d_Out_0_Vector4[3];
        float _Subtract_05d51b931861456793c0a2eedb288a0f_Out_2_Float;
        Unity_Subtract_float(_Split_93694a90fa074f4ca9b406827dd0f959_R_1_Float, 0.5, _Subtract_05d51b931861456793c0a2eedb288a0f_Out_2_Float);
        float _Property_4e59012634c54df9a62c08063edbd7c7_Out_0_Boolean = _Compute_Spin_from_Heading_Vector;
        float _Property_a0ba1f43faf044b68041f47417cbd7af_Out_0_Boolean = _Interframe_Interpolation;
        float _Property_eadb5ba513a6498e8244047c79345758_Out_0_Boolean = _Interpolate_Color;
        float _And_f3054b8d20aa48bfae7a5d53c8acc3cc_Out_2_Boolean;
        Unity_And_float(_Property_a0ba1f43faf044b68041f47417cbd7af_Out_0_Boolean, _Property_eadb5ba513a6498e8244047c79345758_Out_0_Boolean, _And_f3054b8d20aa48bfae7a5d53c8acc3cc_Out_2_Boolean);
        UnityTexture2D _Property_2aa42de9e6e04e418c75ca022cb8072c_Out_0_Texture2D = Texture2D_e2d9e8f7eef04f15ad7d3a47dcf08a66;
        float4 _UV_6799e03a023e45e3845a013c09e28a23_Out_0_Vector4 = IN.uv1;
        float _Split_7157ab551da04777b88f5fa2a8cb91d2_R_1_Float = _UV_6799e03a023e45e3845a013c09e28a23_Out_0_Vector4[0];
        float _Split_7157ab551da04777b88f5fa2a8cb91d2_G_2_Float = _UV_6799e03a023e45e3845a013c09e28a23_Out_0_Vector4[1];
        float _Split_7157ab551da04777b88f5fa2a8cb91d2_B_3_Float = _UV_6799e03a023e45e3845a013c09e28a23_Out_0_Vector4[2];
        float _Split_7157ab551da04777b88f5fa2a8cb91d2_A_4_Float = _UV_6799e03a023e45e3845a013c09e28a23_Out_0_Vector4[3];
        float _Property_59601290c1414961893ef4a6538b3854_Out_0_Float = Vector1_d98d868368384a49a83c61a9e9723b40;
        float _Property_c0406d5f413f4a77a2942e83d6a42255_Out_0_Float = Vector1_1256f3f5f1ae4569984c02d8e880fbc1;
        float _Property_f22990298caa41e6b1859596db73e4f2_Out_0_Float = Vector1_4373686283fd4fe0a811860575a0582b;
        float4 _Combine_b7dc50f2401c46dca6eed4b19e0862d8_RGBA_4_Vector4;
        float3 _Combine_b7dc50f2401c46dca6eed4b19e0862d8_RGB_5_Vector3;
        float2 _Combine_b7dc50f2401c46dca6eed4b19e0862d8_RG_6_Vector2;
        Unity_Combine_float(_Property_59601290c1414961893ef4a6538b3854_Out_0_Float, _Property_c0406d5f413f4a77a2942e83d6a42255_Out_0_Float, _Property_f22990298caa41e6b1859596db73e4f2_Out_0_Float, 0, _Combine_b7dc50f2401c46dca6eed4b19e0862d8_RGBA_4_Vector4, _Combine_b7dc50f2401c46dca6eed4b19e0862d8_RGB_5_Vector3, _Combine_b7dc50f2401c46dca6eed4b19e0862d8_RG_6_Vector2);
        float3 _Vector3_0eb7ffa0098e4750927324bbfad3f6fc_Out_0_Vector3 = float3(10, 10, 10);
        float3 _Multiply_0b6e25661079480989cd42d5c79db7ec_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Combine_b7dc50f2401c46dca6eed4b19e0862d8_RGB_5_Vector3, _Vector3_0eb7ffa0098e4750927324bbfad3f6fc_Out_0_Vector3, _Multiply_0b6e25661079480989cd42d5c79db7ec_Out_2_Vector3);
        float _Split_f748d5d3b6004c4cbb1ac014769880d9_R_1_Float = _Multiply_0b6e25661079480989cd42d5c79db7ec_Out_2_Vector3[0];
        float _Split_f748d5d3b6004c4cbb1ac014769880d9_G_2_Float = _Multiply_0b6e25661079480989cd42d5c79db7ec_Out_2_Vector3[1];
        float _Split_f748d5d3b6004c4cbb1ac014769880d9_B_3_Float = _Multiply_0b6e25661079480989cd42d5c79db7ec_Out_2_Vector3[2];
        float _Split_f748d5d3b6004c4cbb1ac014769880d9_A_4_Float = 0;
        float _Ceiling_4a89909a89be4b7cbb1020b457413672_Out_1_Float;
        Unity_Ceiling_float(_Split_f748d5d3b6004c4cbb1ac014769880d9_B_3_Float, _Ceiling_4a89909a89be4b7cbb1020b457413672_Out_1_Float);
        float _Subtract_6310376d71fd4a54982f986e4fd538ef_Out_2_Float;
        Unity_Subtract_float(_Ceiling_4a89909a89be4b7cbb1020b457413672_Out_1_Float, _Split_f748d5d3b6004c4cbb1ac014769880d9_B_3_Float, _Subtract_6310376d71fd4a54982f986e4fd538ef_Out_2_Float);
        float _OneMinus_4e4177ba42e5455facc1c738da762c00_Out_1_Float;
        Unity_OneMinus_float(_Subtract_6310376d71fd4a54982f986e4fd538ef_Out_2_Float, _OneMinus_4e4177ba42e5455facc1c738da762c00_Out_1_Float);
        float _Multiply_9b6c319d4f9f4f64afb5813d2670c683_Out_2_Float;
        Unity_Multiply_float_float(_Split_7157ab551da04777b88f5fa2a8cb91d2_R_1_Float, _OneMinus_4e4177ba42e5455facc1c738da762c00_Out_1_Float, _Multiply_9b6c319d4f9f4f64afb5813d2670c683_Out_2_Float);
        float _OneMinus_65096401cdc946379bc7a6883c28c7ff_Out_1_Float;
        Unity_OneMinus_float(_Split_7157ab551da04777b88f5fa2a8cb91d2_G_2_Float, _OneMinus_65096401cdc946379bc7a6883c28c7ff_Out_1_Float);
        float _Property_4217789df82b4209a71e34fd26496efd_Out_0_Float = Vector1_ccbea577a96e404faf689f6aec5b88a1;
        float _Property_29651f35c4064687a81374ee5ad44fc4_Out_0_Float = Vector1_dd8d8ffd66fb4dc8b22b2f2bf50a8045;
        float _Property_189de79eec3e4c0ca1cca21498cd3735_Out_0_Float = Vector1_777dc7214cdf45828b8dd360191bde10;
        float4 _Combine_e339454ae4ab446eab26fa05e5da4305_RGBA_4_Vector4;
        float3 _Combine_e339454ae4ab446eab26fa05e5da4305_RGB_5_Vector3;
        float2 _Combine_e339454ae4ab446eab26fa05e5da4305_RG_6_Vector2;
        Unity_Combine_float(_Property_4217789df82b4209a71e34fd26496efd_Out_0_Float, _Property_29651f35c4064687a81374ee5ad44fc4_Out_0_Float, _Property_189de79eec3e4c0ca1cca21498cd3735_Out_0_Float, 0, _Combine_e339454ae4ab446eab26fa05e5da4305_RGBA_4_Vector4, _Combine_e339454ae4ab446eab26fa05e5da4305_RGB_5_Vector3, _Combine_e339454ae4ab446eab26fa05e5da4305_RG_6_Vector2);
        float3 _Multiply_4d68c8f298964b98b16e66da11ecf8e0_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Combine_e339454ae4ab446eab26fa05e5da4305_RGB_5_Vector3, _Vector3_0eb7ffa0098e4750927324bbfad3f6fc_Out_0_Vector3, _Multiply_4d68c8f298964b98b16e66da11ecf8e0_Out_2_Vector3);
        float _Split_c57cc6c2a4714679969ca15abe6b868d_R_1_Float = _Multiply_4d68c8f298964b98b16e66da11ecf8e0_Out_2_Vector3[0];
        float _Split_c57cc6c2a4714679969ca15abe6b868d_G_2_Float = _Multiply_4d68c8f298964b98b16e66da11ecf8e0_Out_2_Vector3[1];
        float _Split_c57cc6c2a4714679969ca15abe6b868d_B_3_Float = _Multiply_4d68c8f298964b98b16e66da11ecf8e0_Out_2_Vector3[2];
        float _Split_c57cc6c2a4714679969ca15abe6b868d_A_4_Float = 0;
        float _Multiply_4f3363e9a75e410085c77799834cdfb3_Out_2_Float;
        Unity_Multiply_float_float(_Split_c57cc6c2a4714679969ca15abe6b868d_R_1_Float, -1, _Multiply_4f3363e9a75e410085c77799834cdfb3_Out_2_Float);
        float _Floor_f97124efdafb4cf6bcb64b0500ff2bf9_Out_1_Float;
        Unity_Floor_float(_Multiply_4f3363e9a75e410085c77799834cdfb3_Out_2_Float, _Floor_f97124efdafb4cf6bcb64b0500ff2bf9_Out_1_Float);
        float _Subtract_c5cb943ce45a4d19a2d265bc11877583_Out_2_Float;
        Unity_Subtract_float(_Multiply_4f3363e9a75e410085c77799834cdfb3_Out_2_Float, _Floor_f97124efdafb4cf6bcb64b0500ff2bf9_Out_1_Float, _Subtract_c5cb943ce45a4d19a2d265bc11877583_Out_2_Float);
        float _OneMinus_6a6f086f607e42bb8409559598119dd2_Out_1_Float;
        Unity_OneMinus_float(_Subtract_c5cb943ce45a4d19a2d265bc11877583_Out_2_Float, _OneMinus_6a6f086f607e42bb8409559598119dd2_Out_1_Float);
        float _Multiply_5a5cd519af8341f3b924960c61aaffff_Out_2_Float;
        Unity_Multiply_float_float(_OneMinus_65096401cdc946379bc7a6883c28c7ff_Out_1_Float, _OneMinus_6a6f086f607e42bb8409559598119dd2_Out_1_Float, _Multiply_5a5cd519af8341f3b924960c61aaffff_Out_2_Float);
        float _Property_1385c4534688495ba3c996fbab6c5bfa_Out_0_Boolean = Boolean_c6d95f0261604ee2b8dc25eb23063490;
        float _Property_f047319a52a445f79fd24d7ce0cd57e9_Out_0_Float = _Input_Time;
        float _Property_e781f51b129a4403a6ec138e988ccc2b_Out_0_Float = _Game_Time_at_First_Frame;
        float _Subtract_90cee014f87040b5845e668a692884ab_Out_2_Float;
        Unity_Subtract_float(_Property_f047319a52a445f79fd24d7ce0cd57e9_Out_0_Float, _Property_e781f51b129a4403a6ec138e988ccc2b_Out_0_Float, _Subtract_90cee014f87040b5845e668a692884ab_Out_2_Float);
        float _Property_5fc6f43cd22541d08c4627c56b36c0ad_Out_0_Float = Vector1_779a70dd0d5f497682265941a24919dc;
        float _Property_36bda8feb9f646a589a5298330a8efb5_Out_0_Float = Vector1_408ce11275b14434bf1948469ee3966c;
        float _Subtract_908b2be8d0fd42feaf2c2021d682789d_Out_2_Float;
        Unity_Subtract_float(_Property_36bda8feb9f646a589a5298330a8efb5_Out_0_Float, 0.01, _Subtract_908b2be8d0fd42feaf2c2021d682789d_Out_2_Float);
        float _Divide_e4f1fca752404084a4a4c8881fed898e_Out_2_Float;
        Unity_Divide_float(_Property_5fc6f43cd22541d08c4627c56b36c0ad_Out_0_Float, _Subtract_908b2be8d0fd42feaf2c2021d682789d_Out_2_Float, _Divide_e4f1fca752404084a4a4c8881fed898e_Out_2_Float);
        float _Multiply_3c4f5926b6424c9d96b4b2e3a575326d_Out_2_Float;
        Unity_Multiply_float_float(_Subtract_90cee014f87040b5845e668a692884ab_Out_2_Float, _Divide_e4f1fca752404084a4a4c8881fed898e_Out_2_Float, _Multiply_3c4f5926b6424c9d96b4b2e3a575326d_Out_2_Float);
        float _Property_b36ff413394b49caaa18e8e7611655fe_Out_0_Float = Vector1_616132c8d66348e59f938fc7754536ce;
        float _Multiply_c936f9a54f8d4368a6b8c56e0773c8aa_Out_2_Float;
        Unity_Multiply_float_float(_Multiply_3c4f5926b6424c9d96b4b2e3a575326d_Out_2_Float, _Property_b36ff413394b49caaa18e8e7611655fe_Out_0_Float, _Multiply_c936f9a54f8d4368a6b8c56e0773c8aa_Out_2_Float);
        float _Fraction_cfedc089a9174d5e9884fdb029048b87_Out_1_Float;
        Unity_Fraction_float(_Multiply_c936f9a54f8d4368a6b8c56e0773c8aa_Out_2_Float, _Fraction_cfedc089a9174d5e9884fdb029048b87_Out_1_Float);
        float _Multiply_93477a679f5e46959ff06b9cec3b7c01_Out_2_Float;
        Unity_Multiply_float_float(_Fraction_cfedc089a9174d5e9884fdb029048b87_Out_1_Float, _Property_36bda8feb9f646a589a5298330a8efb5_Out_0_Float, _Multiply_93477a679f5e46959ff06b9cec3b7c01_Out_2_Float);
        float _Floor_66dec685fd2d4e17a6c4776858547d83_Out_1_Float;
        Unity_Floor_float(_Multiply_93477a679f5e46959ff06b9cec3b7c01_Out_2_Float, _Floor_66dec685fd2d4e17a6c4776858547d83_Out_1_Float);
        float _Add_1cc37e2034bb4425ac8cb738ac068967_Out_2_Float;
        Unity_Add_float(_Floor_66dec685fd2d4e17a6c4776858547d83_Out_1_Float, 1, _Add_1cc37e2034bb4425ac8cb738ac068967_Out_2_Float);
        float _Property_bbaa27bcd1cd41f2af6709b866a5a0cf_Out_0_Float = Vector1_74248139a46a4241857eb5ea760cd76e;
        float _Floor_f6d0b0e9dd5b411d8abcbddac56f923c_Out_1_Float;
        Unity_Floor_float(_Property_bbaa27bcd1cd41f2af6709b866a5a0cf_Out_0_Float, _Floor_f6d0b0e9dd5b411d8abcbddac56f923c_Out_1_Float);
        float _Branch_49a68901b23c4894bfa1af72c26bfc34_Out_3_Float;
        Unity_Branch_float(_Property_1385c4534688495ba3c996fbab6c5bfa_Out_0_Boolean, _Add_1cc37e2034bb4425ac8cb738ac068967_Out_2_Float, _Floor_f6d0b0e9dd5b411d8abcbddac56f923c_Out_1_Float, _Branch_49a68901b23c4894bfa1af72c26bfc34_Out_3_Float);
        float _Subtract_fb669c5626cc433db25f98f7f0912c63_Out_2_Float;
        Unity_Subtract_float(_Branch_49a68901b23c4894bfa1af72c26bfc34_Out_3_Float, 1, _Subtract_fb669c5626cc433db25f98f7f0912c63_Out_2_Float);
        float _Modulo_0944b94fd8654e1696895b7e282bc6b0_Out_2_Float;
        Unity_Modulo_float(_Subtract_fb669c5626cc433db25f98f7f0912c63_Out_2_Float, _Property_36bda8feb9f646a589a5298330a8efb5_Out_0_Float, _Modulo_0944b94fd8654e1696895b7e282bc6b0_Out_2_Float);
        float _Divide_8940f8cc6cc745d28630ad7d2e2ba98d_Out_2_Float;
        Unity_Divide_float(1, _Property_36bda8feb9f646a589a5298330a8efb5_Out_0_Float, _Divide_8940f8cc6cc745d28630ad7d2e2ba98d_Out_2_Float);
        float _Multiply_8ecd22e403084ffeac4fda6da39b7880_Out_2_Float;
        Unity_Multiply_float_float(_Modulo_0944b94fd8654e1696895b7e282bc6b0_Out_2_Float, _Divide_8940f8cc6cc745d28630ad7d2e2ba98d_Out_2_Float, _Multiply_8ecd22e403084ffeac4fda6da39b7880_Out_2_Float);
        float _Multiply_659a4f149aa848898e31ad47bf8e243a_Out_2_Float;
        Unity_Multiply_float_float(_Multiply_8ecd22e403084ffeac4fda6da39b7880_Out_2_Float, _OneMinus_6a6f086f607e42bb8409559598119dd2_Out_1_Float, _Multiply_659a4f149aa848898e31ad47bf8e243a_Out_2_Float);
        float _Add_1fc73c4ac8ed420895dc22580cd38980_Out_2_Float;
        Unity_Add_float(_Multiply_5a5cd519af8341f3b924960c61aaffff_Out_2_Float, _Multiply_659a4f149aa848898e31ad47bf8e243a_Out_2_Float, _Add_1fc73c4ac8ed420895dc22580cd38980_Out_2_Float);
        float _OneMinus_65f54edfb84f406289b8ea2083a34fcf_Out_1_Float;
        Unity_OneMinus_float(_Add_1fc73c4ac8ed420895dc22580cd38980_Out_2_Float, _OneMinus_65f54edfb84f406289b8ea2083a34fcf_Out_1_Float);
        float4 _Combine_7acf849c0cd74d32b462c613ff310511_RGBA_4_Vector4;
        float3 _Combine_7acf849c0cd74d32b462c613ff310511_RGB_5_Vector3;
        float2 _Combine_7acf849c0cd74d32b462c613ff310511_RG_6_Vector2;
        Unity_Combine_float(_Multiply_9b6c319d4f9f4f64afb5813d2670c683_Out_2_Float, _OneMinus_65f54edfb84f406289b8ea2083a34fcf_Out_1_Float, 0, 0, _Combine_7acf849c0cd74d32b462c613ff310511_RGBA_4_Vector4, _Combine_7acf849c0cd74d32b462c613ff310511_RGB_5_Vector3, _Combine_7acf849c0cd74d32b462c613ff310511_RG_6_Vector2);
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_1c09d18b469d42cba4408dce5ff8f8ab_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_1c09d18b469d42cba4408dce5ff8f8ab_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_2aa42de9e6e04e418c75ca022cb8072c_Out_0_Texture2D.tex, _Property_2aa42de9e6e04e418c75ca022cb8072c_Out_0_Texture2D.samplerstate, _Property_2aa42de9e6e04e418c75ca022cb8072c_Out_0_Texture2D.GetTransformedUV(_Combine_7acf849c0cd74d32b462c613ff310511_RG_6_Vector2), 0);
        #endif
        float _SampleTexture2DLOD_1c09d18b469d42cba4408dce5ff8f8ab_R_5_Float = _SampleTexture2DLOD_1c09d18b469d42cba4408dce5ff8f8ab_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_1c09d18b469d42cba4408dce5ff8f8ab_G_6_Float = _SampleTexture2DLOD_1c09d18b469d42cba4408dce5ff8f8ab_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_1c09d18b469d42cba4408dce5ff8f8ab_B_7_Float = _SampleTexture2DLOD_1c09d18b469d42cba4408dce5ff8f8ab_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_1c09d18b469d42cba4408dce5ff8f8ab_A_8_Float = _SampleTexture2DLOD_1c09d18b469d42cba4408dce5ff8f8ab_RGBA_0_Vector4.a;
        float4 _Vector4_a3433028d24348f4bacad3b6e061f9d5_Out_0_Vector4 = float4(0, 0, 0, 0);
        #if defined(_B_LOAD_COL_TEX)
        float4 _LoadColorTexture_f0d31671e10846148e10ff6f6ddcce87_Out_0_Vector4 = _SampleTexture2DLOD_1c09d18b469d42cba4408dce5ff8f8ab_RGBA_0_Vector4;
        #else
        float4 _LoadColorTexture_f0d31671e10846148e10ff6f6ddcce87_Out_0_Vector4 = _Vector4_a3433028d24348f4bacad3b6e061f9d5_Out_0_Vector4;
        #endif
        float _Modulo_1516a1ff77cb45dc94ae896cd3ac7467_Out_2_Float;
        Unity_Modulo_float(_Branch_49a68901b23c4894bfa1af72c26bfc34_Out_3_Float, _Property_36bda8feb9f646a589a5298330a8efb5_Out_0_Float, _Modulo_1516a1ff77cb45dc94ae896cd3ac7467_Out_2_Float);
        float _Multiply_cfb7fa4be2094158a058e2c60bbf86e0_Out_2_Float;
        Unity_Multiply_float_float(_Modulo_1516a1ff77cb45dc94ae896cd3ac7467_Out_2_Float, _Divide_8940f8cc6cc745d28630ad7d2e2ba98d_Out_2_Float, _Multiply_cfb7fa4be2094158a058e2c60bbf86e0_Out_2_Float);
        float _Multiply_543fbeed774e4177b11301a6f0ddea3e_Out_2_Float;
        Unity_Multiply_float_float(_Multiply_cfb7fa4be2094158a058e2c60bbf86e0_Out_2_Float, _OneMinus_6a6f086f607e42bb8409559598119dd2_Out_1_Float, _Multiply_543fbeed774e4177b11301a6f0ddea3e_Out_2_Float);
        float _Add_ec5f1cbe56ae4bc3adc07cab0b3cada0_Out_2_Float;
        Unity_Add_float(_Multiply_5a5cd519af8341f3b924960c61aaffff_Out_2_Float, _Multiply_543fbeed774e4177b11301a6f0ddea3e_Out_2_Float, _Add_ec5f1cbe56ae4bc3adc07cab0b3cada0_Out_2_Float);
        float _OneMinus_9d3490960b384871a31943f989e612cd_Out_1_Float;
        Unity_OneMinus_float(_Add_ec5f1cbe56ae4bc3adc07cab0b3cada0_Out_2_Float, _OneMinus_9d3490960b384871a31943f989e612cd_Out_1_Float);
        float4 _Combine_a5e0df8891744ba98da48d60a7cffd50_RGBA_4_Vector4;
        float3 _Combine_a5e0df8891744ba98da48d60a7cffd50_RGB_5_Vector3;
        float2 _Combine_a5e0df8891744ba98da48d60a7cffd50_RG_6_Vector2;
        Unity_Combine_float(_Multiply_9b6c319d4f9f4f64afb5813d2670c683_Out_2_Float, _OneMinus_9d3490960b384871a31943f989e612cd_Out_1_Float, 0, 0, _Combine_a5e0df8891744ba98da48d60a7cffd50_RGBA_4_Vector4, _Combine_a5e0df8891744ba98da48d60a7cffd50_RGB_5_Vector3, _Combine_a5e0df8891744ba98da48d60a7cffd50_RG_6_Vector2);
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_c6fd58a33ebf447694f7269eaf935a8b_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_c6fd58a33ebf447694f7269eaf935a8b_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_2aa42de9e6e04e418c75ca022cb8072c_Out_0_Texture2D.tex, _Property_2aa42de9e6e04e418c75ca022cb8072c_Out_0_Texture2D.samplerstate, _Property_2aa42de9e6e04e418c75ca022cb8072c_Out_0_Texture2D.GetTransformedUV(_Combine_a5e0df8891744ba98da48d60a7cffd50_RG_6_Vector2), 0);
        #endif
        float _SampleTexture2DLOD_c6fd58a33ebf447694f7269eaf935a8b_R_5_Float = _SampleTexture2DLOD_c6fd58a33ebf447694f7269eaf935a8b_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_c6fd58a33ebf447694f7269eaf935a8b_G_6_Float = _SampleTexture2DLOD_c6fd58a33ebf447694f7269eaf935a8b_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_c6fd58a33ebf447694f7269eaf935a8b_B_7_Float = _SampleTexture2DLOD_c6fd58a33ebf447694f7269eaf935a8b_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_c6fd58a33ebf447694f7269eaf935a8b_A_8_Float = _SampleTexture2DLOD_c6fd58a33ebf447694f7269eaf935a8b_RGBA_0_Vector4.a;
        #if defined(_B_LOAD_COL_TEX)
        float4 _LoadColorTexture_cc743dddac284c769882b4847ff7576b_Out_0_Vector4 = _SampleTexture2DLOD_c6fd58a33ebf447694f7269eaf935a8b_RGBA_0_Vector4;
        #else
        float4 _LoadColorTexture_cc743dddac284c769882b4847ff7576b_Out_0_Vector4 = _Vector4_a3433028d24348f4bacad3b6e061f9d5_Out_0_Vector4;
        #endif
        float _Branch_eff1171da1214341b2c0342c1c420eaa_Out_3_Float;
        Unity_Branch_float(_Property_1385c4534688495ba3c996fbab6c5bfa_Out_0_Boolean, _Multiply_93477a679f5e46959ff06b9cec3b7c01_Out_2_Float, _Property_bbaa27bcd1cd41f2af6709b866a5a0cf_Out_0_Float, _Branch_eff1171da1214341b2c0342c1c420eaa_Out_3_Float);
        float _Fraction_c62e039143ec48078706377fd40a9b87_Out_1_Float;
        Unity_Fraction_float(_Branch_eff1171da1214341b2c0342c1c420eaa_Out_3_Float, _Fraction_c62e039143ec48078706377fd40a9b87_Out_1_Float);
        float4 _Lerp_711aa73fbc3f4d319b13362297282106_Out_3_Vector4;
        Unity_Lerp_float4(_LoadColorTexture_f0d31671e10846148e10ff6f6ddcce87_Out_0_Vector4, _LoadColorTexture_cc743dddac284c769882b4847ff7576b_Out_0_Vector4, (_Fraction_c62e039143ec48078706377fd40a9b87_Out_1_Float.xxxx), _Lerp_711aa73fbc3f4d319b13362297282106_Out_3_Vector4);
        float4 _Branch_3c68277c1c8744a59f98768785e6c5e7_Out_3_Vector4;
        Unity_Branch_float4(_And_f3054b8d20aa48bfae7a5d53c8acc3cc_Out_2_Boolean, _Lerp_711aa73fbc3f4d319b13362297282106_Out_3_Vector4, _LoadColorTexture_f0d31671e10846148e10ff6f6ddcce87_Out_0_Vector4, _Branch_3c68277c1c8744a59f98768785e6c5e7_Out_3_Vector4);
        float _Split_93caab4b3faa4d40b5266de627a0adec_R_1_Float = _Branch_3c68277c1c8744a59f98768785e6c5e7_Out_3_Vector4[0];
        float _Split_93caab4b3faa4d40b5266de627a0adec_G_2_Float = _Branch_3c68277c1c8744a59f98768785e6c5e7_Out_3_Vector4[1];
        float _Split_93caab4b3faa4d40b5266de627a0adec_B_3_Float = _Branch_3c68277c1c8744a59f98768785e6c5e7_Out_3_Vector4[2];
        float _Split_93caab4b3faa4d40b5266de627a0adec_A_4_Float = _Branch_3c68277c1c8744a59f98768785e6c5e7_Out_3_Vector4[3];
        float _Multiply_ab9af485641e45bd8edc5b7d659c50e0_Out_2_Float;
        Unity_Multiply_float_float(_Split_93caab4b3faa4d40b5266de627a0adec_R_1_Float, -1, _Multiply_ab9af485641e45bd8edc5b7d659c50e0_Out_2_Float);
        float4 _Combine_84c4758ac48844248a82cbc39db0198e_RGBA_4_Vector4;
        float3 _Combine_84c4758ac48844248a82cbc39db0198e_RGB_5_Vector3;
        float2 _Combine_84c4758ac48844248a82cbc39db0198e_RG_6_Vector2;
        Unity_Combine_float(_Multiply_ab9af485641e45bd8edc5b7d659c50e0_Out_2_Float, _Split_93caab4b3faa4d40b5266de627a0adec_G_2_Float, _Split_93caab4b3faa4d40b5266de627a0adec_B_3_Float, 0, _Combine_84c4758ac48844248a82cbc39db0198e_RGBA_4_Vector4, _Combine_84c4758ac48844248a82cbc39db0198e_RGB_5_Vector3, _Combine_84c4758ac48844248a82cbc39db0198e_RG_6_Vector2);
        float _Floor_f206c8cf6fba4f088f8a985a5a2ec4f1_Out_1_Float;
        Unity_Floor_float(_Split_c57cc6c2a4714679969ca15abe6b868d_B_3_Float, _Floor_f206c8cf6fba4f088f8a985a5a2ec4f1_Out_1_Float);
        float _Subtract_77492447a2e24ffa89bf91720c777460_Out_2_Float;
        Unity_Subtract_float(_Split_c57cc6c2a4714679969ca15abe6b868d_B_3_Float, _Floor_f206c8cf6fba4f088f8a985a5a2ec4f1_Out_1_Float, _Subtract_77492447a2e24ffa89bf91720c777460_Out_2_Float);
        float _Comparison_322cfaaadddd4969978d57a8c96084ef_Out_2_Boolean;
        Unity_Comparison_GreaterOrEqual_float(_Subtract_77492447a2e24ffa89bf91720c777460_Out_2_Float, 0.5, _Comparison_322cfaaadddd4969978d57a8c96084ef_Out_2_Boolean);
        UnityTexture2D _Property_7dbd408acfee4e078cd82cbe1e5f572b_Out_0_Texture2D = Texture2D_3449ceac7550445ab7147121e9c2dda7;
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_d92919bca21f48e29f52a6d33023c4aa_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_d92919bca21f48e29f52a6d33023c4aa_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_7dbd408acfee4e078cd82cbe1e5f572b_Out_0_Texture2D.tex, _Property_7dbd408acfee4e078cd82cbe1e5f572b_Out_0_Texture2D.samplerstate, _Property_7dbd408acfee4e078cd82cbe1e5f572b_Out_0_Texture2D.GetTransformedUV(_Combine_a5e0df8891744ba98da48d60a7cffd50_RG_6_Vector2), 0);
        #endif
        float _SampleTexture2DLOD_d92919bca21f48e29f52a6d33023c4aa_R_5_Float = _SampleTexture2DLOD_d92919bca21f48e29f52a6d33023c4aa_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_d92919bca21f48e29f52a6d33023c4aa_G_6_Float = _SampleTexture2DLOD_d92919bca21f48e29f52a6d33023c4aa_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_d92919bca21f48e29f52a6d33023c4aa_B_7_Float = _SampleTexture2DLOD_d92919bca21f48e29f52a6d33023c4aa_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_d92919bca21f48e29f52a6d33023c4aa_A_8_Float = _SampleTexture2DLOD_d92919bca21f48e29f52a6d33023c4aa_RGBA_0_Vector4.a;
        float4 _Combine_3a3a46b2dd084ef5b50d1c94bd1bf662_RGBA_4_Vector4;
        float3 _Combine_3a3a46b2dd084ef5b50d1c94bd1bf662_RGB_5_Vector3;
        float2 _Combine_3a3a46b2dd084ef5b50d1c94bd1bf662_RG_6_Vector2;
        Unity_Combine_float(_SampleTexture2DLOD_d92919bca21f48e29f52a6d33023c4aa_R_5_Float, _SampleTexture2DLOD_d92919bca21f48e29f52a6d33023c4aa_G_6_Float, _SampleTexture2DLOD_d92919bca21f48e29f52a6d33023c4aa_B_7_Float, 0, _Combine_3a3a46b2dd084ef5b50d1c94bd1bf662_RGBA_4_Vector4, _Combine_3a3a46b2dd084ef5b50d1c94bd1bf662_RGB_5_Vector3, _Combine_3a3a46b2dd084ef5b50d1c94bd1bf662_RG_6_Vector2);
        UnityTexture2D _Property_88cc07c51d1d4c2ea2801e86f6a9f044_Out_0_Texture2D = Texture2D_754e74d5eb0c4d92affb773f974ae100;
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_d1665f30f3c74d54b5b2be5e322ee59e_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_d1665f30f3c74d54b5b2be5e322ee59e_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_88cc07c51d1d4c2ea2801e86f6a9f044_Out_0_Texture2D.tex, _Property_88cc07c51d1d4c2ea2801e86f6a9f044_Out_0_Texture2D.samplerstate, _Property_88cc07c51d1d4c2ea2801e86f6a9f044_Out_0_Texture2D.GetTransformedUV(_Combine_a5e0df8891744ba98da48d60a7cffd50_RG_6_Vector2), 0);
        #endif
        float _SampleTexture2DLOD_d1665f30f3c74d54b5b2be5e322ee59e_R_5_Float = _SampleTexture2DLOD_d1665f30f3c74d54b5b2be5e322ee59e_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_d1665f30f3c74d54b5b2be5e322ee59e_G_6_Float = _SampleTexture2DLOD_d1665f30f3c74d54b5b2be5e322ee59e_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_d1665f30f3c74d54b5b2be5e322ee59e_B_7_Float = _SampleTexture2DLOD_d1665f30f3c74d54b5b2be5e322ee59e_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_d1665f30f3c74d54b5b2be5e322ee59e_A_8_Float = _SampleTexture2DLOD_d1665f30f3c74d54b5b2be5e322ee59e_RGBA_0_Vector4.a;
        float4 _Combine_dff050d017d340c2800db94c26ef03c5_RGBA_4_Vector4;
        float3 _Combine_dff050d017d340c2800db94c26ef03c5_RGB_5_Vector3;
        float2 _Combine_dff050d017d340c2800db94c26ef03c5_RG_6_Vector2;
        Unity_Combine_float(_SampleTexture2DLOD_d1665f30f3c74d54b5b2be5e322ee59e_R_5_Float, _SampleTexture2DLOD_d1665f30f3c74d54b5b2be5e322ee59e_G_6_Float, _SampleTexture2DLOD_d1665f30f3c74d54b5b2be5e322ee59e_B_7_Float, 0, _Combine_dff050d017d340c2800db94c26ef03c5_RGBA_4_Vector4, _Combine_dff050d017d340c2800db94c26ef03c5_RGB_5_Vector3, _Combine_dff050d017d340c2800db94c26ef03c5_RG_6_Vector2);
        float3 _Multiply_074bdcbed8984aa8bfbb7d64f7394db2_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Combine_dff050d017d340c2800db94c26ef03c5_RGB_5_Vector3, float3(0.01, 0.01, 0.01), _Multiply_074bdcbed8984aa8bfbb7d64f7394db2_Out_2_Vector3);
        float3 _Add_c52759803daa4e8db8b2073f1ca73d5a_Out_2_Vector3;
        Unity_Add_float3(_Combine_3a3a46b2dd084ef5b50d1c94bd1bf662_RGB_5_Vector3, _Multiply_074bdcbed8984aa8bfbb7d64f7394db2_Out_2_Vector3, _Add_c52759803daa4e8db8b2073f1ca73d5a_Out_2_Vector3);
        #if defined(_B_LOAD_POS_TWO_TEX)
        float3 _PositionsRequireTwoTextures_953c53d9543e4e83863d6f6fc765ab90_Out_0_Vector3 = _Add_c52759803daa4e8db8b2073f1ca73d5a_Out_2_Vector3;
        #else
        float3 _PositionsRequireTwoTextures_953c53d9543e4e83863d6f6fc765ab90_Out_0_Vector3 = _Combine_3a3a46b2dd084ef5b50d1c94bd1bf662_RGB_5_Vector3;
        #endif
        float3 _Subtract_83069528d6794190a7bbec7f91d26eb4_Out_2_Vector3;
        Unity_Subtract_float3(_Combine_e339454ae4ab446eab26fa05e5da4305_RGB_5_Vector3, _Combine_b7dc50f2401c46dca6eed4b19e0862d8_RGB_5_Vector3, _Subtract_83069528d6794190a7bbec7f91d26eb4_Out_2_Vector3);
        float3 _Multiply_76ae98c658fe4213ac5482dd0c399267_Out_2_Vector3;
        Unity_Multiply_float3_float3(_PositionsRequireTwoTextures_953c53d9543e4e83863d6f6fc765ab90_Out_0_Vector3, _Subtract_83069528d6794190a7bbec7f91d26eb4_Out_2_Vector3, _Multiply_76ae98c658fe4213ac5482dd0c399267_Out_2_Vector3);
        float3 _Add_dda8c9ca0e7d43e2a04a2882c29f90d7_Out_2_Vector3;
        Unity_Add_float3(_Multiply_76ae98c658fe4213ac5482dd0c399267_Out_2_Vector3, _Combine_b7dc50f2401c46dca6eed4b19e0862d8_RGB_5_Vector3, _Add_dda8c9ca0e7d43e2a04a2882c29f90d7_Out_2_Vector3);
        float3 _Branch_6abcc2317e104339a2decf93e9aee587_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_322cfaaadddd4969978d57a8c96084ef_Out_2_Boolean, _PositionsRequireTwoTextures_953c53d9543e4e83863d6f6fc765ab90_Out_0_Vector3, _Add_dda8c9ca0e7d43e2a04a2882c29f90d7_Out_2_Vector3, _Branch_6abcc2317e104339a2decf93e9aee587_Out_3_Vector3);
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_de27d463cc6a4aa49ace2fa8becc61eb_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_de27d463cc6a4aa49ace2fa8becc61eb_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_7dbd408acfee4e078cd82cbe1e5f572b_Out_0_Texture2D.tex, _Property_7dbd408acfee4e078cd82cbe1e5f572b_Out_0_Texture2D.samplerstate, _Property_7dbd408acfee4e078cd82cbe1e5f572b_Out_0_Texture2D.GetTransformedUV(_Combine_7acf849c0cd74d32b462c613ff310511_RG_6_Vector2), 0);
        #endif
        float _SampleTexture2DLOD_de27d463cc6a4aa49ace2fa8becc61eb_R_5_Float = _SampleTexture2DLOD_de27d463cc6a4aa49ace2fa8becc61eb_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_de27d463cc6a4aa49ace2fa8becc61eb_G_6_Float = _SampleTexture2DLOD_de27d463cc6a4aa49ace2fa8becc61eb_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_de27d463cc6a4aa49ace2fa8becc61eb_B_7_Float = _SampleTexture2DLOD_de27d463cc6a4aa49ace2fa8becc61eb_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_de27d463cc6a4aa49ace2fa8becc61eb_A_8_Float = _SampleTexture2DLOD_de27d463cc6a4aa49ace2fa8becc61eb_RGBA_0_Vector4.a;
        float4 _Combine_d49aa133f0fe4d09ae08fdeb68792238_RGBA_4_Vector4;
        float3 _Combine_d49aa133f0fe4d09ae08fdeb68792238_RGB_5_Vector3;
        float2 _Combine_d49aa133f0fe4d09ae08fdeb68792238_RG_6_Vector2;
        Unity_Combine_float(_SampleTexture2DLOD_de27d463cc6a4aa49ace2fa8becc61eb_R_5_Float, _SampleTexture2DLOD_de27d463cc6a4aa49ace2fa8becc61eb_G_6_Float, _SampleTexture2DLOD_de27d463cc6a4aa49ace2fa8becc61eb_B_7_Float, 0, _Combine_d49aa133f0fe4d09ae08fdeb68792238_RGBA_4_Vector4, _Combine_d49aa133f0fe4d09ae08fdeb68792238_RGB_5_Vector3, _Combine_d49aa133f0fe4d09ae08fdeb68792238_RG_6_Vector2);
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_855392d9245a455d941374694e57f0c7_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_855392d9245a455d941374694e57f0c7_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_88cc07c51d1d4c2ea2801e86f6a9f044_Out_0_Texture2D.tex, _Property_88cc07c51d1d4c2ea2801e86f6a9f044_Out_0_Texture2D.samplerstate, _Property_88cc07c51d1d4c2ea2801e86f6a9f044_Out_0_Texture2D.GetTransformedUV(_Combine_7acf849c0cd74d32b462c613ff310511_RG_6_Vector2), 0);
        #endif
        float _SampleTexture2DLOD_855392d9245a455d941374694e57f0c7_R_5_Float = _SampleTexture2DLOD_855392d9245a455d941374694e57f0c7_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_855392d9245a455d941374694e57f0c7_G_6_Float = _SampleTexture2DLOD_855392d9245a455d941374694e57f0c7_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_855392d9245a455d941374694e57f0c7_B_7_Float = _SampleTexture2DLOD_855392d9245a455d941374694e57f0c7_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_855392d9245a455d941374694e57f0c7_A_8_Float = _SampleTexture2DLOD_855392d9245a455d941374694e57f0c7_RGBA_0_Vector4.a;
        float4 _Combine_85e12c5db5f74b81b34cc35bf980f496_RGBA_4_Vector4;
        float3 _Combine_85e12c5db5f74b81b34cc35bf980f496_RGB_5_Vector3;
        float2 _Combine_85e12c5db5f74b81b34cc35bf980f496_RG_6_Vector2;
        Unity_Combine_float(_SampleTexture2DLOD_855392d9245a455d941374694e57f0c7_R_5_Float, _SampleTexture2DLOD_855392d9245a455d941374694e57f0c7_G_6_Float, _SampleTexture2DLOD_855392d9245a455d941374694e57f0c7_B_7_Float, 0, _Combine_85e12c5db5f74b81b34cc35bf980f496_RGBA_4_Vector4, _Combine_85e12c5db5f74b81b34cc35bf980f496_RGB_5_Vector3, _Combine_85e12c5db5f74b81b34cc35bf980f496_RG_6_Vector2);
        float3 _Multiply_57b4f75333624583be0873db92dedf96_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Combine_85e12c5db5f74b81b34cc35bf980f496_RGB_5_Vector3, float3(0.01, 0.01, 0.01), _Multiply_57b4f75333624583be0873db92dedf96_Out_2_Vector3);
        float3 _Add_caa93fff586040738eb0fd2b1ec136f9_Out_2_Vector3;
        Unity_Add_float3(_Combine_d49aa133f0fe4d09ae08fdeb68792238_RGB_5_Vector3, _Multiply_57b4f75333624583be0873db92dedf96_Out_2_Vector3, _Add_caa93fff586040738eb0fd2b1ec136f9_Out_2_Vector3);
        #if defined(_B_LOAD_POS_TWO_TEX)
        float3 _PositionsRequireTwoTextures_c8e450f1058a4432b4c548b5e53b7946_Out_0_Vector3 = _Add_caa93fff586040738eb0fd2b1ec136f9_Out_2_Vector3;
        #else
        float3 _PositionsRequireTwoTextures_c8e450f1058a4432b4c548b5e53b7946_Out_0_Vector3 = _Combine_d49aa133f0fe4d09ae08fdeb68792238_RGB_5_Vector3;
        #endif
        float3 _Multiply_8e5558b18d83439a9981812720701597_Out_2_Vector3;
        Unity_Multiply_float3_float3(_PositionsRequireTwoTextures_c8e450f1058a4432b4c548b5e53b7946_Out_0_Vector3, _Subtract_83069528d6794190a7bbec7f91d26eb4_Out_2_Vector3, _Multiply_8e5558b18d83439a9981812720701597_Out_2_Vector3);
        float3 _Add_80715fe518cd4ad1a9a73a23b690774d_Out_2_Vector3;
        Unity_Add_float3(_Multiply_8e5558b18d83439a9981812720701597_Out_2_Vector3, _Combine_b7dc50f2401c46dca6eed4b19e0862d8_RGB_5_Vector3, _Add_80715fe518cd4ad1a9a73a23b690774d_Out_2_Vector3);
        float3 _Branch_4f4f2009002c4eafa0b38571d20172b2_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_322cfaaadddd4969978d57a8c96084ef_Out_2_Boolean, _PositionsRequireTwoTextures_c8e450f1058a4432b4c548b5e53b7946_Out_0_Vector3, _Add_80715fe518cd4ad1a9a73a23b690774d_Out_2_Vector3, _Branch_4f4f2009002c4eafa0b38571d20172b2_Out_3_Vector3);
        float3 _Subtract_c002362d55c64293ade55419b13c9056_Out_2_Vector3;
        Unity_Subtract_float3(_Branch_6abcc2317e104339a2decf93e9aee587_Out_3_Vector3, _Branch_4f4f2009002c4eafa0b38571d20172b2_Out_3_Vector3, _Subtract_c002362d55c64293ade55419b13c9056_Out_2_Vector3);
        float3 _ViewSpaceXYVectorSource_c9db42b14c98435bab8a69f03afbc787_Out_0_Vector3;
        if (_View_Space_XY_Vector_Source == 0)
        {
        _ViewSpaceXYVectorSource_c9db42b14c98435bab8a69f03afbc787_Out_0_Vector3 = _Combine_84c4758ac48844248a82cbc39db0198e_RGB_5_Vector3;
        }
        else if (_View_Space_XY_Vector_Source == 1)
        {
        _ViewSpaceXYVectorSource_c9db42b14c98435bab8a69f03afbc787_Out_0_Vector3 = _Subtract_c002362d55c64293ade55419b13c9056_Out_2_Vector3;
        }
        else
        {
        _ViewSpaceXYVectorSource_c9db42b14c98435bab8a69f03afbc787_Out_0_Vector3 = _Combine_84c4758ac48844248a82cbc39db0198e_RGB_5_Vector3;
        }
        float3 _Transform_6470794a874f4e1bba4ded0150b4c37b_Out_1_Vector3;
        {
        // Converting Direction from Object to View via world space
        float3 world;
        world = TransformObjectToWorldDir(_ViewSpaceXYVectorSource_c9db42b14c98435bab8a69f03afbc787_Out_0_Vector3.xyz, true);
        _Transform_6470794a874f4e1bba4ded0150b4c37b_Out_1_Vector3 = TransformWorldToViewDir(world, false);
        }
        float _Split_f2f61f7abb6c4a49a547fa5ea930a375_R_1_Float = _Transform_6470794a874f4e1bba4ded0150b4c37b_Out_1_Vector3[0];
        float _Split_f2f61f7abb6c4a49a547fa5ea930a375_G_2_Float = _Transform_6470794a874f4e1bba4ded0150b4c37b_Out_1_Vector3[1];
        float _Split_f2f61f7abb6c4a49a547fa5ea930a375_B_3_Float = _Transform_6470794a874f4e1bba4ded0150b4c37b_Out_1_Vector3[2];
        float _Split_f2f61f7abb6c4a49a547fa5ea930a375_A_4_Float = 0;
        float4 _Combine_3b689e31c4a044e6ab698d9ac20b40ff_RGBA_4_Vector4;
        float3 _Combine_3b689e31c4a044e6ab698d9ac20b40ff_RGB_5_Vector3;
        float2 _Combine_3b689e31c4a044e6ab698d9ac20b40ff_RG_6_Vector2;
        Unity_Combine_float(_Split_f2f61f7abb6c4a49a547fa5ea930a375_R_1_Float, _Split_f2f61f7abb6c4a49a547fa5ea930a375_G_2_Float, 0, 0, _Combine_3b689e31c4a044e6ab698d9ac20b40ff_RGBA_4_Vector4, _Combine_3b689e31c4a044e6ab698d9ac20b40ff_RGB_5_Vector3, _Combine_3b689e31c4a044e6ab698d9ac20b40ff_RG_6_Vector2);
        float3 _Normalize_d36df1c471174f2d86e73f9ac9d02674_Out_1_Vector3;
        Unity_Normalize_float3(_Combine_3b689e31c4a044e6ab698d9ac20b40ff_RGB_5_Vector3, _Normalize_d36df1c471174f2d86e73f9ac9d02674_Out_1_Vector3);
        float3 _CrossProduct_75431be4ca0f46888f95502ca1290973_Out_2_Vector3;
        Unity_CrossProduct_float(_Normalize_d36df1c471174f2d86e73f9ac9d02674_Out_1_Vector3, float3 (0, 0, 1), _CrossProduct_75431be4ca0f46888f95502ca1290973_Out_2_Vector3);
        float3 _Normalize_98819ae108e64a7e8cb0b3e968a6b08d_Out_1_Vector3;
        Unity_Normalize_float3(_CrossProduct_75431be4ca0f46888f95502ca1290973_Out_2_Vector3, _Normalize_98819ae108e64a7e8cb0b3e968a6b08d_Out_1_Vector3);
        float _Floor_85c378b26acf448082167d21248936fd_Out_1_Float;
        Unity_Floor_float(_Split_c57cc6c2a4714679969ca15abe6b868d_G_2_Float, _Floor_85c378b26acf448082167d21248936fd_Out_1_Float);
        float _Subtract_6e96b166ec394865919eea36f8129ff9_Out_2_Float;
        Unity_Subtract_float(_Split_c57cc6c2a4714679969ca15abe6b868d_G_2_Float, _Floor_85c378b26acf448082167d21248936fd_Out_1_Float, _Subtract_6e96b166ec394865919eea36f8129ff9_Out_2_Float);
        float _OneMinus_af2916e9237347d78467467e0d2806a4_Out_1_Float;
        Unity_OneMinus_float(_Subtract_6e96b166ec394865919eea36f8129ff9_Out_2_Float, _OneMinus_af2916e9237347d78467467e0d2806a4_Out_1_Float);
        float _Divide_569c994b2ab34847bd4a297c59a7ca80_Out_2_Float;
        Unity_Divide_float(1, _OneMinus_af2916e9237347d78467467e0d2806a4_Out_1_Float, _Divide_569c994b2ab34847bd4a297c59a7ca80_Out_2_Float);
        float _Property_3846d8d11e5a4879a5cd321dac5367cf_Out_0_Boolean = _Interframe_Interpolation;
        float _Lerp_422cc4ed2ff54b46a9ed6591acaa8de8_Out_3_Float;
        Unity_Lerp_float(_SampleTexture2DLOD_de27d463cc6a4aa49ace2fa8becc61eb_A_8_Float, _SampleTexture2DLOD_d92919bca21f48e29f52a6d33023c4aa_A_8_Float, _Fraction_c62e039143ec48078706377fd40a9b87_Out_1_Float, _Lerp_422cc4ed2ff54b46a9ed6591acaa8de8_Out_3_Float);
        float _Branch_603f2ce34db44ac798c580a61e245520_Out_3_Float;
        Unity_Branch_float(_Property_3846d8d11e5a4879a5cd321dac5367cf_Out_0_Boolean, _Lerp_422cc4ed2ff54b46a9ed6591acaa8de8_Out_3_Float, _SampleTexture2DLOD_de27d463cc6a4aa49ace2fa8becc61eb_A_8_Float, _Branch_603f2ce34db44ac798c580a61e245520_Out_3_Float);
        float _Multiply_9636e59c40554ea78d0843ee2b762d32_Out_2_Float;
        Unity_Multiply_float_float(_Divide_569c994b2ab34847bd4a297c59a7ca80_Out_2_Float, _Branch_603f2ce34db44ac798c580a61e245520_Out_3_Float, _Multiply_9636e59c40554ea78d0843ee2b762d32_Out_2_Float);
        float _Property_3fc1b14a08c04ca2b75cfef8a78aea87_Out_0_Float = _Particle_Spin_Phase;
        float _SpinPhaseSource_565bd9f613e64db580ee674eca8a6513_Out_0_Float;
        if (_Spin_Phase_Source == 0)
        {
        _SpinPhaseSource_565bd9f613e64db580ee674eca8a6513_Out_0_Float = _Multiply_9636e59c40554ea78d0843ee2b762d32_Out_2_Float;
        }
        else if (_Spin_Phase_Source == 1)
        {
        _SpinPhaseSource_565bd9f613e64db580ee674eca8a6513_Out_0_Float = _Property_3fc1b14a08c04ca2b75cfef8a78aea87_Out_0_Float;
        }
        else
        {
        _SpinPhaseSource_565bd9f613e64db580ee674eca8a6513_Out_0_Float = _Multiply_9636e59c40554ea78d0843ee2b762d32_Out_2_Float;
        }
        float _Property_87abe7fd73b3424f90ae6220fbf94373_Out_0_Float = _Per_Particle_Random_Spin_Speed;
        float _Multiply_8a6c9d62155f4a9fad52f014ba3b20cf_Out_2_Float;
        Unity_Multiply_float_float(_SpinPhaseSource_565bd9f613e64db580ee674eca8a6513_Out_0_Float, _Property_87abe7fd73b3424f90ae6220fbf94373_Out_0_Float, _Multiply_8a6c9d62155f4a9fad52f014ba3b20cf_Out_2_Float);
        float _Fraction_cd766afb81b149388d5ca292b88866c2_Out_1_Float;
        Unity_Fraction_float(_Multiply_8a6c9d62155f4a9fad52f014ba3b20cf_Out_2_Float, _Fraction_cd766afb81b149388d5ca292b88866c2_Out_1_Float);
        float Constant_cb8de5a907974fcba4ccd69ac9252c96 = 6.283185;
        float _Multiply_6c254758289c45c49c0fb6bb3cc11e24_Out_2_Float;
        Unity_Multiply_float_float(_Fraction_cd766afb81b149388d5ca292b88866c2_Out_1_Float, Constant_cb8de5a907974fcba4ccd69ac9252c96, _Multiply_6c254758289c45c49c0fb6bb3cc11e24_Out_2_Float);
        float _Cosine_038417e3ac554eb88655259b9c401edf_Out_1_Float;
        Unity_Cosine_float(_Multiply_6c254758289c45c49c0fb6bb3cc11e24_Out_2_Float, _Cosine_038417e3ac554eb88655259b9c401edf_Out_1_Float);
        float _Sine_61c97be801a24a83ae31fc522bad6e08_Out_1_Float;
        Unity_Sine_float(_Multiply_6c254758289c45c49c0fb6bb3cc11e24_Out_2_Float, _Sine_61c97be801a24a83ae31fc522bad6e08_Out_1_Float);
        float4 _Combine_16836557e0cc43bbb633a33560ea37bb_RGBA_4_Vector4;
        float3 _Combine_16836557e0cc43bbb633a33560ea37bb_RGB_5_Vector3;
        float2 _Combine_16836557e0cc43bbb633a33560ea37bb_RG_6_Vector2;
        Unity_Combine_float(_Cosine_038417e3ac554eb88655259b9c401edf_Out_1_Float, _Sine_61c97be801a24a83ae31fc522bad6e08_Out_1_Float, 0, 0, _Combine_16836557e0cc43bbb633a33560ea37bb_RGBA_4_Vector4, _Combine_16836557e0cc43bbb633a33560ea37bb_RGB_5_Vector3, _Combine_16836557e0cc43bbb633a33560ea37bb_RG_6_Vector2);
        float3 _Branch_f4c937c988ac48ff9ca16abf8cdd8d28_Out_3_Vector3;
        Unity_Branch_float3(_Property_4e59012634c54df9a62c08063edbd7c7_Out_0_Boolean, _Normalize_98819ae108e64a7e8cb0b3e968a6b08d_Out_1_Vector3, _Combine_16836557e0cc43bbb633a33560ea37bb_RGB_5_Vector3, _Branch_f4c937c988ac48ff9ca16abf8cdd8d28_Out_3_Vector3);
        float3 _Vector3_633691609fef45479a887941ad7401f6_Out_0_Vector3 = float3(1, 0, 0);
        #if defined(_B_CAN_SPIN)
        float3 _ParticlesCanSpin_15ccb1fd2e5e41d78ba4bf556e1cb110_Out_0_Vector3 = _Branch_f4c937c988ac48ff9ca16abf8cdd8d28_Out_3_Vector3;
        #else
        float3 _ParticlesCanSpin_15ccb1fd2e5e41d78ba4bf556e1cb110_Out_0_Vector3 = _Vector3_633691609fef45479a887941ad7401f6_Out_0_Vector3;
        #endif
        float3 _Transform_42aac3eb2493482293effaf5c41e857e_Out_1_Vector3;
        {
        // Converting Direction from View to Object via world space
        float3 world;
        world = TransformViewToWorldDir(_ParticlesCanSpin_15ccb1fd2e5e41d78ba4bf556e1cb110_Out_0_Vector3.xyz, false);
        _Transform_42aac3eb2493482293effaf5c41e857e_Out_1_Vector3 = TransformWorldToObjectDir(world, true);
        }
        float3 _Normalize_1df362c23eaa4004a0947a2d49f8dce9_Out_1_Vector3;
        Unity_Normalize_float3(_Transform_42aac3eb2493482293effaf5c41e857e_Out_1_Vector3, _Normalize_1df362c23eaa4004a0947a2d49f8dce9_Out_1_Vector3);
        float _Property_bfccb62ddd954d41b4df62a5ecdbfe03_Out_0_Float = _Particle_Width_Base_Scale;
        float3 _Multiply_1d8614d971ed402788ce7deacdce0dbb_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_1df362c23eaa4004a0947a2d49f8dce9_Out_1_Vector3, (_Property_bfccb62ddd954d41b4df62a5ecdbfe03_Out_0_Float.xxx), _Multiply_1d8614d971ed402788ce7deacdce0dbb_Out_2_Vector3);
        float _Property_ca9e36feb71d4cf78149b81e9217932f_Out_0_Boolean = _Particle_Scales_Are_in_Position_Alpha;
        float _Property_f5786a3d5569478b8eae019914b101f8_Out_0_Boolean = _Hide_Particles_Overlapping_Object_Origin;
        float _Property_096c2661298f4e66af019267698182a6_Out_0_Float = _Global_Particle_Scale_Multiplier;
        float _Property_fd457b14ee374851acb797d805e03ad9_Out_0_Float = _Additional_Particle_Scale_Uniform_Multiplier;
        float _Multiply_86012600a74742f9ba420df31881cca9_Out_2_Float;
        Unity_Multiply_float_float(_Property_096c2661298f4e66af019267698182a6_Out_0_Float, _Property_fd457b14ee374851acb797d805e03ad9_Out_0_Float, _Multiply_86012600a74742f9ba420df31881cca9_Out_2_Float);
        float _Multiply_0e51bc57545d405dadf935ab635a5723_Out_2_Float;
        Unity_Multiply_float_float(_Multiply_9636e59c40554ea78d0843ee2b762d32_Out_2_Float, _Multiply_86012600a74742f9ba420df31881cca9_Out_2_Float, _Multiply_0e51bc57545d405dadf935ab635a5723_Out_2_Float);
        float3 _Vector3_f70d6bc1c14248569ad4b3e23e19222a_Out_0_Vector3 = float3(0, 0, 0);
        float _Distance_c35936b049f44a1189621a3fd28cad14_Out_2_Float;
        Unity_Distance_float3(_Branch_4f4f2009002c4eafa0b38571d20172b2_Out_3_Vector3, _Vector3_f70d6bc1c14248569ad4b3e23e19222a_Out_0_Vector3, _Distance_c35936b049f44a1189621a3fd28cad14_Out_2_Float);
        float _Property_250e60eebdc94654b6e418c4f6dab66d_Out_0_Float = _Origin_Effective_Radius;
        float _Subtract_55e2de4fca2e414995826fba0cc108ce_Out_2_Float;
        Unity_Subtract_float(_Distance_c35936b049f44a1189621a3fd28cad14_Out_2_Float, _Property_250e60eebdc94654b6e418c4f6dab66d_Out_0_Float, _Subtract_55e2de4fca2e414995826fba0cc108ce_Out_2_Float);
        float _Sign_e85ae706559e4ee1b55b138896ddbd43_Out_1_Float;
        Unity_Sign_float(_Subtract_55e2de4fca2e414995826fba0cc108ce_Out_2_Float, _Sign_e85ae706559e4ee1b55b138896ddbd43_Out_1_Float);
        float _Saturate_54409a4820e1408fb06cb2e4e4c735a3_Out_1_Float;
        Unity_Saturate_float(_Sign_e85ae706559e4ee1b55b138896ddbd43_Out_1_Float, _Saturate_54409a4820e1408fb06cb2e4e4c735a3_Out_1_Float);
        float _Multiply_a9c032f8285f4d96b4fd93c44f295293_Out_2_Float;
        Unity_Multiply_float_float(_Multiply_0e51bc57545d405dadf935ab635a5723_Out_2_Float, _Saturate_54409a4820e1408fb06cb2e4e4c735a3_Out_1_Float, _Multiply_a9c032f8285f4d96b4fd93c44f295293_Out_2_Float);
        float _Branch_fee107be4f244e59a6aca55717f5a5f8_Out_3_Float;
        Unity_Branch_float(_Property_f5786a3d5569478b8eae019914b101f8_Out_0_Boolean, _Multiply_a9c032f8285f4d96b4fd93c44f295293_Out_2_Float, _Multiply_0e51bc57545d405dadf935ab635a5723_Out_2_Float, _Branch_fee107be4f244e59a6aca55717f5a5f8_Out_3_Float);
        float _Property_9e9d846aa3374b0fb9f4e18be8f640cf_Out_0_Boolean = _Hide_Particles_Overlapping_Object_Origin;
        float _Property_f1b76a659bc64203bb54639402e90b1e_Out_0_Boolean = _Interframe_Interpolation;
        float _Multiply_8032fae3b0da4e31a9f4af1e10f2b76b_Out_2_Float;
        Unity_Multiply_float_float(_Multiply_86012600a74742f9ba420df31881cca9_Out_2_Float, _Saturate_54409a4820e1408fb06cb2e4e4c735a3_Out_1_Float, _Multiply_8032fae3b0da4e31a9f4af1e10f2b76b_Out_2_Float);
        float _Distance_fd651bbde84b41449eb6384985c3427b_Out_2_Float;
        Unity_Distance_float3(_Branch_6abcc2317e104339a2decf93e9aee587_Out_3_Vector3, _Vector3_f70d6bc1c14248569ad4b3e23e19222a_Out_0_Vector3, _Distance_fd651bbde84b41449eb6384985c3427b_Out_2_Float);
        float _Subtract_6e483d8f08014bea95f3ec2f06a143a3_Out_2_Float;
        Unity_Subtract_float(_Distance_fd651bbde84b41449eb6384985c3427b_Out_2_Float, _Property_250e60eebdc94654b6e418c4f6dab66d_Out_0_Float, _Subtract_6e483d8f08014bea95f3ec2f06a143a3_Out_2_Float);
        float _Sign_91dd2f5b1dac44c2ace59ef7b9834f1a_Out_1_Float;
        Unity_Sign_float(_Subtract_6e483d8f08014bea95f3ec2f06a143a3_Out_2_Float, _Sign_91dd2f5b1dac44c2ace59ef7b9834f1a_Out_1_Float);
        float _Saturate_0494dafbf6744290af271b106670f197_Out_1_Float;
        Unity_Saturate_float(_Sign_91dd2f5b1dac44c2ace59ef7b9834f1a_Out_1_Float, _Saturate_0494dafbf6744290af271b106670f197_Out_1_Float);
        float _Multiply_bfe764e0f9c2424e96f9684a79d03ef9_Out_2_Float;
        Unity_Multiply_float_float(_Multiply_86012600a74742f9ba420df31881cca9_Out_2_Float, _Saturate_0494dafbf6744290af271b106670f197_Out_1_Float, _Multiply_bfe764e0f9c2424e96f9684a79d03ef9_Out_2_Float);
        float _Lerp_fef7510faac9418d8d77d6e374339a9b_Out_3_Float;
        Unity_Lerp_float(_Multiply_8032fae3b0da4e31a9f4af1e10f2b76b_Out_2_Float, _Multiply_bfe764e0f9c2424e96f9684a79d03ef9_Out_2_Float, _Fraction_c62e039143ec48078706377fd40a9b87_Out_1_Float, _Lerp_fef7510faac9418d8d77d6e374339a9b_Out_3_Float);
        float _Branch_96579a0c4c7d4f39b08f5bdde709eb5a_Out_3_Float;
        Unity_Branch_float(_Property_f1b76a659bc64203bb54639402e90b1e_Out_0_Boolean, _Lerp_fef7510faac9418d8d77d6e374339a9b_Out_3_Float, _Multiply_8032fae3b0da4e31a9f4af1e10f2b76b_Out_2_Float, _Branch_96579a0c4c7d4f39b08f5bdde709eb5a_Out_3_Float);
        float _Branch_6d9aacee403844d3a1341d0a886a829d_Out_3_Float;
        Unity_Branch_float(_Property_9e9d846aa3374b0fb9f4e18be8f640cf_Out_0_Boolean, _Branch_96579a0c4c7d4f39b08f5bdde709eb5a_Out_3_Float, _Multiply_86012600a74742f9ba420df31881cca9_Out_2_Float, _Branch_6d9aacee403844d3a1341d0a886a829d_Out_3_Float);
        float _Branch_9407cfb6998e429d984261cbca6c9a42_Out_3_Float;
        Unity_Branch_float(_Property_ca9e36feb71d4cf78149b81e9217932f_Out_0_Boolean, _Branch_fee107be4f244e59a6aca55717f5a5f8_Out_3_Float, _Branch_6d9aacee403844d3a1341d0a886a829d_Out_3_Float, _Branch_9407cfb6998e429d984261cbca6c9a42_Out_3_Float);
        float3 _Multiply_71d17005c55448acacf6b8b1374e2133_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_1d8614d971ed402788ce7deacdce0dbb_Out_2_Vector3, (_Branch_9407cfb6998e429d984261cbca6c9a42_Out_3_Float.xxx), _Multiply_71d17005c55448acacf6b8b1374e2133_Out_2_Vector3);
        float3 _Multiply_9bbc4947f6254658878d5688566865b9_Out_2_Vector3;
        Unity_Multiply_float3_float3((_Subtract_05d51b931861456793c0a2eedb288a0f_Out_2_Float.xxx), _Multiply_71d17005c55448acacf6b8b1374e2133_Out_2_Vector3, _Multiply_9bbc4947f6254658878d5688566865b9_Out_2_Vector3);
        float3 _CrossProduct_3e9b73825c48494cba87775f2408a6c4_Out_2_Vector3;
        Unity_CrossProduct_float(_Branch_f4c937c988ac48ff9ca16abf8cdd8d28_Out_3_Vector3, float3 (0, 0, -1), _CrossProduct_3e9b73825c48494cba87775f2408a6c4_Out_2_Vector3);
        float3 _Vector3_dfbb096f5c1d4eb183c2a1f2a2831fcb_Out_0_Vector3 = float3(0, 1, 0);
        #if defined(_B_CAN_SPIN)
        float3 _ParticlesCanSpin_0548163eda5e4937a93297d411806216_Out_0_Vector3 = _CrossProduct_3e9b73825c48494cba87775f2408a6c4_Out_2_Vector3;
        #else
        float3 _ParticlesCanSpin_0548163eda5e4937a93297d411806216_Out_0_Vector3 = _Vector3_dfbb096f5c1d4eb183c2a1f2a2831fcb_Out_0_Vector3;
        #endif
        float3 _Transform_40eb56208d8944bcbce7c1b0ca4a347b_Out_1_Vector3;
        {
        // Converting Direction from View to Object via world space
        float3 world;
        world = TransformViewToWorldDir(_ParticlesCanSpin_0548163eda5e4937a93297d411806216_Out_0_Vector3.xyz, false);
        _Transform_40eb56208d8944bcbce7c1b0ca4a347b_Out_1_Vector3 = TransformWorldToObjectDir(world, true);
        }
        float3 _Normalize_e41783c3231f4ddf88f800eeef41fad3_Out_1_Vector3;
        Unity_Normalize_float3(_Transform_40eb56208d8944bcbce7c1b0ca4a347b_Out_1_Vector3, _Normalize_e41783c3231f4ddf88f800eeef41fad3_Out_1_Vector3);
        float _Subtract_4e5b1cb76e2a4c5f9cdd36c6ce8c36b9_Out_2_Float;
        Unity_Subtract_float(_Split_93694a90fa074f4ca9b406827dd0f959_G_2_Float, 0.5, _Subtract_4e5b1cb76e2a4c5f9cdd36c6ce8c36b9_Out_2_Float);
        float3 _Multiply_46b9044723184f358cf07d1034e5c676_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Normalize_e41783c3231f4ddf88f800eeef41fad3_Out_1_Vector3, (_Subtract_4e5b1cb76e2a4c5f9cdd36c6ce8c36b9_Out_2_Float.xxx), _Multiply_46b9044723184f358cf07d1034e5c676_Out_2_Vector3);
        float _Property_d7fa5d776e5d4104a7eb2835deb9d6e2_Out_0_Float = _Particle_Height_Base_Scale;
        float _Property_7dc2eaac656d4f70aad646f6a92bf202_Out_0_Boolean = _Compute_Spin_from_Heading_Vector;
        float _Property_4856159750674be19b2dffaae85bdfe6_Out_0_Float = _Scale_by_Velocity_Amount;
        float _Property_1d2458008e3c4035a670f7435608501f_Out_0_Float = _Per_Particle_Random_Velocity_Scale;
        float _Multiply_d7c2e86f5f7a4d1182dd8fd382cdaccc_Out_2_Float;
        Unity_Multiply_float_float(_Property_4856159750674be19b2dffaae85bdfe6_Out_0_Float, _Property_1d2458008e3c4035a670f7435608501f_Out_0_Float, _Multiply_d7c2e86f5f7a4d1182dd8fd382cdaccc_Out_2_Float);
        float _Length_fe93d7d382c243e49aa1ca674deab76e_Out_1_Float;
        Unity_Length_float3(_Combine_3b689e31c4a044e6ab698d9ac20b40ff_RGB_5_Vector3, _Length_fe93d7d382c243e49aa1ca674deab76e_Out_1_Float);
        float _Multiply_de3e851b81b4479eb465898650d4861c_Out_2_Float;
        Unity_Multiply_float_float(_Multiply_d7c2e86f5f7a4d1182dd8fd382cdaccc_Out_2_Float, _Length_fe93d7d382c243e49aa1ca674deab76e_Out_1_Float, _Multiply_de3e851b81b4479eb465898650d4861c_Out_2_Float);
        float _Branch_7fa3f83e28694bb0b700cebab680acda_Out_3_Float;
        Unity_Branch_float(_Property_7dc2eaac656d4f70aad646f6a92bf202_Out_0_Boolean, _Multiply_de3e851b81b4479eb465898650d4861c_Out_2_Float, 1, _Branch_7fa3f83e28694bb0b700cebab680acda_Out_3_Float);
        #if defined(_B_CAN_SPIN)
        float _ParticlesCanSpin_6156f9ea9002421cb862542f395e77c8_Out_0_Float = _Branch_7fa3f83e28694bb0b700cebab680acda_Out_3_Float;
        #else
        float _ParticlesCanSpin_6156f9ea9002421cb862542f395e77c8_Out_0_Float = 1;
        #endif
        float _Multiply_1962268dcc4f4a4480db4bfa9476c2a2_Out_2_Float;
        Unity_Multiply_float_float(_Property_d7fa5d776e5d4104a7eb2835deb9d6e2_Out_0_Float, _ParticlesCanSpin_6156f9ea9002421cb862542f395e77c8_Out_0_Float, _Multiply_1962268dcc4f4a4480db4bfa9476c2a2_Out_2_Float);
        float3 _Multiply_8635652c718b41838c47993ce3e89298_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_46b9044723184f358cf07d1034e5c676_Out_2_Vector3, (_Multiply_1962268dcc4f4a4480db4bfa9476c2a2_Out_2_Float.xxx), _Multiply_8635652c718b41838c47993ce3e89298_Out_2_Vector3);
        float3 _Multiply_2b21e6ea928f4a79a8d1b2178e62dcb5_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_8635652c718b41838c47993ce3e89298_Out_2_Vector3, (_Branch_9407cfb6998e429d984261cbca6c9a42_Out_3_Float.xxx), _Multiply_2b21e6ea928f4a79a8d1b2178e62dcb5_Out_2_Vector3);
        float3 _Add_33e0b86d54404adc858df2b688d0a4cc_Out_2_Vector3;
        Unity_Add_float3(_Multiply_9bbc4947f6254658878d5688566865b9_Out_2_Vector3, _Multiply_2b21e6ea928f4a79a8d1b2178e62dcb5_Out_2_Vector3, _Add_33e0b86d54404adc858df2b688d0a4cc_Out_2_Vector3);
        float _Property_3ce953a60a5d4afbbdbbe5cc126e8bf3_Out_0_Boolean = _Particle_Scales_Are_in_Position_Alpha;
        float _Property_1238b8669b754229a924fa19745c9a3a_Out_0_Boolean = _Interframe_Interpolation;
        float3 _Lerp_575c9c879bd54a02896fea66ac682590_Out_3_Vector3;
        Unity_Lerp_float3(_Branch_4f4f2009002c4eafa0b38571d20172b2_Out_3_Vector3, _Branch_6abcc2317e104339a2decf93e9aee587_Out_3_Vector3, (_Fraction_c62e039143ec48078706377fd40a9b87_Out_1_Float.xxx), _Lerp_575c9c879bd54a02896fea66ac682590_Out_3_Vector3);
        float3 _Branch_a95062aee478445eb238301f4077b46b_Out_3_Vector3;
        Unity_Branch_float3(_Property_1238b8669b754229a924fa19745c9a3a_Out_0_Boolean, _Lerp_575c9c879bd54a02896fea66ac682590_Out_3_Vector3, _Branch_4f4f2009002c4eafa0b38571d20172b2_Out_3_Vector3, _Branch_a95062aee478445eb238301f4077b46b_Out_3_Vector3);
        float _Comparison_b7ce4ddaa3cc4b478a800ece23d40e5b_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Saturate_54409a4820e1408fb06cb2e4e4c735a3_Out_1_Float, 0, _Comparison_b7ce4ddaa3cc4b478a800ece23d40e5b_Out_2_Boolean);
        float _Comparison_2897401515e34b908c45d072f81b765e_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Saturate_0494dafbf6744290af271b106670f197_Out_1_Float, 0, _Comparison_2897401515e34b908c45d072f81b765e_Out_2_Boolean);
        float3 _Branch_d00e56da8a90456cb7c41ce6a00e1906_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_2897401515e34b908c45d072f81b765e_Out_2_Boolean, _Branch_a95062aee478445eb238301f4077b46b_Out_3_Vector3, _Branch_4f4f2009002c4eafa0b38571d20172b2_Out_3_Vector3, _Branch_d00e56da8a90456cb7c41ce6a00e1906_Out_3_Vector3);
        float3 _Branch_0fac16c643e44ab3a41c8cd91bb317ba_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_b7ce4ddaa3cc4b478a800ece23d40e5b_Out_2_Boolean, _Branch_d00e56da8a90456cb7c41ce6a00e1906_Out_3_Vector3, _Branch_6abcc2317e104339a2decf93e9aee587_Out_3_Vector3, _Branch_0fac16c643e44ab3a41c8cd91bb317ba_Out_3_Vector3);
        float3 _Branch_b35fd4f4c0544633ba23d1c373809e3d_Out_3_Vector3;
        Unity_Branch_float3(_Property_3ce953a60a5d4afbbdbbe5cc126e8bf3_Out_0_Boolean, _Branch_a95062aee478445eb238301f4077b46b_Out_3_Vector3, _Branch_0fac16c643e44ab3a41c8cd91bb317ba_Out_3_Vector3, _Branch_b35fd4f4c0544633ba23d1c373809e3d_Out_3_Vector3);
        float3 _Add_78525f464a6d4f779780673f94af0b68_Out_2_Vector3;
        Unity_Add_float3(_Add_33e0b86d54404adc858df2b688d0a4cc_Out_2_Vector3, _Branch_b35fd4f4c0544633ba23d1c373809e3d_Out_3_Vector3, _Add_78525f464a6d4f779780673f94af0b68_Out_2_Vector3);
        float3 _Property_8b9e36bcab644a8a8de5aa7a5f8c87cc_Out_0_Vector3 = Vector3_d2bfcc1e36e143fb8998c41bd35e34ce;
        float3 _Add_cfc4c853d1734b97a576111ad82a4646_Out_2_Vector3;
        Unity_Add_float3(_Add_78525f464a6d4f779780673f94af0b68_Out_2_Vector3, _Property_8b9e36bcab644a8a8de5aa7a5f8c87cc_Out_0_Vector3, _Add_cfc4c853d1734b97a576111ad82a4646_Out_2_Vector3);
        float3 _Branch_ba93d84f34e744b6a0798505c9ceae34_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_05395f032a9d41f883deb216f4f78844_Out_2_Boolean, float3(0, 0, 0), _Add_cfc4c853d1734b97a576111ad82a4646_Out_2_Vector3, _Branch_ba93d84f34e744b6a0798505c9ceae34_Out_3_Vector3);
        float3 _Vector3_b2e22f7efe9b4567beb1673b8403d831_Out_0_Vector3 = float3(0, 0, 1);
        float3 _Transform_1e5f2cb5266a473b9b67af7ba4f16ec7_Out_1_Vector3;
        {
        // Converting Direction from View to Object via world space
        float3 world;
        world = TransformViewToWorldDir(_Vector3_b2e22f7efe9b4567beb1673b8403d831_Out_0_Vector3.xyz, false);
        _Transform_1e5f2cb5266a473b9b67af7ba4f16ec7_Out_1_Vector3 = TransformWorldToObjectDir(world, true);
        }
        float3 _Normalize_6ff0bb5959824712b3c1a9d455332917_Out_1_Vector3;
        Unity_Normalize_float3(_Transform_1e5f2cb5266a473b9b67af7ba4f16ec7_Out_1_Vector3, _Normalize_6ff0bb5959824712b3c1a9d455332917_Out_1_Vector3);
        float _Property_e82ce2070ecc4580b8cc7e2957a8b387_Out_0_Boolean = Boolean_452ee7b85a19421f84aedbe953332219;
        float3 _Vector3_334362fd0ae04d9c8d077e7724248b0f_Out_0_Vector3 = float3(0, 0, 0);
        float3 _Branch_937bb7ab707947f3939fbece2363d768_Out_3_Vector3;
        Unity_Branch_float3(_Property_e82ce2070ecc4580b8cc7e2957a8b387_Out_0_Boolean, _Normalize_1df362c23eaa4004a0947a2d49f8dce9_Out_1_Vector3, _Vector3_334362fd0ae04d9c8d077e7724248b0f_Out_0_Vector3, _Branch_937bb7ab707947f3939fbece2363d768_Out_3_Vector3);
        float _Split_c5593124f90046678b7f159106c72a73_R_1_Float = _Branch_3c68277c1c8744a59f98768785e6c5e7_Out_3_Vector4[0];
        float _Split_c5593124f90046678b7f159106c72a73_G_2_Float = _Branch_3c68277c1c8744a59f98768785e6c5e7_Out_3_Vector4[1];
        float _Split_c5593124f90046678b7f159106c72a73_B_3_Float = _Branch_3c68277c1c8744a59f98768785e6c5e7_Out_3_Vector4[2];
        float _Split_c5593124f90046678b7f159106c72a73_A_4_Float = _Branch_3c68277c1c8744a59f98768785e6c5e7_Out_3_Vector4[3];
        float4 _Combine_4377c6dcc5d345eca19f49e271a380a1_RGBA_4_Vector4;
        float3 _Combine_4377c6dcc5d345eca19f49e271a380a1_RGB_5_Vector3;
        float2 _Combine_4377c6dcc5d345eca19f49e271a380a1_RG_6_Vector2;
        Unity_Combine_float(_Split_c5593124f90046678b7f159106c72a73_R_1_Float, _Split_c5593124f90046678b7f159106c72a73_G_2_Float, _Split_c5593124f90046678b7f159106c72a73_B_3_Float, 0, _Combine_4377c6dcc5d345eca19f49e271a380a1_RGBA_4_Vector4, _Combine_4377c6dcc5d345eca19f49e271a380a1_RGB_5_Vector3, _Combine_4377c6dcc5d345eca19f49e271a380a1_RG_6_Vector2);
        float _Property_1a2077ccac00451180694756814bdb14_Out_0_Boolean = _Interframe_Interpolation;
        float _Property_d21add728a344d5aa22e5521939df28a_Out_0_Boolean = _Interpolate_Spare_Color;
        float _And_01fa23b3b0054ee285a642ea984c79bd_Out_2_Boolean;
        Unity_And_float(_Property_1a2077ccac00451180694756814bdb14_Out_0_Boolean, _Property_d21add728a344d5aa22e5521939df28a_Out_0_Boolean, _And_01fa23b3b0054ee285a642ea984c79bd_Out_2_Boolean);
        UnityTexture2D _Property_fdb0c4a7b4304cf7aa5f4f3b27b8156e_Out_0_Texture2D = Texture2D_dc3c6e2909694510a2bce97b5d611620;
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_91d8eb10f6014791b31ca62331d89a27_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_91d8eb10f6014791b31ca62331d89a27_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_fdb0c4a7b4304cf7aa5f4f3b27b8156e_Out_0_Texture2D.tex, _Property_fdb0c4a7b4304cf7aa5f4f3b27b8156e_Out_0_Texture2D.samplerstate, _Property_fdb0c4a7b4304cf7aa5f4f3b27b8156e_Out_0_Texture2D.GetTransformedUV(_Combine_7acf849c0cd74d32b462c613ff310511_RG_6_Vector2), 0);
        #endif
        float _SampleTexture2DLOD_91d8eb10f6014791b31ca62331d89a27_R_5_Float = _SampleTexture2DLOD_91d8eb10f6014791b31ca62331d89a27_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_91d8eb10f6014791b31ca62331d89a27_G_6_Float = _SampleTexture2DLOD_91d8eb10f6014791b31ca62331d89a27_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_91d8eb10f6014791b31ca62331d89a27_B_7_Float = _SampleTexture2DLOD_91d8eb10f6014791b31ca62331d89a27_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_91d8eb10f6014791b31ca62331d89a27_A_8_Float = _SampleTexture2DLOD_91d8eb10f6014791b31ca62331d89a27_RGBA_0_Vector4.a;
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_25f85af0492d4a22a920ab930ef4024f_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_25f85af0492d4a22a920ab930ef4024f_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_fdb0c4a7b4304cf7aa5f4f3b27b8156e_Out_0_Texture2D.tex, _Property_fdb0c4a7b4304cf7aa5f4f3b27b8156e_Out_0_Texture2D.samplerstate, _Property_fdb0c4a7b4304cf7aa5f4f3b27b8156e_Out_0_Texture2D.GetTransformedUV(_Combine_a5e0df8891744ba98da48d60a7cffd50_RG_6_Vector2), 0);
        #endif
        float _SampleTexture2DLOD_25f85af0492d4a22a920ab930ef4024f_R_5_Float = _SampleTexture2DLOD_25f85af0492d4a22a920ab930ef4024f_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_25f85af0492d4a22a920ab930ef4024f_G_6_Float = _SampleTexture2DLOD_25f85af0492d4a22a920ab930ef4024f_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_25f85af0492d4a22a920ab930ef4024f_B_7_Float = _SampleTexture2DLOD_25f85af0492d4a22a920ab930ef4024f_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_25f85af0492d4a22a920ab930ef4024f_A_8_Float = _SampleTexture2DLOD_25f85af0492d4a22a920ab930ef4024f_RGBA_0_Vector4.a;
        float4 _Lerp_5b84de47bc154d2eab428508120ea672_Out_3_Vector4;
        Unity_Lerp_float4(_SampleTexture2DLOD_91d8eb10f6014791b31ca62331d89a27_RGBA_0_Vector4, _SampleTexture2DLOD_25f85af0492d4a22a920ab930ef4024f_RGBA_0_Vector4, (_Fraction_c62e039143ec48078706377fd40a9b87_Out_1_Float.xxxx), _Lerp_5b84de47bc154d2eab428508120ea672_Out_3_Vector4);
        float4 _Branch_a6360ef37f69476dad27377056af6ce2_Out_3_Vector4;
        Unity_Branch_float4(_And_01fa23b3b0054ee285a642ea984c79bd_Out_2_Boolean, _Lerp_5b84de47bc154d2eab428508120ea672_Out_3_Vector4, _SampleTexture2DLOD_91d8eb10f6014791b31ca62331d89a27_RGBA_0_Vector4, _Branch_a6360ef37f69476dad27377056af6ce2_Out_3_Vector4);
        float4 _UV_a6a3ceca5d714584aa693875a566aeda_Out_0_Vector4 = IN.uv0;
        float _Split_3c2d32b294344f7a8bc4c66576fd53b0_R_1_Float = _UV_a6a3ceca5d714584aa693875a566aeda_Out_0_Vector4[0];
        float _Split_3c2d32b294344f7a8bc4c66576fd53b0_G_2_Float = _UV_a6a3ceca5d714584aa693875a566aeda_Out_0_Vector4[1];
        float _Split_3c2d32b294344f7a8bc4c66576fd53b0_B_3_Float = _UV_a6a3ceca5d714584aa693875a566aeda_Out_0_Vector4[2];
        float _Split_3c2d32b294344f7a8bc4c66576fd53b0_A_4_Float = _UV_a6a3ceca5d714584aa693875a566aeda_Out_0_Vector4[3];
        float4 _Combine_689da211165242e7964c6b27e601dd12_RGBA_4_Vector4;
        float3 _Combine_689da211165242e7964c6b27e601dd12_RGB_5_Vector3;
        float2 _Combine_689da211165242e7964c6b27e601dd12_RG_6_Vector2;
        Unity_Combine_float(_Split_3c2d32b294344f7a8bc4c66576fd53b0_R_1_Float, _Split_3c2d32b294344f7a8bc4c66576fd53b0_G_2_Float, 0, 0, _Combine_689da211165242e7964c6b27e601dd12_RGBA_4_Vector4, _Combine_689da211165242e7964c6b27e601dd12_RGB_5_Vector3, _Combine_689da211165242e7964c6b27e601dd12_RG_6_Vector2);
        float _Property_ef3799523abb46618edd884b3ffa0662_Out_0_Float = _Particle_Texture_U_Scale;
        float _Property_ed3185e29a984142a5e9f501f88564bd_Out_0_Float = _Particle_Texture_V_Scale;
        float4 _Combine_cd05fb9b7c2343afb247e9b71e14933f_RGBA_4_Vector4;
        float3 _Combine_cd05fb9b7c2343afb247e9b71e14933f_RGB_5_Vector3;
        float2 _Combine_cd05fb9b7c2343afb247e9b71e14933f_RG_6_Vector2;
        Unity_Combine_float(_Property_ef3799523abb46618edd884b3ffa0662_Out_0_Float, _Property_ed3185e29a984142a5e9f501f88564bd_Out_0_Float, 0, 0, _Combine_cd05fb9b7c2343afb247e9b71e14933f_RGBA_4_Vector4, _Combine_cd05fb9b7c2343afb247e9b71e14933f_RGB_5_Vector3, _Combine_cd05fb9b7c2343afb247e9b71e14933f_RG_6_Vector2);
        float2 _Multiply_2b4b78d88a00448ea5dece6fd4974204_Out_2_Vector2;
        Unity_Multiply_float2_float2(_Combine_689da211165242e7964c6b27e601dd12_RG_6_Vector2, _Combine_cd05fb9b7c2343afb247e9b71e14933f_RG_6_Vector2, _Multiply_2b4b78d88a00448ea5dece6fd4974204_Out_2_Vector2);
        float2 _Multiply_a3e130de7a294b7b81017b236457a393_Out_2_Vector2;
        Unity_Multiply_float2_float2(_Combine_cd05fb9b7c2343afb247e9b71e14933f_RG_6_Vector2, float2(-0.5, -0.5), _Multiply_a3e130de7a294b7b81017b236457a393_Out_2_Vector2);
        float2 _Vector2_d1b74b73b4d14d688dfa054b9aec33cb_Out_0_Vector2 = float2(0.5, 0.5);
        float2 _Add_5df3e3b7e7624c7280020843ffe8d50d_Out_2_Vector2;
        Unity_Add_float2(_Multiply_a3e130de7a294b7b81017b236457a393_Out_2_Vector2, _Vector2_d1b74b73b4d14d688dfa054b9aec33cb_Out_0_Vector2, _Add_5df3e3b7e7624c7280020843ffe8d50d_Out_2_Vector2);
        float2 _Add_e00605b26063466b94029711a45957a2_Out_2_Vector2;
        Unity_Add_float2(_Multiply_2b4b78d88a00448ea5dece6fd4974204_Out_2_Vector2, _Add_5df3e3b7e7624c7280020843ffe8d50d_Out_2_Vector2, _Add_e00605b26063466b94029711a45957a2_Out_2_Vector2);
        float _Multiply_da3254ad20e34a8b9507097f01d91a2c_Out_2_Float;
        Unity_Multiply_float_float(_Divide_569c994b2ab34847bd4a297c59a7ca80_Out_2_Float, _SampleTexture2DLOD_de27d463cc6a4aa49ace2fa8becc61eb_A_8_Float, _Multiply_da3254ad20e34a8b9507097f01d91a2c_Out_2_Float);
        float _Multiply_951a39edc04e42edb94eec3de2616641_Out_2_Float;
        Unity_Multiply_float_float(_Divide_569c994b2ab34847bd4a297c59a7ca80_Out_2_Float, _SampleTexture2DLOD_d92919bca21f48e29f52a6d33023c4aa_A_8_Float, _Multiply_951a39edc04e42edb94eec3de2616641_Out_2_Float);
        Out_Position_1 = _Branch_ba93d84f34e744b6a0798505c9ceae34_Out_3_Vector3;
        Out_Normal_2 = _Normalize_6ff0bb5959824712b3c1a9d455332917_Out_1_Vector3;
        Out_Tangent_3 = _Branch_937bb7ab707947f3939fbece2363d768_Out_3_Vector3;
        Out_ColorRGB_4 = _Combine_4377c6dcc5d345eca19f49e271a380a1_RGB_5_Vector3;
        Out_ColorAlpha_6 = _Split_c5593124f90046678b7f159106c72a73_A_4_Float;
        Out_SpareColorRGBA_5 = _Branch_a6360ef37f69476dad27377056af6ce2_Out_3_Vector4;
        Out_ParticleTextureUV_19 = _Add_e00605b26063466b94029711a45957a2_Out_2_Vector2;
        Out_SamplingVThisFrame_8 = _Add_1fc73c4ac8ed420895dc22580cd38980_Out_2_Float;
        Out_SamplingVNextFrame_9 = _Add_ec5f1cbe56ae4bc3adc07cab0b3cada0_Out_2_Float;
        Out_ParticleLocalPositionThisFrame_10 = _Branch_4f4f2009002c4eafa0b38571d20172b2_Out_3_Vector3;
        Out_ParticleLocalPositionNextFrame_11 = _Branch_6abcc2317e104339a2decf93e9aee587_Out_3_Vector3;
        Out_DataInPositionAlphaThisFrame_12 = _Multiply_da3254ad20e34a8b9507097f01d91a2c_Out_2_Float;
        Out_DataInPositionAlphaNextFrame_13 = _Multiply_951a39edc04e42edb94eec3de2616641_Out_2_Float;
        Out_ColorRGBAThisFrame_17 = _LoadColorTexture_f0d31671e10846148e10ff6f6ddcce87_Out_0_Vector4;
        Out_ColorRGBANextFrame_14 = _LoadColorTexture_cc743dddac284c769882b4847ff7576b_Out_0_Vector4;
        Out_SpareColorRGBAThisFrame_18 = _SampleTexture2DLOD_91d8eb10f6014791b31ca62331d89a27_RGBA_0_Vector4;
        Out_SpareColorRGBANextFrame_15 = _SampleTexture2DLOD_25f85af0492d4a22a920ab930ef4024f_RGBA_0_Vector4;
        Out_InterframeInterpolationAlpha_16 = _Fraction_c62e039143ec48078706377fd40a9b87_Out_1_Float;
        Out_AnimationProgressThisFrame_21 = _Multiply_8ecd22e403084ffeac4fda6da39b7880_Out_2_Float;
        Out_AnimationProgressNextFrame_22 = _Multiply_cfb7fa4be2094158a058e2c60bbf86e0_Out_2_Float;
        Out_ParticleLocalPositionFinal_20 = _Branch_b35fd4f4c0544633ba23d1c373809e3d_Out_3_Vector3;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
            float4 Color_ToFragment;
            float2 ParticleUV_ToFragment;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_dec4506e248341b28fe2c8d49642655e_Out_0_Boolean = _B_autoPlayback;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_682e3efc6bec45c688c9265906107ff9_Out_0_Float = _gameTimeAtFirstFrame;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_f1e2cf2c77614076b44609bb6248b3b0_Out_0_Float = _displayFrame;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_9dd3f3a8aa7f4b8b98c245671a0ccc3c_Out_0_Float = _playbackSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_c8cf047780ab45ee8b7c46338cb1f1f6_Out_0_Float = _houdiniFPS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_bdf605ae51274295b6717cdea5f990ee_Out_0_Boolean = _B_interpolate;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_ac8fa91ddd734a51805b060cfb9ef252_Out_0_Boolean = _B_interpolateCol;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_91fe97fdf36b4ad29e3a17ebdf13896b_Out_0_Boolean = _B_interpolateSpareCol;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_59c97c43621b48e7a7113ee8e093093c_Out_0_Boolean = _B_surfaceNormals;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            UnityTexture2D _Property_9236a60294a44b11b05129feaf44221a_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_posTexture);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            UnityTexture2D _Property_46fd3449bf4c4e63808c67b6b43ce73c_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_posTexture2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            UnityTexture2D _Property_2771991b04124530b56cab74d03b1ad5_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_colTexture);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            UnityTexture2D _Property_0623e61d7a4d4dc6a62bbeeb3270e8c3_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_spareColTexture);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_3e8b20bce2d04e97ada3073a6a4c3c37_Out_0_Boolean = _B_pscaleAreInPosA;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_fb22cb80dd714f128e343f320df23e6f_Out_0_Float = _globalPscaleMul;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_cf38667243ce4131b75af96beb784b6d_Out_0_Float = _widthBaseScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_f3e5d779adb74c8ba14b5a9f8d1d83fe_Out_0_Float = _heightBaseScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_8e5b28a5fdbf41cf890658b345213f55_Out_0_Float = _particleTexUScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_182c462d07ed468d8cc9b4359d2ce300_Out_0_Float = _particleTexVScale;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_de84099b3ac644d8bef5cea27a177928_Out_0_Boolean = _B_spinFromHeading;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_2505a1794fbe4b56882da896f50b91cf_Out_0_Float = _scaleByVelAmount;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_7f61289720db4dacb3b4437e9657774c_Out_0_Boolean = _B_hideOverlappingOrigin;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_2b955d204d994e9ca14e8974642a4aad_Out_0_Float = _originRadius;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_b86981125884455da91bed13413bbbbf_Out_0_Float = _frameCount;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_52c5873f926b4b9f854070d9c8d2886f_Out_0_Float = _boundMaxX;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_611d6cf54f734f89bd499a23712ca0df_Out_0_Float = _boundMaxY;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_6b6a2245b06b46399254eb74e17a261f_Out_0_Float = _boundMaxZ;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_d17bb64f97e34bdea2e7af2405dc0686_Out_0_Float = _boundMinX;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_153b5f703dc1482f9da91cf90eca30f5_Out_0_Float = _boundMinY;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_e3f21ed56bb74dcdb3cf4a5ac378ca77_Out_0_Float = _boundMinZ;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float4 _UV_754f61126c02453e9df8d8c775b36189_Out_0_Vector4 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Split_a7cb08f9c2b84eb7a30ba86a72f195b3_R_1_Float = _UV_754f61126c02453e9df8d8c775b36189_Out_0_Vector4[0];
            float _Split_a7cb08f9c2b84eb7a30ba86a72f195b3_G_2_Float = _UV_754f61126c02453e9df8d8c775b36189_Out_0_Vector4[1];
            float _Split_a7cb08f9c2b84eb7a30ba86a72f195b3_B_3_Float = _UV_754f61126c02453e9df8d8c775b36189_Out_0_Vector4[2];
            float _Split_a7cb08f9c2b84eb7a30ba86a72f195b3_A_4_Float = _UV_754f61126c02453e9df8d8c775b36189_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float4 _Combine_936097b6227442bf9c4940bf857c182a_RGBA_4_Vector4;
            float3 _Combine_936097b6227442bf9c4940bf857c182a_RGB_5_Vector3;
            float2 _Combine_936097b6227442bf9c4940bf857c182a_RG_6_Vector2;
            Unity_Combine_float(_Split_a7cb08f9c2b84eb7a30ba86a72f195b3_R_1_Float, _Split_a7cb08f9c2b84eb7a30ba86a72f195b3_G_2_Float, 0, 0, _Combine_936097b6227442bf9c4940bf857c182a_RGBA_4_Vector4, _Combine_936097b6227442bf9c4940bf857c182a_RGB_5_Vector3, _Combine_936097b6227442bf9c4940bf857c182a_RG_6_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _RandomRange_731303725b7c454787b70318b6fd8aa7_Out_3_Float;
            Unity_RandomRange_float(_Combine_936097b6227442bf9c4940bf857c182a_RG_6_Vector2, 0, 1, _RandomRange_731303725b7c454787b70318b6fd8aa7_Out_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Split_a3763bd838e74a059edf7bc236057660_R_1_Float = _RandomRange_731303725b7c454787b70318b6fd8aa7_Out_3_Float;
            float _Split_a3763bd838e74a059edf7bc236057660_G_2_Float = 0;
            float _Split_a3763bd838e74a059edf7bc236057660_B_3_Float = 0;
            float _Split_a3763bd838e74a059edf7bc236057660_A_4_Float = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Multiply_821512b33a9a46529f6c48a79cfc3495_Out_2_Float;
            Unity_Multiply_float_float(_Split_a3763bd838e74a059edf7bc236057660_R_1_Float, 0.5, _Multiply_821512b33a9a46529f6c48a79cfc3495_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Add_3e06f9540ba2453a97507457559c8dfa_Out_2_Float;
            Unity_Add_float(1, _Multiply_821512b33a9a46529f6c48a79cfc3495_Out_2_Float, _Add_3e06f9540ba2453a97507457559c8dfa_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Multiply_73c53dce2b854033aefd2e8188d1f3f7_Out_2_Float;
            Unity_Multiply_float_float(_Split_a3763bd838e74a059edf7bc236057660_R_1_Float, 1, _Multiply_73c53dce2b854033aefd2e8188d1f3f7_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Add_6f790a3d9399414a8884f8c0240824e3_Out_2_Float;
            Unity_Add_float(_Multiply_73c53dce2b854033aefd2e8188d1f3f7_Out_2_Float, 1, _Add_6f790a3d9399414a8884f8c0240824e3_Out_2_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            Bindings_VATParticleSpritesSSG_0c58eccff9a0bb343a88b72ec3ca197c_float _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f;
            _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f.uv0 = IN.uv0;
            _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f.uv1 = IN.uv1;
            float3 _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutPosition_1_Vector3;
            float3 _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutNormal_2_Vector3;
            float3 _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutTangent_3_Vector3;
            float3 _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutColorRGB_4_Vector3;
            float _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutColorAlpha_6_Float;
            float4 _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutSpareColorRGBA_5_Vector4;
            float2 _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutParticleTextureUV_19_Vector2;
            float _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutSamplingVThisFrame_8_Float;
            float _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutSamplingVNextFrame_9_Float;
            float3 _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutParticleLocalPositionThisFrame_10_Vector3;
            float3 _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutParticleLocalPositionNextFrame_11_Vector3;
            float _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutDataInPositionAlphaThisFrame_12_Float;
            float _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutDataInPositionAlphaNextFrame_13_Float;
            float4 _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutColorRGBAThisFrame_17_Vector4;
            float4 _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutColorRGBANextFrame_14_Vector4;
            float4 _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutSpareColorRGBAThisFrame_18_Vector4;
            float4 _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutSpareColorRGBANextFrame_15_Vector4;
            float _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutInterframeInterpolationAlpha_16_Float;
            float _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutAnimationProgressThisFrame_21_Float;
            float _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutAnimationProgressNextFrame_22_Float;
            float3 _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutParticleLocalPositionFinal_20_Vector3;
            SG_VATParticleSpritesSSG_0c58eccff9a0bb343a88b72ec3ca197c_float(_Property_dec4506e248341b28fe2c8d49642655e_Out_0_Boolean, _Property_682e3efc6bec45c688c9265906107ff9_Out_0_Float, _Property_f1e2cf2c77614076b44609bb6248b3b0_Out_0_Float, _Property_9dd3f3a8aa7f4b8b98c245671a0ccc3c_Out_0_Float, _Property_c8cf047780ab45ee8b7c46338cb1f1f6_Out_0_Float, _Property_bdf605ae51274295b6717cdea5f990ee_Out_0_Boolean, _Property_ac8fa91ddd734a51805b060cfb9ef252_Out_0_Boolean, _Property_91fe97fdf36b4ad29e3a17ebdf13896b_Out_0_Boolean, _Property_59c97c43621b48e7a7113ee8e093093c_Out_0_Boolean, _Property_9236a60294a44b11b05129feaf44221a_Out_0_Texture2D, _Property_46fd3449bf4c4e63808c67b6b43ce73c_Out_0_Texture2D, _Property_2771991b04124530b56cab74d03b1ad5_Out_0_Texture2D, _Property_0623e61d7a4d4dc6a62bbeeb3270e8c3_Out_0_Texture2D, _Property_3e8b20bce2d04e97ada3073a6a4c3c37_Out_0_Boolean, _Property_fb22cb80dd714f128e343f320df23e6f_Out_0_Float, _Property_cf38667243ce4131b75af96beb784b6d_Out_0_Float, _Property_f3e5d779adb74c8ba14b5a9f8d1d83fe_Out_0_Float, _Property_8e5b28a5fdbf41cf890658b345213f55_Out_0_Float, _Property_182c462d07ed468d8cc9b4359d2ce300_Out_0_Float, _Property_de84099b3ac644d8bef5cea27a177928_Out_0_Boolean, _Property_2505a1794fbe4b56882da896f50b91cf_Out_0_Float, IN.TimeParameters.x, _Property_7f61289720db4dacb3b4437e9657774c_Out_0_Boolean, _Property_2b955d204d994e9ca14e8974642a4aad_Out_0_Float, _Property_b86981125884455da91bed13413bbbbf_Out_0_Float, _Property_52c5873f926b4b9f854070d9c8d2886f_Out_0_Float, _Property_611d6cf54f734f89bd499a23712ca0df_Out_0_Float, _Property_6b6a2245b06b46399254eb74e17a261f_Out_0_Float, _Property_d17bb64f97e34bdea2e7af2405dc0686_Out_0_Float, _Property_153b5f703dc1482f9da91cf90eca30f5_Out_0_Float, _Property_e3f21ed56bb74dcdb3cf4a5ac378ca77_Out_0_Float, IN.TimeParameters.x, _Add_3e06f9540ba2453a97507457559c8dfa_Out_2_Float, 1, _Add_6f790a3d9399414a8884f8c0240824e3_Out_2_Float, float3 (0, 0, 0), 0, 1, _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f, _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutPosition_1_Vector3, _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutNormal_2_Vector3, _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutTangent_3_Vector3, _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutColorRGB_4_Vector3, _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutColorAlpha_6_Float, _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutSpareColorRGBA_5_Vector4, _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutParticleTextureUV_19_Vector2, _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutSamplingVThisFrame_8_Float, _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutSamplingVNextFrame_9_Float, _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutParticleLocalPositionThisFrame_10_Vector3, _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutParticleLocalPositionNextFrame_11_Vector3, _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutDataInPositionAlphaThisFrame_12_Float, _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutDataInPositionAlphaNextFrame_13_Float, _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutColorRGBAThisFrame_17_Vector4, _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutColorRGBANextFrame_14_Vector4, _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutSpareColorRGBAThisFrame_18_Vector4, _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutSpareColorRGBANextFrame_15_Vector4, _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutInterframeInterpolationAlpha_16_Float, _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutAnimationProgressThisFrame_21_Float, _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutAnimationProgressNextFrame_22_Float, _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutParticleLocalPositionFinal_20_Vector3);
            #endif
            description.Position = _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutPosition_1_Vector3;
            description.Normal = _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutNormal_2_Vector3;
            description.Tangent = _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutTangent_3_Vector3;
            description.Color_ToFragment = (float4(_VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutColorRGB_4_Vector3, 1.0));
            description.ParticleUV_ToFragment = _VATParticleSpritesSSG_c8b3a44042434ef9bdafdfa279709f2f_OutParticleTextureUV_19_Vector2;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        output.Color_ToFragment = input.Color_ToFragment;
        output.ParticleUV_ToFragment = input.ParticleUV_ToFragment;
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalOS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_c0c9539d7cae4f549517590b42124c43_Out_0_Boolean = _B_twoSidedNorms;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _IsFrontFace_797bcc6b59ee4f51aa350be53d68f84b_Out_0_Boolean = max(0, IN.FaceSign.x);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Property_73f39f06706f43d2bad927457f3cdc28_Out_0_Boolean = _B_surfaceNormals;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float4 _SampleTexture2D_72ab43ee7e5b4ff3acd5a9fb57f150dc_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_72ab43ee7e5b4ff3acd5a9fb57f150dc_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_72ab43ee7e5b4ff3acd5a9fb57f150dc_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_72ab43ee7e5b4ff3acd5a9fb57f150dc_Texture_1_Texture2D).GetTransformedUV(IN.ParticleUV_ToFragment) );
            _SampleTexture2D_72ab43ee7e5b4ff3acd5a9fb57f150dc_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_72ab43ee7e5b4ff3acd5a9fb57f150dc_RGBA_0_Vector4);
            float _SampleTexture2D_72ab43ee7e5b4ff3acd5a9fb57f150dc_R_4_Float = _SampleTexture2D_72ab43ee7e5b4ff3acd5a9fb57f150dc_RGBA_0_Vector4.r;
            float _SampleTexture2D_72ab43ee7e5b4ff3acd5a9fb57f150dc_G_5_Float = _SampleTexture2D_72ab43ee7e5b4ff3acd5a9fb57f150dc_RGBA_0_Vector4.g;
            float _SampleTexture2D_72ab43ee7e5b4ff3acd5a9fb57f150dc_B_6_Float = _SampleTexture2D_72ab43ee7e5b4ff3acd5a9fb57f150dc_RGBA_0_Vector4.b;
            float _SampleTexture2D_72ab43ee7e5b4ff3acd5a9fb57f150dc_A_7_Float = _SampleTexture2D_72ab43ee7e5b4ff3acd5a9fb57f150dc_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            #if defined(_B_LOAD_NORM_TEX)
            float4 _LoadSurfaceNormalMap_fb4ebe14c0f84712932829ccbc964ceb_Out_0_Vector4 = _SampleTexture2D_72ab43ee7e5b4ff3acd5a9fb57f150dc_RGBA_0_Vector4;
            #else
            float4 _LoadSurfaceNormalMap_fb4ebe14c0f84712932829ccbc964ceb_Out_0_Vector4 = float4(0, 0, 1, 1);
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _Split_a3e282ac8b3d465e879f5738abeb2647_R_1_Float = _LoadSurfaceNormalMap_fb4ebe14c0f84712932829ccbc964ceb_Out_0_Vector4[0];
            float _Split_a3e282ac8b3d465e879f5738abeb2647_G_2_Float = _LoadSurfaceNormalMap_fb4ebe14c0f84712932829ccbc964ceb_Out_0_Vector4[1];
            float _Split_a3e282ac8b3d465e879f5738abeb2647_B_3_Float = _LoadSurfaceNormalMap_fb4ebe14c0f84712932829ccbc964ceb_Out_0_Vector4[2];
            float _Split_a3e282ac8b3d465e879f5738abeb2647_A_4_Float = _LoadSurfaceNormalMap_fb4ebe14c0f84712932829ccbc964ceb_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float3 _Multiply_5e22dc23e2cd45c9a521a42408488070_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Split_a3e282ac8b3d465e879f5738abeb2647_B_3_Float.xxx), _Multiply_5e22dc23e2cd45c9a521a42408488070_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float3 _Multiply_69a8d13ae64d4a5b9f0d18138840a2bb_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceTangent, (_Split_a3e282ac8b3d465e879f5738abeb2647_R_1_Float.xxx), _Multiply_69a8d13ae64d4a5b9f0d18138840a2bb_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float3 _Add_3086fe80ae9a4abf8e682a24cc01b8a7_Out_2_Vector3;
            Unity_Add_float3(_Multiply_5e22dc23e2cd45c9a521a42408488070_Out_2_Vector3, _Multiply_69a8d13ae64d4a5b9f0d18138840a2bb_Out_2_Vector3, _Add_3086fe80ae9a4abf8e682a24cc01b8a7_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float3 _CrossProduct_c8e3ffc4478e4299b8a35f912b2faefd_Out_2_Vector3;
            Unity_CrossProduct_float(IN.ObjectSpaceTangent, IN.ObjectSpaceNormal, _CrossProduct_c8e3ffc4478e4299b8a35f912b2faefd_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float3 _Multiply_1b231ef7d4d24d2698ac413e125f32a7_Out_2_Vector3;
            Unity_Multiply_float3_float3(_CrossProduct_c8e3ffc4478e4299b8a35f912b2faefd_Out_2_Vector3, (_Split_a3e282ac8b3d465e879f5738abeb2647_G_2_Float.xxx), _Multiply_1b231ef7d4d24d2698ac413e125f32a7_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float3 _Add_76738a2deacc4cb1b1cff82a9338c807_Out_2_Vector3;
            Unity_Add_float3(_Add_3086fe80ae9a4abf8e682a24cc01b8a7_Out_2_Vector3, _Multiply_1b231ef7d4d24d2698ac413e125f32a7_Out_2_Vector3, _Add_76738a2deacc4cb1b1cff82a9338c807_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float3 _Branch_afc1cd56bb8f46d0ace957e28162f6b8_Out_3_Vector3;
            Unity_Branch_float3(_Property_73f39f06706f43d2bad927457f3cdc28_Out_0_Boolean, _Add_76738a2deacc4cb1b1cff82a9338c807_Out_2_Vector3, IN.ObjectSpaceNormal, _Branch_afc1cd56bb8f46d0ace957e28162f6b8_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float3 _Multiply_1d10b2264dba403bbb88c295c78462d0_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Branch_afc1cd56bb8f46d0ace957e28162f6b8_Out_3_Vector3, float3(-1, -1, -1), _Multiply_1d10b2264dba403bbb88c295c78462d0_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float3 _Branch_de02fb38aadf488c9f43cd8205c955df_Out_3_Vector3;
            Unity_Branch_float3(_IsFrontFace_797bcc6b59ee4f51aa350be53d68f84b_Out_0_Boolean, _Branch_afc1cd56bb8f46d0ace957e28162f6b8_Out_3_Vector3, _Multiply_1d10b2264dba403bbb88c295c78462d0_Out_2_Vector3, _Branch_de02fb38aadf488c9f43cd8205c955df_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float3 _Branch_d5a9a10070cf4223890c7cc96ae82d01_Out_3_Vector3;
            Unity_Branch_float3(_Property_c0c9539d7cae4f549517590b42124c43_Out_0_Boolean, _Branch_de02fb38aadf488c9f43cd8205c955df_Out_3_Vector3, _Branch_afc1cd56bb8f46d0ace957e28162f6b8_Out_3_Vector3, _Branch_d5a9a10070cf4223890c7cc96ae82d01_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float3 _Normalize_1ffe6cd47eb8460c91e6550310ab983f_Out_1_Vector3;
            Unity_Normalize_float3(_Branch_d5a9a10070cf4223890c7cc96ae82d01_Out_3_Vector3, _Normalize_1ffe6cd47eb8460c91e6550310ab983f_Out_1_Vector3);
            #endif
            surface.BaseColor = (float3(IN.Color_ToFragment.xyz));
            surface.NormalOS = _Normalize_1ffe6cd47eb8460c91e6550310ab983f_Out_1_Vector3;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0;
            surface.Occlusion = 1;
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
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        output.uv0 =                                        input.uv0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        output.uv1 =                                        input.uv1;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        output.TimeParameters =                             _TimeParameters.xyz;
        #endif
        
        
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
        
            output.Color_ToFragment = input.Color_ToFragment;
        output.ParticleUV_ToFragment = input.ParticleUV_ToFragment;
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        float3 unnormalizedNormalWS = input.normalWS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        #endif
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        output.ObjectSpaceNormal = normalize(mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M));           // transposed multiplication by inverse matrix to handle normal scale
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        output.ObjectSpaceTangent = TransformWorldToObjectDir(output.WorldSpaceTangent);
        #endif
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
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
   }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
//    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}