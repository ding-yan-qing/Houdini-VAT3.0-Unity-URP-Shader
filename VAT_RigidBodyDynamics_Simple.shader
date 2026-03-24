Shader "Custom/VAT_RigidBodyDynamics_Simple"
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
        [NoScaleOffset]_rotTexture("Rotation Texture", 2D) = "white" {}
        [NoScaleOffset]_colTexture("Color Texture", 2D) = "white" {}
        [NoScaleOffset]_spareColTexture("Spare Color Texture", 2D) = "white" {}
        [ToggleUI]_B_pscaleAreInPosA("Piece Scales Are in Position Alpha", Float) = 1
        _globalPscaleMul("Global Piece Scale Multiplier", Float) = 1
        [ToggleUI]_B_stretchByVel("Stretch by Velocity", Float) = 0
        _stretchByVelAmount("Stretch by Velocity Amount", Float) = 0
        [ToggleUI]_B_animateFirstFrame("Animate First Frame", Float) = 0
        [Toggle(_B_LOAD_COL_TEX)]_B_LOAD_COL_TEX("Load Color Texture", Float) = 1
        [Toggle(_B_SMOOTH_TRAJECTORIES)]_B_SMOOTH_TRAJECTORIES("Smoothly Interpolated Trajectories", Float) = 0
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
        #pragma shader_feature_local_vertex _ _B_SMOOTH_TRAJECTORIES
        #pragma shader_feature_local _ _B_LOAD_COL_TEX
        #pragma shader_feature_local_fragment _ _B_LOAD_NORM_TEX
        
        #if defined(_B_LOAD_POS_TWO_TEX) && defined(_B_SMOOTH_TRAJECTORIES) && defined(_B_LOAD_COL_TEX) && defined(_B_LOAD_NORM_TEX)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_B_LOAD_POS_TWO_TEX) && defined(_B_SMOOTH_TRAJECTORIES) && defined(_B_LOAD_COL_TEX)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_B_LOAD_POS_TWO_TEX) && defined(_B_SMOOTH_TRAJECTORIES) && defined(_B_LOAD_NORM_TEX)
            #define KEYWORD_PERMUTATION_2
        #elif defined(_B_LOAD_POS_TWO_TEX) && defined(_B_SMOOTH_TRAJECTORIES)
            #define KEYWORD_PERMUTATION_3
        #elif defined(_B_LOAD_POS_TWO_TEX) && defined(_B_LOAD_COL_TEX) && defined(_B_LOAD_NORM_TEX)
            #define KEYWORD_PERMUTATION_4
        #elif defined(_B_LOAD_POS_TWO_TEX) && defined(_B_LOAD_COL_TEX)
            #define KEYWORD_PERMUTATION_5
        #elif defined(_B_LOAD_POS_TWO_TEX) && defined(_B_LOAD_NORM_TEX)
            #define KEYWORD_PERMUTATION_6
        #elif defined(_B_LOAD_POS_TWO_TEX)
            #define KEYWORD_PERMUTATION_7
        #elif defined(_B_SMOOTH_TRAJECTORIES) && defined(_B_LOAD_COL_TEX) && defined(_B_LOAD_NORM_TEX)
            #define KEYWORD_PERMUTATION_8
        #elif defined(_B_SMOOTH_TRAJECTORIES) && defined(_B_LOAD_COL_TEX)
            #define KEYWORD_PERMUTATION_9
        #elif defined(_B_SMOOTH_TRAJECTORIES) && defined(_B_LOAD_NORM_TEX)
            #define KEYWORD_PERMUTATION_10
        #elif defined(_B_SMOOTH_TRAJECTORIES)
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
        #define ATTRIBUTES_NEED_TEXCOORD3
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
        #define VARYINGS_NEED_TEXCOORD0
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
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float4 uv3 : TEXCOORD3;
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
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float4 texCoord0;
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
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float FaceSign;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float4 Color_ToFragment;
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
             float4 uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float4 uv2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float4 uv3;
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
             float4 texCoord0 : INTERP5;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float4 fogFactorAndVertexLight : INTERP6;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float4 Color_ToFragment : INTERP7;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float3 positionWS : INTERP8;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
             float3 normalWS : INTERP9;
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
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.Color_ToFragment.xyzw = input.Color_ToFragment;
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
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.Color_ToFragment = input.Color_ToFragment.xyzw;
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
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _SampleTexture2D_72ab43ee7e5b4ff3acd5a9fb57f150dc_Texture_1_Texture2D_TexelSize;
        float _gameTimeAtFirstFrame;
        float _stretchByVelAmount;
        float _B_stretchByVel;
        float _B_interpolate;
        float _B_interpolateCol;
        float _B_interpolateSpareCol;
        float _B_autoPlayback;
        float _displayFrame;
        float _B_surfaceNormals;
        float4 _posTexture_TexelSize;
        float4 _posTexture2_TexelSize;
        float4 _rotTexture_TexelSize;
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
        float _B_animateFirstFrame;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_SampleTexture2D_72ab43ee7e5b4ff3acd5a9fb57f150dc_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_72ab43ee7e5b4ff3acd5a9fb57f150dc_Texture_1_Texture2D);
        TEXTURE2D(_posTexture);
        SAMPLER(sampler_posTexture);
        TEXTURE2D(_posTexture2);
        SAMPLER(sampler_posTexture2);
        TEXTURE2D(_rotTexture);
        SAMPLER(sampler_rotTexture);
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
        
        void Unity_Comparison_LessOrEqual_float(float A, float B, out float Out)
        {
            Out = A <= B ? 1 : 0;
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        void Unity_Floor_float(float In, out float Out)
        {
            Out = floor(In);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Comparison_GreaterOrEqual_float(float A, float B, out float Out)
        {
            Out = A >= B ? 1 : 0;
        }
        
        void Unity_Ceiling_float(float In, out float Out)
        {
            Out = ceil(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Fraction_float(float In, out float Out)
        {
            Out = frac(In);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Modulo_float(float A, float B, out float Out)
        {
            Out = fmod(A, B);
        }
        
        void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A - B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
        Out = A * B;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Comparison_NotEqual_float(float A, float B, out float Out)
        {
            Out = A != B ? 1 : 0;
        }
        
        void Decode_Quaternion_float(float3 XYZ, float MaxComponent, out float4 Out_XYZW){
        float w = sqrt(1.0 - pow(XYZ.x, 2) - pow(XYZ.y, 2) - pow(XYZ.z, 2));
        
        float4 q = float4(0, 0, 0, 1);
        
        
        
        switch(MaxComponent)
        
        {
        
            case 0:
        
                q = float4(XYZ.x, XYZ.y, XYZ.z, w);
        
                break;
        
            case 1:
        
                q = float4(w, XYZ.y, XYZ.z, XYZ.x);
        
                break;
        
            case 2:
        
                q = float4(XYZ.x, -w, XYZ.z, -XYZ.y);
        
                break;
        
            case 3:
        
                q = float4(XYZ.x, XYZ.y, -w, -XYZ.z);
        
                break;
        
            default:
        
                q = float4(XYZ.x, XYZ.y, XYZ.z, w);
        
                break;
        
        }
        
        
        
        Out_XYZW = q;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        void Unity_Sign_float(float In, out float Out)
        {
            Out = sign(In);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        void Unity_Normalize_float4(float4 In, out float4 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Absolute_float3(float3 In, out float3 Out)
        {
            Out = abs(In);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Interframe_Position_float(float3 V, float3 A, float3 P, float T, out float3 Out_InterframeP){
        Out_InterframeP = V * T + 0.5 * A * T * T + P;
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        struct Bindings_vatRigidBodyDynamics
        {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
        half4 uv1;
        half4 uv2;
        half4 uv3;
        };
        
        void SG_vatRigidBodyDynamicsSSG(float b_autoPlayback, float _Game_Time_at_First_Frame, float DisplayFrame, float PlaybackSpeed, float HoudiniFPS, float _Interframe_Interpolation, float _Interpolate_Color, float _Interpolate_Spare_Color,
            float b_surfaceNormals, UnityTexture2D pos_texture, UnityTexture2D pos_texture2, UnityTexture2D rot_texture, UnityTexture2D ColTexture, UnityTexture2D spareColTexture, float b_pscaleAreInPosA, float GlobalPscaleMul,
            float b_stretchByVel, float StretchByVelAmount, float _Animate_First_Frame, float FrameCount, float BoundMaxX, float BoundMaxY, float BoundMaxZ, float BoundMinX, float BoundMinY, float BoundMinZ, float _Input_Time,
            float3 zreo, Bindings_vatRigidBodyDynamics IN, out float3 Out_Position_1, out float3 Out_Normal_2, out float3 Out_Tangent_3, out float3 Out_ColorRGB_4, out float Out_ColorAlpha_6, out float4 Out_SpareColorRGBA_5, out float Out_SamplingVThisFrame_8, out float Out_SamplingVNextFrame_9, out float3 Out_PieceLocalPositionThisFrame_10, out float3 Out_PieceLocalPositionNextFrame_11, out float Out_DataInPositionAlphaThisFrame_12, out float Out_DataInPositionAlphaNextFrame_13, out float4 Out_ColorRGBAThisFrame_17, out float4 Out_ColorRGBANextFrame_14, out float4 Out_SpareColorRGBAThisFrame_18, out float4 Out_SpareColorRGBANextFrame_15, out float Out_InterframeInterpolationAlpha_16, out float Out_AnimationProgressThisFrame_21, out float Out_AnimationProgressNextFrame_22, out float3 Out_PieceRestFrameLocalPosition_19, out float3 Out_PieceLocalPositionFinal_20)
        {
        float4 _UV1 = IN.uv1;
        float _Comparison_LessOrEqual_B = _UV1.g <= 0.1 ? 1 : 0;
        
        float boundMaxX = BoundMaxX;
        float boundMaxY = BoundMaxY;
        float boundMaxZ = BoundMaxZ;
        
        float3 boundMaxCombine_RGB = float3(boundMaxX, boundMaxY, boundMaxZ);
            
        float3 boundMaxMul10 = boundMaxCombine_RGB * float3(10, 10, 10);
            
        float floorBoundMaxb = floor(boundMaxMul10.b);
        
        float SubtractBoundMaxb = boundMaxMul10.b - floorBoundMaxb;
        
        float ComparisonBoundMaxb = SubtractBoundMaxb >= 0.5 ? 1 : 0;
        
        UnityTexture2D rotTexture = rot_texture;
        
        float boundMinX = BoundMinX;
        float boundMinY = BoundMinY;
        float boundMinZ = BoundMinZ;
        
        float3 boundMinCombine_RGB = float3(boundMinX, boundMinY, boundMinZ);
        
        float3 boundMinMul10 = boundMinCombine_RGB * float3(10, 10, 10);
            
        float CeilingBoundMinMul10b = ceil(boundMinMul10.b);
        
        float SubtractCeilingBoundMinB = CeilingBoundMinMul10b - boundMinMul10.b;
        
        float OneMinusBoundMinB = 1 - SubtractCeilingBoundMinB;
        
        float MultiplyBoundMinB = _UV1.r * OneMinusBoundMinB;
        
        float OneMinusUV1g = 1 - _UV1.g;
        
        float MultiplyBoundMaxR = boundMaxMul10.r * -1;
        
        float FloorBoundMaxR = floor(MultiplyBoundMaxR);
        
        float SubtractBoundMaxR = MultiplyBoundMaxR - FloorBoundMaxR;
        
        float OneMinusBoundMaxR = 1 - SubtractBoundMaxR;

        // UV 坐标计算   
        float uvMultiplier = OneMinusUV1g * OneMinusBoundMaxR;
            
        // 时间参数
        float b_autoPlay = b_autoPlayback;
        float currentTime = _Input_Time;
        float  startTime = _Game_Time_at_First_Frame;
        float elapsedTime = currentTime - startTime;
            
        // 动画参数
        float fps = HoudiniFPS;
        float totalFrames = FrameCount;
        float adjustedFrames = totalFrames - 0.01;
        float playbackSpeed = PlaybackSpeed;
        float displayFrame = DisplayFrame;
            
        // 计算当前帧
        float timeToFrameRatio = fps / adjustedFrames;
        
        float scaledTime = elapsedTime * timeToFrameRatio;
        
        float animatedTime = scaledTime * playbackSpeed;
        
        float frameFraction = frac(animatedTime);
        
        float frameFloat = frameFraction * totalFrames;
        
        float currentFrameIndex = floor(frameFloat);
        float nextFrameIndex = currentFrameIndex + 1;
            
        // 选择帧索引：自动播放 或 手动指定
        float manualFrameIndex = floor(displayFrame);
        
        float selectedFrame = b_autoPlay ? nextFrameIndex : manualFrameIndex;
            
        // 帧循环处理
        float wrappedFrame = (selectedFrame - 1) % totalFrames;
        float totalFramesDivide = 1 / totalFrames;
            
        float frameNormalized = wrappedFrame * totalFramesDivide;
        float frameOffset = frameNormalized * OneMinusBoundMaxR;
            
        // 最终 V 坐标
        float vCoordBase = uvMultiplier + frameOffset;
        float vCoordFinal = 1 - vCoordBase;
        float2 texcoordUV = float2(MultiplyBoundMinB, vCoordFinal);
        
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 rotSample = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 rotSample = SAMPLE_TEXTURE2D_LOD(rotTexture.tex, rotTexture.samplerstate, rotTexture.GetTransformedUV(texcoordUV), 0);
        #endif
            
        // 方法1: 重映射到有符号范围 [-1, +1]
        // 公式: signed = (unsigned - 0.5) * 2
        float4 rotRemapped = (rotSample - float4(0.5, 0.5, 0.5, 0.5)) * float4(2, 2, 2, 2);
            
        // 根据条件选择：使用原始值还是重映射值
        // (ComparisonBoundMaxb 可能判断是否需要重映射)
        float4 rotFinal = ComparisonBoundMaxb ? rotSample : rotRemapped;

        // 提取最终值的各个分量
        float rotFinalR = rotFinal.r;
        float rotFinalG = rotFinal.g;
        float rotFinalB = rotFinal.b;
        float rotFinalA = rotFinal.a;

        float hasRotation = (rotFinalA != 0);
        
        float3 rotXYZ = float3(rotFinalR, rotFinalG, rotFinalB);
        
        UnityTexture2D posTexture = pos_texture;
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 posSample = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 posSample = SAMPLE_TEXTURE2D_LOD(posTexture.tex, posTexture.samplerstate, posTexture.GetTransformedUV(texcoordUV), 0);
        #endif

        // 提取位置纹理数据 
        float posR = posSample.r;
        float posG = posSample.g;
        float posB = posSample.b;
        float posA = posSample.a;
            
        // 解码四元数的最大分量索引 (存储在Alpha通道)
        float quatMaxIdxScaled = posA * 4.0;
        float quatMaxIdx = floor(quatMaxIdxScaled);
            
        // 从3分量重建完整四元数
        float4 quaternion;
        Decode_Quaternion_float(rotXYZ, quatMaxIdx, quaternion);
            
        // 平滑插值权重计算 (Smooth Trajectories)
        // 位置Alpha的绝对值
        float posAlphaAbs = abs(rotFinalA);

        // 计算边界相关的插值因子
        float boundMinNeg = boundMinMul10.r * -1.0;
        float boundMinFloor = floor(boundMinNeg);
        float  boundMinFrac = boundMinNeg - boundMinFloor;
        float boundMinInv = 1.0 - boundMinFrac;
        float invBoundMinInv = 1.0 / boundMinInv;

        // 缩放posAlpha
        float scaledPosAlpha = posAlphaAbs * invBoundMinInv;
        // 根据条件选择插值权重
        float interpWeight = ComparisonBoundMaxb ? posAlphaAbs : scaledPosAlpha;
        // 帧间插值相位计算
        // 当前帧的小数部分
        float frameFrac1 = frac(interpWeight);
        float phase1 = frameFrac1 * 0.5;
        // 选择当前帧或显示帧
        float activeFrame = b_autoPlay ? frameFloat : displayFrame;
        float activeFrameFrac = frac(activeFrame);
        // 计算加权相位
        float weightedFrac = interpWeight * activeFrameFrac;
        float frameFrac2 = frac(weightedFrac);
        float phase2 = frameFrac2 * 0.5;
            
        // 相位差
        float phaseDelta = phase1 - phase2;
        // 正弦插值权重 (物理正确的轨迹)
        // float TWO_PI = 6.283185;
        // 当前帧权重
        float angle1 = phaseDelta * TWO_PI;
        float weight1 = sin(angle1);
        // 应用权重到四元数
        float4 weightedQuat1 = quaternion * weight1;
        // 下一帧UV坐标计算
        // 计算下一帧索引
        float nextFrameWrapped = selectedFrame % totalFrames;
        float nextFrameNorm = nextFrameWrapped * totalFramesDivide;
        float nextFrameOffset = nextFrameNorm * OneMinusBoundMaxR;
        // 合成UV坐标
        float vCoordNext = uvMultiplier + nextFrameOffset;
        float vFinalNext = 1.0 - vCoordNext;
        // 下一帧UV
        float2 texcoordNextFrame = float2(MultiplyBoundMinB, vFinalNext);
            
        // 下一帧旋转数据采样              
        // 采样下一帧旋转纹理
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 rotSampleNext = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 rotSampleNext = SAMPLE_TEXTURE2D_LOD(rotTexture.tex, rotTexture.samplerstate, rotTexture.GetTransformedUV(texcoordNextFrame), 0);
        #endif
        
        float4 rotRemappedNext = (rotSampleNext - 0.5) * 2.0;
        float4 rotDataNext = ComparisonBoundMaxb ? rotSampleNext : rotRemappedNext;
        float3 rotXYZNext = rotDataNext.rgb;

        // 下一帧位置采样
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 posSampleNext = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 posSampleNext = SAMPLE_TEXTURE2D_LOD(posTexture.tex, posTexture.samplerstate, posTexture.GetTransformedUV(texcoordNextFrame), 0);
        #endif
        float _SampleTexture2DLOD_d92919bca21f48e29f52a6d33023c4aa_R_5_Float = posSampleNext.r;
        float _SampleTexture2DLOD_d92919bca21f48e29f52a6d33023c4aa_G_6_Float = posSampleNext.g;
        float _SampleTexture2DLOD_d92919bca21f48e29f52a6d33023c4aa_B_7_Float = posSampleNext.b;
        float _SampleTexture2DLOD_d92919bca21f48e29f52a6d33023c4aa_A_8_Float = posSampleNext.a;
        float _Multiply_3bef55aa6ed148a398fe70ea0b10dafc_Out_2_Float;
        Unity_Multiply_float_float(_SampleTexture2DLOD_d92919bca21f48e29f52a6d33023c4aa_A_8_Float, 4, _Multiply_3bef55aa6ed148a398fe70ea0b10dafc_Out_2_Float);
        float _Floor_e0a98d028f1749d3b749bc97c81a569e_Out_1_Float;
        Unity_Floor_float(_Multiply_3bef55aa6ed148a398fe70ea0b10dafc_Out_2_Float, _Floor_e0a98d028f1749d3b749bc97c81a569e_Out_1_Float);
        float4 _DecodeQuaternionCustomFunction_08bdc03b6109407d96635e4daa8cb042_OutXYZW_2_Vector4;
        Decode_Quaternion_float(rotXYZNext, _Floor_e0a98d028f1749d3b749bc97c81a569e_Out_1_Float, _DecodeQuaternionCustomFunction_08bdc03b6109407d96635e4daa8cb042_OutXYZW_2_Vector4);
        float _Sign_7914421bf9ea49859d084a55fc0b937e_Out_1_Float;
        Unity_Sign_float(rotFinalA, _Sign_7914421bf9ea49859d084a55fc0b937e_Out_1_Float);
        float4 _Multiply_954d292058014c3780fc85e85b37ff58_Out_2_Vector4;
        Unity_Multiply_float4_float4(_DecodeQuaternionCustomFunction_08bdc03b6109407d96635e4daa8cb042_OutXYZW_2_Vector4, (_Sign_7914421bf9ea49859d084a55fc0b937e_Out_1_Float.xxxx), _Multiply_954d292058014c3780fc85e85b37ff58_Out_2_Vector4);
        float _Multiply_3934041d4da34f33a378403df611cb3b_Out_2_Float;
        Unity_Multiply_float_float(phase2, TWO_PI, _Multiply_3934041d4da34f33a378403df611cb3b_Out_2_Float);
        float _Sine_44c8fe0289b44c2baa95d34b5f14564b_Out_1_Float;
        Unity_Sine_float(_Multiply_3934041d4da34f33a378403df611cb3b_Out_2_Float, _Sine_44c8fe0289b44c2baa95d34b5f14564b_Out_1_Float);
        float4 _Multiply_43567b2eb3b54a958fbdf2132c76c3db_Out_2_Vector4;
        Unity_Multiply_float4_float4(_Multiply_954d292058014c3780fc85e85b37ff58_Out_2_Vector4, (_Sine_44c8fe0289b44c2baa95d34b5f14564b_Out_1_Float.xxxx), _Multiply_43567b2eb3b54a958fbdf2132c76c3db_Out_2_Vector4);
        float4 _Add_37b459ad577245e7adc9018101dd96e6_Out_2_Vector4;
        Unity_Add_float4(weightedQuat1, _Multiply_43567b2eb3b54a958fbdf2132c76c3db_Out_2_Vector4, _Add_37b459ad577245e7adc9018101dd96e6_Out_2_Vector4);
        float _Multiply_949e9ecdf588438bbf90616ea0fa6358_Out_2_Float;
        Unity_Multiply_float_float(phase1, TWO_PI, _Multiply_949e9ecdf588438bbf90616ea0fa6358_Out_2_Float);
        float _Sine_9716d493df4c4225b1be55410aa3b6d8_Out_1_Float;
        Unity_Sine_float(_Multiply_949e9ecdf588438bbf90616ea0fa6358_Out_2_Float, _Sine_9716d493df4c4225b1be55410aa3b6d8_Out_1_Float);
        float4 _Divide_20fbc487f25240c7802ac61ae2d336c6_Out_2_Vector4;
        Unity_Divide_float4(_Add_37b459ad577245e7adc9018101dd96e6_Out_2_Vector4, (_Sine_9716d493df4c4225b1be55410aa3b6d8_Out_1_Float.xxxx), _Divide_20fbc487f25240c7802ac61ae2d336c6_Out_2_Vector4);
        float4 _Normalize_c028599e0d1d4c5985b78c33212f9a0c_Out_1_Vector4;
        Unity_Normalize_float4(_Divide_20fbc487f25240c7802ac61ae2d336c6_Out_2_Vector4, _Normalize_c028599e0d1d4c5985b78c33212f9a0c_Out_1_Vector4);
        float4 _Branch_eb507c876e864ee08168417cee04d1fc_Out_3_Vector4;
        Unity_Branch_float4(hasRotation, _Normalize_c028599e0d1d4c5985b78c33212f9a0c_Out_1_Vector4, quaternion, _Branch_eb507c876e864ee08168417cee04d1fc_Out_3_Vector4);
        float4 _Branch_2db7ae80ee1a4fa7aad5c113e11603b8_Out_3_Vector4;
        Unity_Branch_float4(_Interframe_Interpolation, _Branch_eb507c876e864ee08168417cee04d1fc_Out_3_Vector4, quaternion, _Branch_2db7ae80ee1a4fa7aad5c113e11603b8_Out_3_Vector4);
        float _Split_70d7fe38e42f4a49b6a12b4a28073bfb_R_1_Float = _Branch_2db7ae80ee1a4fa7aad5c113e11603b8_Out_3_Vector4[0];
        float _Split_70d7fe38e42f4a49b6a12b4a28073bfb_G_2_Float = _Branch_2db7ae80ee1a4fa7aad5c113e11603b8_Out_3_Vector4[1];
        float _Split_70d7fe38e42f4a49b6a12b4a28073bfb_B_3_Float = _Branch_2db7ae80ee1a4fa7aad5c113e11603b8_Out_3_Vector4[2];
        float _Split_70d7fe38e42f4a49b6a12b4a28073bfb_A_4_Float = _Branch_2db7ae80ee1a4fa7aad5c113e11603b8_Out_3_Vector4[3];
        float4 _Combine_c62cf49352cf4def93cd35bff786a4f8_RGBA_4_Vector4;
        float3 _Combine_c62cf49352cf4def93cd35bff786a4f8_RGB_5_Vector3;
        float2 _Combine_c62cf49352cf4def93cd35bff786a4f8_RG_6_Vector2;
        Unity_Combine_float(_Split_70d7fe38e42f4a49b6a12b4a28073bfb_R_1_Float, _Split_70d7fe38e42f4a49b6a12b4a28073bfb_G_2_Float, _Split_70d7fe38e42f4a49b6a12b4a28073bfb_B_3_Float, 0, _Combine_c62cf49352cf4def93cd35bff786a4f8_RGBA_4_Vector4, _Combine_c62cf49352cf4def93cd35bff786a4f8_RGB_5_Vector3, _Combine_c62cf49352cf4def93cd35bff786a4f8_RG_6_Vector2);
        float4 _UV_fa8f02ef2e484ce2a563a00bd562b3c7_Out_0_Vector4 = IN.uv2;
        float _Split_7afd517dccf7404b99a40dd3c607f89b_R_1_Float = _UV_fa8f02ef2e484ce2a563a00bd562b3c7_Out_0_Vector4[0];
        float _Split_7afd517dccf7404b99a40dd3c607f89b_G_2_Float = _UV_fa8f02ef2e484ce2a563a00bd562b3c7_Out_0_Vector4[1];
        float _Split_7afd517dccf7404b99a40dd3c607f89b_B_3_Float = _UV_fa8f02ef2e484ce2a563a00bd562b3c7_Out_0_Vector4[2];
        float _Split_7afd517dccf7404b99a40dd3c607f89b_A_4_Float = _UV_fa8f02ef2e484ce2a563a00bd562b3c7_Out_0_Vector4[3];
        float _Multiply_d6360a1521fb48a0a05cd08d73eed501_Out_2_Float;
        Unity_Multiply_float_float(_Split_7afd517dccf7404b99a40dd3c607f89b_R_1_Float, -1, _Multiply_d6360a1521fb48a0a05cd08d73eed501_Out_2_Float);
        float4 _UV_8b83443e55e74c1e9ec329aea8e41f00_Out_0_Vector4 = IN.uv3;
        float _Split_a3e34a5b0d534cd59d8920be9a923edf_R_1_Float = _UV_8b83443e55e74c1e9ec329aea8e41f00_Out_0_Vector4[0];
        float _Split_a3e34a5b0d534cd59d8920be9a923edf_G_2_Float = _UV_8b83443e55e74c1e9ec329aea8e41f00_Out_0_Vector4[1];
        float _Split_a3e34a5b0d534cd59d8920be9a923edf_B_3_Float = _UV_8b83443e55e74c1e9ec329aea8e41f00_Out_0_Vector4[2];
        float _Split_a3e34a5b0d534cd59d8920be9a923edf_A_4_Float = _UV_8b83443e55e74c1e9ec329aea8e41f00_Out_0_Vector4[3];
        float _OneMinus_098c078147344a55a81768b536131833_Out_1_Float;
        Unity_OneMinus_float(_Split_a3e34a5b0d534cd59d8920be9a923edf_G_2_Float, _OneMinus_098c078147344a55a81768b536131833_Out_1_Float);
        float4 _Combine_c5b8f60c79034bba86a0dcdd200aaf52_RGBA_4_Vector4;
        float3 _Combine_c5b8f60c79034bba86a0dcdd200aaf52_RGB_5_Vector3;
        float2 _Combine_c5b8f60c79034bba86a0dcdd200aaf52_RG_6_Vector2;
        Unity_Combine_float(_Multiply_d6360a1521fb48a0a05cd08d73eed501_Out_2_Float, _Split_a3e34a5b0d534cd59d8920be9a923edf_R_1_Float, _OneMinus_098c078147344a55a81768b536131833_Out_1_Float, 0, _Combine_c5b8f60c79034bba86a0dcdd200aaf52_RGBA_4_Vector4, _Combine_c5b8f60c79034bba86a0dcdd200aaf52_RGB_5_Vector3, _Combine_c5b8f60c79034bba86a0dcdd200aaf52_RG_6_Vector2);
        float3 _Subtract_7d4d4fd0026a43aba75a54d7606035d0_Out_2_Vector3;
        Unity_Subtract_float3(IN.ObjectSpacePosition, _Combine_c5b8f60c79034bba86a0dcdd200aaf52_RGB_5_Vector3, _Subtract_7d4d4fd0026a43aba75a54d7606035d0_Out_2_Vector3);
        float3 _CrossProduct_34801cb8e20c421c9c778d4af18a612f_Out_2_Vector3;
        Unity_CrossProduct_float(_Combine_c62cf49352cf4def93cd35bff786a4f8_RGB_5_Vector3, _Subtract_7d4d4fd0026a43aba75a54d7606035d0_Out_2_Vector3, _CrossProduct_34801cb8e20c421c9c778d4af18a612f_Out_2_Vector3);
        float3 _Multiply_25a9cad507fe42db8daf9dcecc21befc_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_7d4d4fd0026a43aba75a54d7606035d0_Out_2_Vector3, (_Split_70d7fe38e42f4a49b6a12b4a28073bfb_A_4_Float.xxx), _Multiply_25a9cad507fe42db8daf9dcecc21befc_Out_2_Vector3);
        float3 _Add_e51d5fd36c61408ab4ff0f915e815b9d_Out_2_Vector3;
        Unity_Add_float3(_CrossProduct_34801cb8e20c421c9c778d4af18a612f_Out_2_Vector3, _Multiply_25a9cad507fe42db8daf9dcecc21befc_Out_2_Vector3, _Add_e51d5fd36c61408ab4ff0f915e815b9d_Out_2_Vector3);
        float3 _CrossProduct_f6d776468af0467fa5a8e9c53c8ded57_Out_2_Vector3;
        Unity_CrossProduct_float(_Combine_c62cf49352cf4def93cd35bff786a4f8_RGB_5_Vector3, _Add_e51d5fd36c61408ab4ff0f915e815b9d_Out_2_Vector3, _CrossProduct_f6d776468af0467fa5a8e9c53c8ded57_Out_2_Vector3);
        float3 _Multiply_d5c943298de44bc68d77c2a6ef0e2021_Out_2_Vector3;
        Unity_Multiply_float3_float3(_CrossProduct_f6d776468af0467fa5a8e9c53c8ded57_Out_2_Vector3, float3(2, 2, 2), _Multiply_d5c943298de44bc68d77c2a6ef0e2021_Out_2_Vector3);
        float3 _Add_35cadb8beba84319b7c86c86694dcab6_Out_2_Vector3;
        Unity_Add_float3(_Multiply_d5c943298de44bc68d77c2a6ef0e2021_Out_2_Vector3, _Subtract_7d4d4fd0026a43aba75a54d7606035d0_Out_2_Vector3, _Add_35cadb8beba84319b7c86c86694dcab6_Out_2_Vector3);
        float _Property_c7e79dafca81422598d644abb0295581_Out_0_Boolean = b_stretchByVel;
        float _Property_a0ba1f43faf044b68041f47417cbd7af_Out_0_Boolean = _Interframe_Interpolation;
        float _Property_eadb5ba513a6498e8244047c79345758_Out_0_Boolean = _Interpolate_Color;
        float _And_f3054b8d20aa48bfae7a5d53c8acc3cc_Out_2_Boolean;
        Unity_And_float(_Property_a0ba1f43faf044b68041f47417cbd7af_Out_0_Boolean, _Property_eadb5ba513a6498e8244047c79345758_Out_0_Boolean, _And_f3054b8d20aa48bfae7a5d53c8acc3cc_Out_2_Boolean);
        UnityTexture2D _Property_2aa42de9e6e04e418c75ca022cb8072c_Out_0_Texture2D = ColTexture;
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_1c09d18b469d42cba4408dce5ff8f8ab_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_1c09d18b469d42cba4408dce5ff8f8ab_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_2aa42de9e6e04e418c75ca022cb8072c_Out_0_Texture2D.tex, _Property_2aa42de9e6e04e418c75ca022cb8072c_Out_0_Texture2D.samplerstate, _Property_2aa42de9e6e04e418c75ca022cb8072c_Out_0_Texture2D.GetTransformedUV(texcoordUV), 0);
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
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_c6fd58a33ebf447694f7269eaf935a8b_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_c6fd58a33ebf447694f7269eaf935a8b_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_2aa42de9e6e04e418c75ca022cb8072c_Out_0_Texture2D.tex, _Property_2aa42de9e6e04e418c75ca022cb8072c_Out_0_Texture2D.samplerstate, _Property_2aa42de9e6e04e418c75ca022cb8072c_Out_0_Texture2D.GetTransformedUV(texcoordNextFrame), 0);
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
        float4 _Lerp_711aa73fbc3f4d319b13362297282106_Out_3_Vector4;
        Unity_Lerp_float4(_LoadColorTexture_f0d31671e10846148e10ff6f6ddcce87_Out_0_Vector4, _LoadColorTexture_cc743dddac284c769882b4847ff7576b_Out_0_Vector4, (activeFrameFrac.xxxx), _Lerp_711aa73fbc3f4d319b13362297282106_Out_3_Vector4);
        float4 _Branch_3c68277c1c8744a59f98768785e6c5e7_Out_3_Vector4;
        Unity_Branch_float4(_And_f3054b8d20aa48bfae7a5d53c8acc3cc_Out_2_Boolean, _Lerp_711aa73fbc3f4d319b13362297282106_Out_3_Vector4, _LoadColorTexture_f0d31671e10846148e10ff6f6ddcce87_Out_0_Vector4, _Branch_3c68277c1c8744a59f98768785e6c5e7_Out_3_Vector4);
        float _Split_4d8e2369f047422c8b3838da41666224_R_1_Float = _Branch_3c68277c1c8744a59f98768785e6c5e7_Out_3_Vector4[0];
        float _Split_4d8e2369f047422c8b3838da41666224_G_2_Float = _Branch_3c68277c1c8744a59f98768785e6c5e7_Out_3_Vector4[1];
        float _Split_4d8e2369f047422c8b3838da41666224_B_3_Float = _Branch_3c68277c1c8744a59f98768785e6c5e7_Out_3_Vector4[2];
        float _Split_4d8e2369f047422c8b3838da41666224_A_4_Float = _Branch_3c68277c1c8744a59f98768785e6c5e7_Out_3_Vector4[3];
        float _Multiply_ce19a663a8d547228ed9314e5bc8dea9_Out_2_Float;
        Unity_Multiply_float_float(_Split_4d8e2369f047422c8b3838da41666224_R_1_Float, -1, _Multiply_ce19a663a8d547228ed9314e5bc8dea9_Out_2_Float);
        float4 _Combine_1840611a245a41ba91ab0037d21ece7c_RGBA_4_Vector4;
        float3 _Combine_1840611a245a41ba91ab0037d21ece7c_RGB_5_Vector3;
        float2 _Combine_1840611a245a41ba91ab0037d21ece7c_RG_6_Vector2;
        Unity_Combine_float(_Multiply_ce19a663a8d547228ed9314e5bc8dea9_Out_2_Float, _Split_4d8e2369f047422c8b3838da41666224_G_2_Float, _Split_4d8e2369f047422c8b3838da41666224_B_3_Float, 0, _Combine_1840611a245a41ba91ab0037d21ece7c_RGBA_4_Vector4, _Combine_1840611a245a41ba91ab0037d21ece7c_RGB_5_Vector3, _Combine_1840611a245a41ba91ab0037d21ece7c_RG_6_Vector2);
        float3 _Vector3_15aecf0488824eeea4967cba0231c95e_Out_0_Vector3 = float3(0, 0, 0);
        float3 _Branch_242e07af2d894b35bfd183d5797f6838_Out_3_Vector3;
        Unity_Branch_float3(_Property_c7e79dafca81422598d644abb0295581_Out_0_Boolean, _Combine_1840611a245a41ba91ab0037d21ece7c_RGB_5_Vector3, _Vector3_15aecf0488824eeea4967cba0231c95e_Out_0_Vector3, _Branch_242e07af2d894b35bfd183d5797f6838_Out_3_Vector3);
        float3 _Absolute_447686bfd2ba4354a5e54d566a3007d7_Out_1_Vector3;
        Unity_Absolute_float3(_Branch_242e07af2d894b35bfd183d5797f6838_Out_3_Vector3, _Absolute_447686bfd2ba4354a5e54d566a3007d7_Out_1_Vector3);
        float _Property_bd4c17c3b42945fc8b675c6d8b2657c4_Out_0_Float = StretchByVelAmount;
        float3 _Multiply_f4488f9db2d54d4eb411deee45cdaec0_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Absolute_447686bfd2ba4354a5e54d566a3007d7_Out_1_Vector3, (_Property_bd4c17c3b42945fc8b675c6d8b2657c4_Out_0_Float.xxx), _Multiply_f4488f9db2d54d4eb411deee45cdaec0_Out_2_Vector3);
        float3 _Add_9d3cdc7ed2da4ff287ed700521fb79cb_Out_2_Vector3;
        Unity_Add_float3(_Multiply_f4488f9db2d54d4eb411deee45cdaec0_Out_2_Vector3, float3(1, 1, 1), _Add_9d3cdc7ed2da4ff287ed700521fb79cb_Out_2_Vector3);
        float _Property_8ee8917f00e3449395c5eea43291705f_Out_0_Float = GlobalPscaleMul;
        float3 _Multiply_f845b91c6da540e183cbcdfaed766334_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Add_9d3cdc7ed2da4ff287ed700521fb79cb_Out_2_Vector3, (_Property_8ee8917f00e3449395c5eea43291705f_Out_0_Float.xxx), _Multiply_f845b91c6da540e183cbcdfaed766334_Out_2_Vector3);
        float _Property_186f741aac5e416aa8ebd42eae9efe37_Out_0_Boolean = b_pscaleAreInPosA;
        float _Floor_85c378b26acf448082167d21248936fd_Out_1_Float;
        Unity_Floor_float(boundMaxMul10.g, _Floor_85c378b26acf448082167d21248936fd_Out_1_Float);
        float _Subtract_6e96b166ec394865919eea36f8129ff9_Out_2_Float;
        Unity_Subtract_float(boundMaxMul10.g, _Floor_85c378b26acf448082167d21248936fd_Out_1_Float, _Subtract_6e96b166ec394865919eea36f8129ff9_Out_2_Float);
        float _OneMinus_af2916e9237347d78467467e0d2806a4_Out_1_Float;
        Unity_OneMinus_float(_Subtract_6e96b166ec394865919eea36f8129ff9_Out_2_Float, _OneMinus_af2916e9237347d78467467e0d2806a4_Out_1_Float);
        float _Divide_569c994b2ab34847bd4a297c59a7ca80_Out_2_Float;
        Unity_Divide_float(1, _OneMinus_af2916e9237347d78467467e0d2806a4_Out_1_Float, _Divide_569c994b2ab34847bd4a297c59a7ca80_Out_2_Float);
        float _Property_107ccb5b88da4d1cad7d392c75edb794_Out_0_Boolean = _Interframe_Interpolation;
        float _Fraction_0dc32141f20a48d3b9756b16c416b3a4_Out_1_Float;
        Unity_Fraction_float(quatMaxIdxScaled, _Fraction_0dc32141f20a48d3b9756b16c416b3a4_Out_1_Float);
        float _OneMinus_9b87aca1ae574fd289bcfc7b1beb7820_Out_1_Float;
        Unity_OneMinus_float(_Fraction_0dc32141f20a48d3b9756b16c416b3a4_Out_1_Float, _OneMinus_9b87aca1ae574fd289bcfc7b1beb7820_Out_1_Float);
        float _Fraction_741137d353274eaca925a62fc252e2f7_Out_1_Float;
        Unity_Fraction_float(_Multiply_3bef55aa6ed148a398fe70ea0b10dafc_Out_2_Float, _Fraction_741137d353274eaca925a62fc252e2f7_Out_1_Float);
        float _OneMinus_fe03f4b292834b7991037367f130cefa_Out_1_Float;
        Unity_OneMinus_float(_Fraction_741137d353274eaca925a62fc252e2f7_Out_1_Float, _OneMinus_fe03f4b292834b7991037367f130cefa_Out_1_Float);
        float _Lerp_c236e21084c048258b89aa1f6f8df177_Out_3_Float;
        Unity_Lerp_float(_OneMinus_9b87aca1ae574fd289bcfc7b1beb7820_Out_1_Float, _OneMinus_fe03f4b292834b7991037367f130cefa_Out_1_Float, activeFrameFrac, _Lerp_c236e21084c048258b89aa1f6f8df177_Out_3_Float);
        float _Branch_15ae6925b3d54c46a9b155c30c08257d_Out_3_Float;
        Unity_Branch_float(_Property_107ccb5b88da4d1cad7d392c75edb794_Out_0_Boolean, _Lerp_c236e21084c048258b89aa1f6f8df177_Out_3_Float, _OneMinus_9b87aca1ae574fd289bcfc7b1beb7820_Out_1_Float, _Branch_15ae6925b3d54c46a9b155c30c08257d_Out_3_Float);
        float _Multiply_864a587ed0774fceb6983b19629dca8b_Out_2_Float;
        Unity_Multiply_float_float(_Divide_569c994b2ab34847bd4a297c59a7ca80_Out_2_Float, _Branch_15ae6925b3d54c46a9b155c30c08257d_Out_3_Float, _Multiply_864a587ed0774fceb6983b19629dca8b_Out_2_Float);
        float _Branch_e19e3a90853948fcb7579b26d288868c_Out_3_Float;
        Unity_Branch_float(_Property_186f741aac5e416aa8ebd42eae9efe37_Out_0_Boolean, _Multiply_864a587ed0774fceb6983b19629dca8b_Out_2_Float, 1, _Branch_e19e3a90853948fcb7579b26d288868c_Out_3_Float);
        float3 _Multiply_3bb4a7e6c4104359a4a521977dc04358_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_f845b91c6da540e183cbcdfaed766334_Out_2_Vector3, (_Branch_e19e3a90853948fcb7579b26d288868c_Out_3_Float.xxx), _Multiply_3bb4a7e6c4104359a4a521977dc04358_Out_2_Vector3);
        float3 _Multiply_ae9a523d22654befb80a94a4d9838cfe_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Add_35cadb8beba84319b7c86c86694dcab6_Out_2_Vector3, _Multiply_3bb4a7e6c4104359a4a521977dc04358_Out_2_Vector3, _Multiply_ae9a523d22654befb80a94a4d9838cfe_Out_2_Vector3);
        float _Property_1238b8669b754229a924fa19745c9a3a_Out_0_Boolean = _Interframe_Interpolation;
        float _Floor_8451392599f740c2aaf9026063cf9e17_Out_1_Float;
        Unity_Floor_float(selectedFrame, _Floor_8451392599f740c2aaf9026063cf9e17_Out_1_Float);
        float _Modulo_31665d96abb54fd6894ec4d43962941c_Out_2_Float;
        Unity_Modulo_float(_Floor_8451392599f740c2aaf9026063cf9e17_Out_1_Float, totalFrames, _Modulo_31665d96abb54fd6894ec4d43962941c_Out_2_Float);
        float _Subtract_9a3fa8f96fab4c788c2a9eece8c414f5_Out_2_Float;
        Unity_Subtract_float(_Modulo_31665d96abb54fd6894ec4d43962941c_Out_2_Float, 1, _Subtract_9a3fa8f96fab4c788c2a9eece8c414f5_Out_2_Float);
        float _Absolute_1593ad46b9904444acb0ca8f23eb1242_Out_1_Float;
        Unity_Absolute_float(_Subtract_9a3fa8f96fab4c788c2a9eece8c414f5_Out_2_Float, _Absolute_1593ad46b9904444acb0ca8f23eb1242_Out_1_Float);
        float _Saturate_746ef44d6a8b412f8ee64846753f0c6b_Out_1_Float;
        Unity_Saturate_float(_Absolute_1593ad46b9904444acb0ca8f23eb1242_Out_1_Float, _Saturate_746ef44d6a8b412f8ee64846753f0c6b_Out_1_Float);
        float _Subtract_5ff69817d07a41e7b6302a18951b02c9_Out_2_Float;
        Unity_Subtract_float(_Modulo_31665d96abb54fd6894ec4d43962941c_Out_2_Float, totalFrames, _Subtract_5ff69817d07a41e7b6302a18951b02c9_Out_2_Float);
        float _Absolute_46cc16ef94cf404288d82dd9f79350d8_Out_1_Float;
        Unity_Absolute_float(_Subtract_5ff69817d07a41e7b6302a18951b02c9_Out_2_Float, _Absolute_46cc16ef94cf404288d82dd9f79350d8_Out_1_Float);
        float _Saturate_842a3cbdf84c440b8c50b27eaa68917f_Out_1_Float;
        Unity_Saturate_float(_Absolute_46cc16ef94cf404288d82dd9f79350d8_Out_1_Float, _Saturate_842a3cbdf84c440b8c50b27eaa68917f_Out_1_Float);
        float _Multiply_2407536f9f5d449daed4b604dd11a1e7_Out_2_Float;
        Unity_Multiply_float_float(_Saturate_746ef44d6a8b412f8ee64846753f0c6b_Out_1_Float, _Saturate_842a3cbdf84c440b8c50b27eaa68917f_Out_1_Float, _Multiply_2407536f9f5d449daed4b604dd11a1e7_Out_2_Float);
        float _Comparison_a8c089c976024f2ebd3b2c6e3f328243_Out_2_Boolean;
        Unity_Comparison_Greater_float(_Multiply_2407536f9f5d449daed4b604dd11a1e7_Out_2_Float, 0, _Comparison_a8c089c976024f2ebd3b2c6e3f328243_Out_2_Boolean);
        float4 _Combine_3a3a46b2dd084ef5b50d1c94bd1bf662_RGBA_4_Vector4;
        float3 _Combine_3a3a46b2dd084ef5b50d1c94bd1bf662_RGB_5_Vector3;
        float2 _Combine_3a3a46b2dd084ef5b50d1c94bd1bf662_RG_6_Vector2;
        Unity_Combine_float(_SampleTexture2DLOD_d92919bca21f48e29f52a6d33023c4aa_R_5_Float, _SampleTexture2DLOD_d92919bca21f48e29f52a6d33023c4aa_G_6_Float, _SampleTexture2DLOD_d92919bca21f48e29f52a6d33023c4aa_B_7_Float, 0, _Combine_3a3a46b2dd084ef5b50d1c94bd1bf662_RGBA_4_Vector4, _Combine_3a3a46b2dd084ef5b50d1c94bd1bf662_RGB_5_Vector3, _Combine_3a3a46b2dd084ef5b50d1c94bd1bf662_RG_6_Vector2);
        UnityTexture2D _Property_88cc07c51d1d4c2ea2801e86f6a9f044_Out_0_Texture2D = pos_texture2;
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_d1665f30f3c74d54b5b2be5e322ee59e_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_d1665f30f3c74d54b5b2be5e322ee59e_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_88cc07c51d1d4c2ea2801e86f6a9f044_Out_0_Texture2D.tex, _Property_88cc07c51d1d4c2ea2801e86f6a9f044_Out_0_Texture2D.samplerstate, _Property_88cc07c51d1d4c2ea2801e86f6a9f044_Out_0_Texture2D.GetTransformedUV(texcoordNextFrame), 0);
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
        Unity_Subtract_float3(boundMaxCombine_RGB, boundMinCombine_RGB, _Subtract_83069528d6794190a7bbec7f91d26eb4_Out_2_Vector3);
        float3 _Multiply_76ae98c658fe4213ac5482dd0c399267_Out_2_Vector3;
        Unity_Multiply_float3_float3(_PositionsRequireTwoTextures_953c53d9543e4e83863d6f6fc765ab90_Out_0_Vector3, _Subtract_83069528d6794190a7bbec7f91d26eb4_Out_2_Vector3, _Multiply_76ae98c658fe4213ac5482dd0c399267_Out_2_Vector3);
        float3 _Add_dda8c9ca0e7d43e2a04a2882c29f90d7_Out_2_Vector3;
        Unity_Add_float3(_Multiply_76ae98c658fe4213ac5482dd0c399267_Out_2_Vector3, boundMinCombine_RGB, _Add_dda8c9ca0e7d43e2a04a2882c29f90d7_Out_2_Vector3);
        float3 _Branch_6abcc2317e104339a2decf93e9aee587_Out_3_Vector3;
        Unity_Branch_float3(ComparisonBoundMaxb, _PositionsRequireTwoTextures_953c53d9543e4e83863d6f6fc765ab90_Out_0_Vector3, _Add_dda8c9ca0e7d43e2a04a2882c29f90d7_Out_2_Vector3, _Branch_6abcc2317e104339a2decf93e9aee587_Out_3_Vector3);
        float _Subtract_23e431f62c684e8a8c79463d4883d924_Out_2_Float;
        Unity_Subtract_float(selectedFrame, 2, _Subtract_23e431f62c684e8a8c79463d4883d924_Out_2_Float);
        float _Modulo_4fa22a36c1a74f2caca4dde1485497a5_Out_2_Float;
        Unity_Modulo_float(_Subtract_23e431f62c684e8a8c79463d4883d924_Out_2_Float, totalFrames, _Modulo_4fa22a36c1a74f2caca4dde1485497a5_Out_2_Float);
        float _Multiply_86c00bc3990045fbbce849f2ee279dc8_Out_2_Float;
        Unity_Multiply_float_float(_Modulo_4fa22a36c1a74f2caca4dde1485497a5_Out_2_Float, totalFramesDivide, _Multiply_86c00bc3990045fbbce849f2ee279dc8_Out_2_Float);
        float _Multiply_48ab7ff273e047839ee54f47a6412481_Out_2_Float;
        Unity_Multiply_float_float(_Multiply_86c00bc3990045fbbce849f2ee279dc8_Out_2_Float, OneMinusBoundMaxR, _Multiply_48ab7ff273e047839ee54f47a6412481_Out_2_Float);
        float _Add_54623ae385a0479db3407044f6434b68_Out_2_Float;
        Unity_Add_float(uvMultiplier, _Multiply_48ab7ff273e047839ee54f47a6412481_Out_2_Float, _Add_54623ae385a0479db3407044f6434b68_Out_2_Float);
        float _OneMinus_42761850f55345a2817d77c53379b8e3_Out_1_Float;
        Unity_OneMinus_float(_Add_54623ae385a0479db3407044f6434b68_Out_2_Float, _OneMinus_42761850f55345a2817d77c53379b8e3_Out_1_Float);
        float4 _Combine_3239577421b246bbaaa02adf4ba9b356_RGBA_4_Vector4;
        float3 _Combine_3239577421b246bbaaa02adf4ba9b356_RGB_5_Vector3;
        float2 _Combine_3239577421b246bbaaa02adf4ba9b356_RG_6_Vector2;
        Unity_Combine_float(MultiplyBoundMinB, _OneMinus_42761850f55345a2817d77c53379b8e3_Out_1_Float, 0, 0, _Combine_3239577421b246bbaaa02adf4ba9b356_RGBA_4_Vector4, _Combine_3239577421b246bbaaa02adf4ba9b356_RGB_5_Vector3, _Combine_3239577421b246bbaaa02adf4ba9b356_RG_6_Vector2);
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_287579fcd49d4a6bb2ef93878e6bb97a_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_287579fcd49d4a6bb2ef93878e6bb97a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(posTexture.tex, posTexture.samplerstate, posTexture.GetTransformedUV(_Combine_3239577421b246bbaaa02adf4ba9b356_RG_6_Vector2), 0);
        #endif
        float _SampleTexture2DLOD_287579fcd49d4a6bb2ef93878e6bb97a_R_5_Float = _SampleTexture2DLOD_287579fcd49d4a6bb2ef93878e6bb97a_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_287579fcd49d4a6bb2ef93878e6bb97a_G_6_Float = _SampleTexture2DLOD_287579fcd49d4a6bb2ef93878e6bb97a_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_287579fcd49d4a6bb2ef93878e6bb97a_B_7_Float = _SampleTexture2DLOD_287579fcd49d4a6bb2ef93878e6bb97a_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_287579fcd49d4a6bb2ef93878e6bb97a_A_8_Float = _SampleTexture2DLOD_287579fcd49d4a6bb2ef93878e6bb97a_RGBA_0_Vector4.a;
        float4 _Combine_9c39a564551e4a1dab2cc722d58cfed9_RGBA_4_Vector4;
        float3 _Combine_9c39a564551e4a1dab2cc722d58cfed9_RGB_5_Vector3;
        float2 _Combine_9c39a564551e4a1dab2cc722d58cfed9_RG_6_Vector2;
        Unity_Combine_float(_SampleTexture2DLOD_287579fcd49d4a6bb2ef93878e6bb97a_R_5_Float, _SampleTexture2DLOD_287579fcd49d4a6bb2ef93878e6bb97a_G_6_Float, _SampleTexture2DLOD_287579fcd49d4a6bb2ef93878e6bb97a_B_7_Float, 0, _Combine_9c39a564551e4a1dab2cc722d58cfed9_RGBA_4_Vector4, _Combine_9c39a564551e4a1dab2cc722d58cfed9_RGB_5_Vector3, _Combine_9c39a564551e4a1dab2cc722d58cfed9_RG_6_Vector2);
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_360702360c8c40eeb628fd723c0d1f36_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_360702360c8c40eeb628fd723c0d1f36_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_88cc07c51d1d4c2ea2801e86f6a9f044_Out_0_Texture2D.tex, _Property_88cc07c51d1d4c2ea2801e86f6a9f044_Out_0_Texture2D.samplerstate, _Property_88cc07c51d1d4c2ea2801e86f6a9f044_Out_0_Texture2D.GetTransformedUV(_Combine_3239577421b246bbaaa02adf4ba9b356_RG_6_Vector2), 0);
        #endif
        float _SampleTexture2DLOD_360702360c8c40eeb628fd723c0d1f36_R_5_Float = _SampleTexture2DLOD_360702360c8c40eeb628fd723c0d1f36_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_360702360c8c40eeb628fd723c0d1f36_G_6_Float = _SampleTexture2DLOD_360702360c8c40eeb628fd723c0d1f36_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_360702360c8c40eeb628fd723c0d1f36_B_7_Float = _SampleTexture2DLOD_360702360c8c40eeb628fd723c0d1f36_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_360702360c8c40eeb628fd723c0d1f36_A_8_Float = _SampleTexture2DLOD_360702360c8c40eeb628fd723c0d1f36_RGBA_0_Vector4.a;
        float4 _Combine_7084182552c241bdb6d0512cb1155a3f_RGBA_4_Vector4;
        float3 _Combine_7084182552c241bdb6d0512cb1155a3f_RGB_5_Vector3;
        float2 _Combine_7084182552c241bdb6d0512cb1155a3f_RG_6_Vector2;
        Unity_Combine_float(_SampleTexture2DLOD_360702360c8c40eeb628fd723c0d1f36_R_5_Float, _SampleTexture2DLOD_360702360c8c40eeb628fd723c0d1f36_G_6_Float, _SampleTexture2DLOD_360702360c8c40eeb628fd723c0d1f36_B_7_Float, 0, _Combine_7084182552c241bdb6d0512cb1155a3f_RGBA_4_Vector4, _Combine_7084182552c241bdb6d0512cb1155a3f_RGB_5_Vector3, _Combine_7084182552c241bdb6d0512cb1155a3f_RG_6_Vector2);
        float3 _Multiply_7a5859a14b5d45cfbf932206d683f2d0_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Combine_7084182552c241bdb6d0512cb1155a3f_RGB_5_Vector3, float3(0.01, 0.01, 0.01), _Multiply_7a5859a14b5d45cfbf932206d683f2d0_Out_2_Vector3);
        float3 _Add_097f634a10154558b7d3955ab7a9b3c2_Out_2_Vector3;
        Unity_Add_float3(_Combine_9c39a564551e4a1dab2cc722d58cfed9_RGB_5_Vector3, _Multiply_7a5859a14b5d45cfbf932206d683f2d0_Out_2_Vector3, _Add_097f634a10154558b7d3955ab7a9b3c2_Out_2_Vector3);
        #if defined(_B_LOAD_POS_TWO_TEX)
        float3 _PositionsRequireTwoTextures_398d49e0a9e745c3be0cb6dd43f9bdb2_Out_0_Vector3 = _Add_097f634a10154558b7d3955ab7a9b3c2_Out_2_Vector3;
        #else
        float3 _PositionsRequireTwoTextures_398d49e0a9e745c3be0cb6dd43f9bdb2_Out_0_Vector3 = _Combine_9c39a564551e4a1dab2cc722d58cfed9_RGB_5_Vector3;
        #endif
        float3 _Multiply_9a42a47779a74789b63390a9d333158b_Out_2_Vector3;
        Unity_Multiply_float3_float3(_PositionsRequireTwoTextures_398d49e0a9e745c3be0cb6dd43f9bdb2_Out_0_Vector3, _Subtract_83069528d6794190a7bbec7f91d26eb4_Out_2_Vector3, _Multiply_9a42a47779a74789b63390a9d333158b_Out_2_Vector3);
        float3 _Add_9c03ef247e144a429e1065251468edf1_Out_2_Vector3;
        Unity_Add_float3(_Multiply_9a42a47779a74789b63390a9d333158b_Out_2_Vector3, boundMinCombine_RGB, _Add_9c03ef247e144a429e1065251468edf1_Out_2_Vector3);
        float3 _Branch_214a74645ca6492b89141f31e6ea5a7f_Out_3_Vector3;
        Unity_Branch_float3(ComparisonBoundMaxb, _PositionsRequireTwoTextures_398d49e0a9e745c3be0cb6dd43f9bdb2_Out_0_Vector3, _Add_9c03ef247e144a429e1065251468edf1_Out_2_Vector3, _Branch_214a74645ca6492b89141f31e6ea5a7f_Out_3_Vector3);
        float3 _Subtract_030df86ef0634ac481fba96527ff242c_Out_2_Vector3;
        Unity_Subtract_float3(_Branch_6abcc2317e104339a2decf93e9aee587_Out_3_Vector3, _Branch_214a74645ca6492b89141f31e6ea5a7f_Out_3_Vector3, _Subtract_030df86ef0634ac481fba96527ff242c_Out_2_Vector3);
        float3 _Multiply_544b3b7d0858480cad712d97b73febff_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Subtract_030df86ef0634ac481fba96527ff242c_Out_2_Vector3, float3(0.5, 0.5, 0.5), _Multiply_544b3b7d0858480cad712d97b73febff_Out_2_Vector3);
        float3 _Multiply_e51eff6f24a64bf2aef49ed99220a97c_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Multiply_544b3b7d0858480cad712d97b73febff_Out_2_Vector3, (fps.xxx), _Multiply_e51eff6f24a64bf2aef49ed99220a97c_Out_2_Vector3);
        float _Split_720aa7f35a6b490aaf7a2154ebc4da24_R_1_Float = _LoadColorTexture_f0d31671e10846148e10ff6f6ddcce87_Out_0_Vector4[0];
        float _Split_720aa7f35a6b490aaf7a2154ebc4da24_G_2_Float = _LoadColorTexture_f0d31671e10846148e10ff6f6ddcce87_Out_0_Vector4[1];
        float _Split_720aa7f35a6b490aaf7a2154ebc4da24_B_3_Float = _LoadColorTexture_f0d31671e10846148e10ff6f6ddcce87_Out_0_Vector4[2];
        float _Split_720aa7f35a6b490aaf7a2154ebc4da24_A_4_Float = _LoadColorTexture_f0d31671e10846148e10ff6f6ddcce87_Out_0_Vector4[3];
        float _Multiply_d460d4376ec443478b75affab2a6484f_Out_2_Float;
        Unity_Multiply_float_float(_Split_720aa7f35a6b490aaf7a2154ebc4da24_R_1_Float, -1, _Multiply_d460d4376ec443478b75affab2a6484f_Out_2_Float);
        float4 _Combine_0030b1857d35451ab7953bc224675699_RGBA_4_Vector4;
        float3 _Combine_0030b1857d35451ab7953bc224675699_RGB_5_Vector3;
        float2 _Combine_0030b1857d35451ab7953bc224675699_RG_6_Vector2;
        Unity_Combine_float(_Multiply_d460d4376ec443478b75affab2a6484f_Out_2_Float, _Split_720aa7f35a6b490aaf7a2154ebc4da24_G_2_Float, _Split_720aa7f35a6b490aaf7a2154ebc4da24_B_3_Float, 0, _Combine_0030b1857d35451ab7953bc224675699_RGBA_4_Vector4, _Combine_0030b1857d35451ab7953bc224675699_RGB_5_Vector3, _Combine_0030b1857d35451ab7953bc224675699_RG_6_Vector2);
        #if defined(_B_SMOOTH_TRAJECTORIES)
        float3 _SmoothlyInterpolatedTrajectories_8c042b0f8b114723960f856f38e1f8c0_Out_0_Vector3 = _Combine_0030b1857d35451ab7953bc224675699_RGB_5_Vector3;
        #else
        float3 _SmoothlyInterpolatedTrajectories_8c042b0f8b114723960f856f38e1f8c0_Out_0_Vector3 = _Vector3_15aecf0488824eeea4967cba0231c95e_Out_0_Vector3;
        #endif
        float4 _Combine_d49aa133f0fe4d09ae08fdeb68792238_RGBA_4_Vector4;
        float3 _Combine_d49aa133f0fe4d09ae08fdeb68792238_RGB_5_Vector3;
        float2 _Combine_d49aa133f0fe4d09ae08fdeb68792238_RG_6_Vector2;
        Unity_Combine_float(posR, posG, posB, 0, _Combine_d49aa133f0fe4d09ae08fdeb68792238_RGBA_4_Vector4, _Combine_d49aa133f0fe4d09ae08fdeb68792238_RGB_5_Vector3, _Combine_d49aa133f0fe4d09ae08fdeb68792238_RG_6_Vector2);
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_855392d9245a455d941374694e57f0c7_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_855392d9245a455d941374694e57f0c7_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_88cc07c51d1d4c2ea2801e86f6a9f044_Out_0_Texture2D.tex, _Property_88cc07c51d1d4c2ea2801e86f6a9f044_Out_0_Texture2D.samplerstate, _Property_88cc07c51d1d4c2ea2801e86f6a9f044_Out_0_Texture2D.GetTransformedUV(texcoordUV), 0);
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
        Unity_Add_float3(_Multiply_8e5558b18d83439a9981812720701597_Out_2_Vector3, boundMinCombine_RGB, _Add_80715fe518cd4ad1a9a73a23b690774d_Out_2_Vector3);
        float3 _Branch_4f4f2009002c4eafa0b38571d20172b2_Out_3_Vector3;
        Unity_Branch_float3(ComparisonBoundMaxb, _PositionsRequireTwoTextures_c8e450f1058a4432b4c548b5e53b7946_Out_0_Vector3, _Add_80715fe518cd4ad1a9a73a23b690774d_Out_2_Vector3, _Branch_4f4f2009002c4eafa0b38571d20172b2_Out_3_Vector3);
        float _Divide_03c6ba4deacf4ae583578eda86eb0d6c_Out_2_Float;
        Unity_Divide_float(activeFrameFrac, fps, _Divide_03c6ba4deacf4ae583578eda86eb0d6c_Out_2_Float);
        float3 _InterframePositionCustomFunction_f2c5f95f36674ad4820e14112ab81b58_OutInterframeP_4_Vector3;
        Interframe_Position_float(_Multiply_e51eff6f24a64bf2aef49ed99220a97c_Out_2_Vector3, _SmoothlyInterpolatedTrajectories_8c042b0f8b114723960f856f38e1f8c0_Out_0_Vector3, _Branch_4f4f2009002c4eafa0b38571d20172b2_Out_3_Vector3, _Divide_03c6ba4deacf4ae583578eda86eb0d6c_Out_2_Float, _InterframePositionCustomFunction_f2c5f95f36674ad4820e14112ab81b58_OutInterframeP_4_Vector3);
        float3 _Lerp_575c9c879bd54a02896fea66ac682590_Out_3_Vector3;
        Unity_Lerp_float3(_Branch_4f4f2009002c4eafa0b38571d20172b2_Out_3_Vector3, _Branch_6abcc2317e104339a2decf93e9aee587_Out_3_Vector3, (activeFrameFrac.xxx), _Lerp_575c9c879bd54a02896fea66ac682590_Out_3_Vector3);
        float3 _Branch_61123dba8a02420981f4eddc0122eadc_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_a8c089c976024f2ebd3b2c6e3f328243_Out_2_Boolean, _InterframePositionCustomFunction_f2c5f95f36674ad4820e14112ab81b58_OutInterframeP_4_Vector3, _Lerp_575c9c879bd54a02896fea66ac682590_Out_3_Vector3, _Branch_61123dba8a02420981f4eddc0122eadc_Out_3_Vector3);
        #if defined(_B_SMOOTH_TRAJECTORIES)
        float3 _SmoothlyInterpolatedTrajectories_b2ed49e7c6884dcb836a6829cb6a74a8_Out_0_Vector3 = _Branch_61123dba8a02420981f4eddc0122eadc_Out_3_Vector3;
        #else
        float3 _SmoothlyInterpolatedTrajectories_b2ed49e7c6884dcb836a6829cb6a74a8_Out_0_Vector3 = _Lerp_575c9c879bd54a02896fea66ac682590_Out_3_Vector3;
        #endif
        float3 _Branch_a95062aee478445eb238301f4077b46b_Out_3_Vector3;
        Unity_Branch_float3(_Property_1238b8669b754229a924fa19745c9a3a_Out_0_Boolean, _SmoothlyInterpolatedTrajectories_b2ed49e7c6884dcb836a6829cb6a74a8_Out_0_Vector3, _Branch_4f4f2009002c4eafa0b38571d20172b2_Out_3_Vector3, _Branch_a95062aee478445eb238301f4077b46b_Out_3_Vector3);
        float3 _Add_4a9418dc3a174f3882e94203ce727c53_Out_2_Vector3;
        Unity_Add_float3(_Multiply_ae9a523d22654befb80a94a4d9838cfe_Out_2_Vector3, _Branch_a95062aee478445eb238301f4077b46b_Out_3_Vector3, _Add_4a9418dc3a174f3882e94203ce727c53_Out_2_Vector3);
        float _Modulo_06e767356ff446e988538299493c5368_Out_2_Float;
        Unity_Modulo_float(selectedFrame, totalFrames, _Modulo_06e767356ff446e988538299493c5368_Out_2_Float);
        float _Comparison_c9e7d128e0ea4aa59ccdf144224f8e95_Out_2_Boolean;
        Unity_Comparison_NotEqual_float(_Modulo_06e767356ff446e988538299493c5368_Out_2_Float, 1, _Comparison_c9e7d128e0ea4aa59ccdf144224f8e95_Out_2_Boolean);
        float3 _Branch_1ac08f9a9c2f42628f75369930c90d03_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_c9e7d128e0ea4aa59ccdf144224f8e95_Out_2_Boolean, _Add_4a9418dc3a174f3882e94203ce727c53_Out_2_Vector3, IN.ObjectSpacePosition, _Branch_1ac08f9a9c2f42628f75369930c90d03_Out_3_Vector3);
        float3 _Branch_51ea135983084664b04a144b570d0456_Out_3_Vector3;
        Unity_Branch_float3(_Animate_First_Frame, _Add_4a9418dc3a174f3882e94203ce727c53_Out_2_Vector3, _Branch_1ac08f9a9c2f42628f75369930c90d03_Out_3_Vector3, _Branch_51ea135983084664b04a144b570d0456_Out_3_Vector3);
        float3 _Property_8b9e36bcab644a8a8de5aa7a5f8c87cc_Out_0_Vector3 = zreo;
        float3 _Add_cfc4c853d1734b97a576111ad82a4646_Out_2_Vector3;
        Unity_Add_float3(_Branch_51ea135983084664b04a144b570d0456_Out_3_Vector3, _Property_8b9e36bcab644a8a8de5aa7a5f8c87cc_Out_0_Vector3, _Add_cfc4c853d1734b97a576111ad82a4646_Out_2_Vector3);
        float3 _Branch_ba93d84f34e744b6a0798505c9ceae34_Out_3_Vector3;
        Unity_Branch_float3(_Comparison_LessOrEqual_B, float3(0, 0, 0), _Add_cfc4c853d1734b97a576111ad82a4646_Out_2_Vector3, _Branch_ba93d84f34e744b6a0798505c9ceae34_Out_3_Vector3);
        float3 _Multiply_5081d7eb1fdb4fc093265e623fbf81be_Out_2_Vector3;
        Unity_Multiply_float3_float3((_Split_70d7fe38e42f4a49b6a12b4a28073bfb_A_4_Float.xxx), IN.ObjectSpaceNormal, _Multiply_5081d7eb1fdb4fc093265e623fbf81be_Out_2_Vector3);
        float3 _CrossProduct_09f100e05a724ab799c461db618ee59c_Out_2_Vector3;
        Unity_CrossProduct_float(_Combine_c62cf49352cf4def93cd35bff786a4f8_RGB_5_Vector3, IN.ObjectSpaceNormal, _CrossProduct_09f100e05a724ab799c461db618ee59c_Out_2_Vector3);
        float3 _Add_7ffc599647db4fcbbd0be8e1c9c5199e_Out_2_Vector3;
        Unity_Add_float3(_Multiply_5081d7eb1fdb4fc093265e623fbf81be_Out_2_Vector3, _CrossProduct_09f100e05a724ab799c461db618ee59c_Out_2_Vector3, _Add_7ffc599647db4fcbbd0be8e1c9c5199e_Out_2_Vector3);
        float3 _CrossProduct_db59763f2af2444faaf6a0df5cab782a_Out_2_Vector3;
        Unity_CrossProduct_float(_Combine_c62cf49352cf4def93cd35bff786a4f8_RGB_5_Vector3, _Add_7ffc599647db4fcbbd0be8e1c9c5199e_Out_2_Vector3, _CrossProduct_db59763f2af2444faaf6a0df5cab782a_Out_2_Vector3);
        float3 _Multiply_82421ac159f64abd8757d369cef3ca2b_Out_2_Vector3;
        Unity_Multiply_float3_float3(_CrossProduct_db59763f2af2444faaf6a0df5cab782a_Out_2_Vector3, float3(2, 2, 2), _Multiply_82421ac159f64abd8757d369cef3ca2b_Out_2_Vector3);
        float3 _Add_4055c3505ca44c9cb83eed649da64efc_Out_2_Vector3;
        Unity_Add_float3(_Multiply_82421ac159f64abd8757d369cef3ca2b_Out_2_Vector3, IN.ObjectSpaceNormal, _Add_4055c3505ca44c9cb83eed649da64efc_Out_2_Vector3);
        float3 _Normalize_6ff0bb5959824712b3c1a9d455332917_Out_1_Vector3;
        Unity_Normalize_float3(_Add_4055c3505ca44c9cb83eed649da64efc_Out_2_Vector3, _Normalize_6ff0bb5959824712b3c1a9d455332917_Out_1_Vector3);
        float _Property_e82ce2070ecc4580b8cc7e2957a8b387_Out_0_Boolean = b_surfaceNormals;
        float3 _Multiply_2683d56e97a94688a0cd18f0f377c461_Out_2_Vector3;
        Unity_Multiply_float3_float3((_Split_70d7fe38e42f4a49b6a12b4a28073bfb_A_4_Float.xxx), IN.ObjectSpaceTangent, _Multiply_2683d56e97a94688a0cd18f0f377c461_Out_2_Vector3);
        float3 _CrossProduct_fe4b33b782c94a958908c6d0fda7f1f2_Out_2_Vector3;
        Unity_CrossProduct_float(_Combine_c62cf49352cf4def93cd35bff786a4f8_RGB_5_Vector3, IN.ObjectSpaceTangent, _CrossProduct_fe4b33b782c94a958908c6d0fda7f1f2_Out_2_Vector3);
        float3 _Add_d4d4404f29b5478da05d90333fa2646e_Out_2_Vector3;
        Unity_Add_float3(_Multiply_2683d56e97a94688a0cd18f0f377c461_Out_2_Vector3, _CrossProduct_fe4b33b782c94a958908c6d0fda7f1f2_Out_2_Vector3, _Add_d4d4404f29b5478da05d90333fa2646e_Out_2_Vector3);
        float3 _CrossProduct_9e211350ebb44f2b9f167a39dbe5d0c1_Out_2_Vector3;
        Unity_CrossProduct_float(_Combine_c62cf49352cf4def93cd35bff786a4f8_RGB_5_Vector3, _Add_d4d4404f29b5478da05d90333fa2646e_Out_2_Vector3, _CrossProduct_9e211350ebb44f2b9f167a39dbe5d0c1_Out_2_Vector3);
        float3 _Multiply_f8c674663fcb47739695e51f81080da2_Out_2_Vector3;
        Unity_Multiply_float3_float3(_CrossProduct_9e211350ebb44f2b9f167a39dbe5d0c1_Out_2_Vector3, float3(2, 2, 2), _Multiply_f8c674663fcb47739695e51f81080da2_Out_2_Vector3);
        float3 _Add_53834285195c4c39aa433be810aa07ea_Out_2_Vector3;
        Unity_Add_float3(_Multiply_f8c674663fcb47739695e51f81080da2_Out_2_Vector3, IN.ObjectSpaceTangent, _Add_53834285195c4c39aa433be810aa07ea_Out_2_Vector3);
        float3 _Normalize_182c6b7faf5a4d4e9d83e30a084d9c3f_Out_1_Vector3;
        Unity_Normalize_float3(_Add_53834285195c4c39aa433be810aa07ea_Out_2_Vector3, _Normalize_182c6b7faf5a4d4e9d83e30a084d9c3f_Out_1_Vector3);
        float3 _Vector3_334362fd0ae04d9c8d077e7724248b0f_Out_0_Vector3 = float3(0, 0, 0);
        float3 _Branch_937bb7ab707947f3939fbece2363d768_Out_3_Vector3;
        Unity_Branch_float3(_Property_e82ce2070ecc4580b8cc7e2957a8b387_Out_0_Boolean, _Normalize_182c6b7faf5a4d4e9d83e30a084d9c3f_Out_1_Vector3, _Vector3_334362fd0ae04d9c8d077e7724248b0f_Out_0_Vector3, _Branch_937bb7ab707947f3939fbece2363d768_Out_3_Vector3);
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
        UnityTexture2D _Property_fdb0c4a7b4304cf7aa5f4f3b27b8156e_Out_0_Texture2D = spareColTexture;
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_91d8eb10f6014791b31ca62331d89a27_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_91d8eb10f6014791b31ca62331d89a27_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_fdb0c4a7b4304cf7aa5f4f3b27b8156e_Out_0_Texture2D.tex, _Property_fdb0c4a7b4304cf7aa5f4f3b27b8156e_Out_0_Texture2D.samplerstate, _Property_fdb0c4a7b4304cf7aa5f4f3b27b8156e_Out_0_Texture2D.GetTransformedUV(texcoordUV), 0);
        #endif
        float _SampleTexture2DLOD_91d8eb10f6014791b31ca62331d89a27_R_5_Float = _SampleTexture2DLOD_91d8eb10f6014791b31ca62331d89a27_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_91d8eb10f6014791b31ca62331d89a27_G_6_Float = _SampleTexture2DLOD_91d8eb10f6014791b31ca62331d89a27_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_91d8eb10f6014791b31ca62331d89a27_B_7_Float = _SampleTexture2DLOD_91d8eb10f6014791b31ca62331d89a27_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_91d8eb10f6014791b31ca62331d89a27_A_8_Float = _SampleTexture2DLOD_91d8eb10f6014791b31ca62331d89a27_RGBA_0_Vector4.a;
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_25f85af0492d4a22a920ab930ef4024f_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_25f85af0492d4a22a920ab930ef4024f_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_fdb0c4a7b4304cf7aa5f4f3b27b8156e_Out_0_Texture2D.tex, _Property_fdb0c4a7b4304cf7aa5f4f3b27b8156e_Out_0_Texture2D.samplerstate, _Property_fdb0c4a7b4304cf7aa5f4f3b27b8156e_Out_0_Texture2D.GetTransformedUV(texcoordNextFrame), 0);
        #endif
        float _SampleTexture2DLOD_25f85af0492d4a22a920ab930ef4024f_R_5_Float = _SampleTexture2DLOD_25f85af0492d4a22a920ab930ef4024f_RGBA_0_Vector4.r;
        float _SampleTexture2DLOD_25f85af0492d4a22a920ab930ef4024f_G_6_Float = _SampleTexture2DLOD_25f85af0492d4a22a920ab930ef4024f_RGBA_0_Vector4.g;
        float _SampleTexture2DLOD_25f85af0492d4a22a920ab930ef4024f_B_7_Float = _SampleTexture2DLOD_25f85af0492d4a22a920ab930ef4024f_RGBA_0_Vector4.b;
        float _SampleTexture2DLOD_25f85af0492d4a22a920ab930ef4024f_A_8_Float = _SampleTexture2DLOD_25f85af0492d4a22a920ab930ef4024f_RGBA_0_Vector4.a;
        float4 _Lerp_5b84de47bc154d2eab428508120ea672_Out_3_Vector4;
        Unity_Lerp_float4(_SampleTexture2DLOD_91d8eb10f6014791b31ca62331d89a27_RGBA_0_Vector4, _SampleTexture2DLOD_25f85af0492d4a22a920ab930ef4024f_RGBA_0_Vector4, (activeFrameFrac.xxxx), _Lerp_5b84de47bc154d2eab428508120ea672_Out_3_Vector4);
        float4 _Branch_a6360ef37f69476dad27377056af6ce2_Out_3_Vector4;
        Unity_Branch_float4(_And_01fa23b3b0054ee285a642ea984c79bd_Out_2_Boolean, _Lerp_5b84de47bc154d2eab428508120ea672_Out_3_Vector4, _SampleTexture2DLOD_91d8eb10f6014791b31ca62331d89a27_RGBA_0_Vector4, _Branch_a6360ef37f69476dad27377056af6ce2_Out_3_Vector4);
        float _Multiply_da3254ad20e34a8b9507097f01d91a2c_Out_2_Float;
        Unity_Multiply_float_float(_Divide_569c994b2ab34847bd4a297c59a7ca80_Out_2_Float, _OneMinus_9b87aca1ae574fd289bcfc7b1beb7820_Out_1_Float, _Multiply_da3254ad20e34a8b9507097f01d91a2c_Out_2_Float);
        float _Multiply_951a39edc04e42edb94eec3de2616641_Out_2_Float;
        Unity_Multiply_float_float(_Divide_569c994b2ab34847bd4a297c59a7ca80_Out_2_Float, _OneMinus_fe03f4b292834b7991037367f130cefa_Out_1_Float, _Multiply_951a39edc04e42edb94eec3de2616641_Out_2_Float);
        Out_Position_1 = _Branch_ba93d84f34e744b6a0798505c9ceae34_Out_3_Vector3;
        Out_Normal_2 = _Normalize_6ff0bb5959824712b3c1a9d455332917_Out_1_Vector3;
        Out_Tangent_3 = _Branch_937bb7ab707947f3939fbece2363d768_Out_3_Vector3;
        Out_ColorRGB_4 = _Combine_4377c6dcc5d345eca19f49e271a380a1_RGB_5_Vector3;
        Out_ColorAlpha_6 = _Split_c5593124f90046678b7f159106c72a73_A_4_Float;
        Out_SpareColorRGBA_5 = _Branch_a6360ef37f69476dad27377056af6ce2_Out_3_Vector4;
        Out_SamplingVThisFrame_8 = vCoordBase;
        Out_SamplingVNextFrame_9 = vCoordNext;
        Out_PieceLocalPositionThisFrame_10 = _Branch_4f4f2009002c4eafa0b38571d20172b2_Out_3_Vector3;
        Out_PieceLocalPositionNextFrame_11 = _Branch_6abcc2317e104339a2decf93e9aee587_Out_3_Vector3;
        Out_DataInPositionAlphaThisFrame_12 = _Multiply_da3254ad20e34a8b9507097f01d91a2c_Out_2_Float;
        Out_DataInPositionAlphaNextFrame_13 = _Multiply_951a39edc04e42edb94eec3de2616641_Out_2_Float;
        Out_ColorRGBAThisFrame_17 = _LoadColorTexture_f0d31671e10846148e10ff6f6ddcce87_Out_0_Vector4;
        Out_ColorRGBANextFrame_14 = _LoadColorTexture_cc743dddac284c769882b4847ff7576b_Out_0_Vector4;
        Out_SpareColorRGBAThisFrame_18 = _SampleTexture2DLOD_91d8eb10f6014791b31ca62331d89a27_RGBA_0_Vector4;
        Out_SpareColorRGBANextFrame_15 = _SampleTexture2DLOD_25f85af0492d4a22a920ab930ef4024f_RGBA_0_Vector4;
        Out_InterframeInterpolationAlpha_16 = activeFrameFrac;
        Out_AnimationProgressThisFrame_21 = frameNormalized;
        Out_AnimationProgressNextFrame_22 = nextFrameNorm;
        Out_PieceRestFrameLocalPosition_19 = _Combine_c5b8f60c79034bba86a0dcdd200aaf52_RGB_5_Vector3;
        Out_PieceLocalPositionFinal_20 = _Branch_a95062aee478445eb238301f4077b46b_Out_3_Vector3;
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
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _b_autoPlayback = _B_autoPlayback;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _GameTimeAtFirstFrame = _gameTimeAtFirstFrame;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _DisplayFrame = _displayFrame;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _PlaybackSpeed = _playbackSpeed;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _HoudiniFPS = _houdiniFPS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _b_interpolate = _B_interpolate;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _b_interpolateCol = _B_interpolateCol;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _b_interpolateSpareCol = _B_interpolateSpareCol;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _b_surfaceNormals = _B_surfaceNormals;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            UnityTexture2D _PosTexture = UnityBuildTexture2DStructNoScale(_posTexture);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            UnityTexture2D _PosTexture2 = UnityBuildTexture2DStructNoScale(_posTexture2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            UnityTexture2D _RotTexture = UnityBuildTexture2DStructNoScale(_rotTexture);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            UnityTexture2D _ColTexture = UnityBuildTexture2DStructNoScale(_colTexture);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            UnityTexture2D _SpareColTexture = UnityBuildTexture2DStructNoScale(_spareColTexture);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _b_pscaleAreInPosA = _B_pscaleAreInPosA;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _GlobalPscaleMul = _globalPscaleMul;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _b_stretchByVel = _B_stretchByVel;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _StretchByVelAmount = _stretchByVelAmount;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _b_animateFirstFrame = _B_animateFirstFrame;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _FrameCount = _frameCount;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _BoundMaxX = _boundMaxX;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _BoundMaxY = _boundMaxY;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _BoundMaxZ = _boundMaxZ;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _BoundMinX = _boundMinX;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _BoundMinY = _boundMinY;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            float _BoundMinZ = _boundMinZ;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
            Bindings_vatRigidBodyDynamics _vatRigidBodySSG;
            _vatRigidBodySSG.ObjectSpaceNormal = IN.ObjectSpaceNormal;
            _vatRigidBodySSG.ObjectSpaceTangent = IN.ObjectSpaceTangent;
            _vatRigidBodySSG.ObjectSpacePosition = IN.ObjectSpacePosition;
            _vatRigidBodySSG.uv1 = IN.uv1;
            _vatRigidBodySSG.uv2 = IN.uv2;
            _vatRigidBodySSG.uv3 = IN.uv3;
            float3 _vatRigidBodySSG_OutPosition_1_Vector3;
            float3 _vatRigidBodySSG_OutNormal_2_Vector3;
            float3 _vatRigidBodySSG_OutTangent_3_Vector3;
            float3 _vatRigidBodySSG_OutColorRGB_4_Vector3;
            float _vatRigidBodySSG_OutColorAlpha_6_Float;
            float4 _vatRigidBodySSG_OutSpareColorRGBA_5_Vector4;
            float _vatRigidBodySSG_OutSamplingVThisFrame_8_Float;
            float _vatRigidBodySSG_OutSamplingVNextFrame_9_Float;
            float3 _vatRigidBodySSG_OutPieceLocalPositionThisFrame_10_Vector3;
            float3 _vatRigidBodySSG_OutPieceLocalPositionNextFrame_11_Vector3;
            float _vatRigidBodySSG_OutDataInPositionAlphaThisFrame_12_Float;
            float _vatRigidBodySSG_OutDataInPositionAlphaNextFrame_13_Float;
            float4 _vatRigidBodySSG_OutColorRGBAThisFrame_17_Vector4;
            float4 _vatRigidBodySSG_OutColorRGBANextFrame_14_Vector4;
            float4 _vatRigidBodySSG_OutSpareColorRGBAThisFrame_18_Vector4;
            float4 _vatRigidBodySSG_OutSpareColorRGBANextFrame_15_Vector4;
            float _vatRigidBodySSG_OutInterframeInterpolationAlpha_16_Float;
            float _vatRigidBodySSG_OutAnimationProgressThisFrame_21_Float;
            float _vatRigidBodySSG_OutAnimationProgressNextFrame_22_Float;
            float3 _vatRigidBodySSG_OutPieceRestFrameLocalPosition_19_Vector3;
            float3 _vatRigidBodySSG_OutPieceLocalPositionFinal_20_Vector3;
            SG_vatRigidBodyDynamicsSSG(_b_autoPlayback, _GameTimeAtFirstFrame, _DisplayFrame, _PlaybackSpeed, _HoudiniFPS, _b_interpolate, _b_interpolateCol, _b_interpolateSpareCol,
                _b_surfaceNormals, _PosTexture, _PosTexture2, _RotTexture, _ColTexture, _SpareColTexture, _b_pscaleAreInPosA, _GlobalPscaleMul, _b_stretchByVel, _StretchByVelAmount,
                _b_animateFirstFrame, _FrameCount, _BoundMaxX, _BoundMaxY, _BoundMaxZ, _BoundMinX, _BoundMinY, _BoundMinZ, IN.TimeParameters.x, float3 (0, 0, 0), _vatRigidBodySSG, _vatRigidBodySSG_OutPosition_1_Vector3, _vatRigidBodySSG_OutNormal_2_Vector3, _vatRigidBodySSG_OutTangent_3_Vector3, _vatRigidBodySSG_OutColorRGB_4_Vector3, _vatRigidBodySSG_OutColorAlpha_6_Float, _vatRigidBodySSG_OutSpareColorRGBA_5_Vector4, _vatRigidBodySSG_OutSamplingVThisFrame_8_Float, _vatRigidBodySSG_OutSamplingVNextFrame_9_Float, _vatRigidBodySSG_OutPieceLocalPositionThisFrame_10_Vector3, _vatRigidBodySSG_OutPieceLocalPositionNextFrame_11_Vector3, _vatRigidBodySSG_OutDataInPositionAlphaThisFrame_12_Float, _vatRigidBodySSG_OutDataInPositionAlphaNextFrame_13_Float, _vatRigidBodySSG_OutColorRGBAThisFrame_17_Vector4, _vatRigidBodySSG_OutColorRGBANextFrame_14_Vector4, _vatRigidBodySSG_OutSpareColorRGBAThisFrame_18_Vector4, _vatRigidBodySSG_OutSpareColorRGBANextFrame_15_Vector4, _vatRigidBodySSG_OutInterframeInterpolationAlpha_16_Float, _vatRigidBodySSG_OutAnimationProgressThisFrame_21_Float, _vatRigidBodySSG_OutAnimationProgressNextFrame_22_Float, _vatRigidBodySSG_OutPieceRestFrameLocalPosition_19_Vector3, _vatRigidBodySSG_OutPieceLocalPositionFinal_20_Vector3);
            #endif
            description.Position = _vatRigidBodySSG_OutPosition_1_Vector3;
            description.Normal = _vatRigidBodySSG_OutNormal_2_Vector3;
            description.Tangent = _vatRigidBodySSG_OutTangent_3_Vector3;
            description.Color_ToFragment = (float4(_vatRigidBodySSG_OutColorRGB_4_Vector3, 1.0));
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        output.Color_ToFragment = input.Color_ToFragment;
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
            float4 _SampleTexture2D_72ab43ee7e5b4ff3acd5a9fb57f150dc_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_72ab43ee7e5b4ff3acd5a9fb57f150dc_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_72ab43ee7e5b4ff3acd5a9fb57f150dc_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_72ab43ee7e5b4ff3acd5a9fb57f150dc_Texture_1_Texture2D).GetTransformedUV(IN.uv0.xy) );
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
            float4 _LoadSurfaceNormalMap_fb4ebe14c0f84712932829ccbc964ceb_Out_0_Vector4 = float4(0, 0, 1, 0);
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
        output.uv1 =                                        input.uv1;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        output.uv2 =                                        input.uv2;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        output.uv3 =                                        input.uv3;
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
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7) || defined(KEYWORD_PERMUTATION_8) || defined(KEYWORD_PERMUTATION_9) || defined(KEYWORD_PERMUTATION_10) || defined(KEYWORD_PERMUTATION_11) || defined(KEYWORD_PERMUTATION_12) || defined(KEYWORD_PERMUTATION_13) || defined(KEYWORD_PERMUTATION_14) || defined(KEYWORD_PERMUTATION_15)
        output.uv0 = input.texCoord0;
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