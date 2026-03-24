// VAT_RigidBody_Unlit_VFX.shader
// URP Lit shader for Houdini VAT3 Rigid Body Dynamics, designed for VFX use.
// Lighting: Lambert diffuse + SH ambient. Emission supported.
//
// Algorithms verified against the compiled ShaderGraph output:
//   VAT_RigidBodyDynamics_Simple.shader (SideFXLabs 20.5 URP_VAT3)
//
// UV channel layout (Houdini Labs VAT3 SOP export):
//   uv1.r = piece U coordinate (piece column index in texture)
//   uv1.g = piece V weight (used in frame V calculation, encodes row position)
//   uv2.r = rest pivot X (stored negated: pivot.x = -uv2.r)
//   uv3.r = rest pivot Y
//   uv3.g = rest pivot Z (stored inverted: pivot.z = 1 - uv3.g)
//
// Texture layout (Houdini VAT ROP default):
//   posTexture : RGB = piece pivot world-pos normalized to [0,1]; A = encodes MaxComponent index + pscale
//   rotTexture : RGB = smallest-3 quaternion components; A = sign flag for smooth trajectories
//   colTexture : RGBA vertex color per-piece per-frame (optional)
//   posTexture2: RGB = acceleration * 0.01 (Smooth Trajectories mode only)
//
// Bounds metadata encoding (SideFX VAT3 convention):
//   BoundMaxZ decimal * 10 >= 0.5  =>  HDR mode (no [-1,1] remapping)
//   BoundMaxX decimal * (-10)      =>  frame row scale factor (OneMinusBoundMaxR)
//   BoundMinZ decimal              =>  piece U scale factor
//   BoundMaxY decimal              =>  pscale denominator

Shader "SideFX/VAT_RigidBody_Lit_VFX"
{
    Properties
    {
        // ── Houdini VAT ─ Playback ────────────────────────────────────────
        [Header(Houdini VAT Playback)]
        [Space(4)]
        [ToggleUI] _autoPlayback          ("Auto Playback",              Float) = 1
        _gameTimeAtFirstFrame             ("Game Time at First Frame",   Float) = 0
        _playbackSpeed                    ("Playback Speed",             Float) = 1
        _houdiniFPS                       ("Houdini FPS",                Float) = 24
        _displayFrame                     ("Display Frame (Auto=off)",   Float) = 0
        [ToggleUI] _animateFirstFrame     ("Animate First Frame",        Float) = 0

        // ── Houdini VAT ─ Data ────────────────────────────────────────────
        [Header(Houdini VAT Data)]
        [Space(4)]
        _frameCount   ("Frame Count",   Float) = 1
        _boundMinX    ("Bound Min X",   Float) = -1
        _boundMinY    ("Bound Min Y",   Float) = -1
        _boundMinZ    ("Bound Min Z",   Float) = -1
        _boundMaxX    ("Bound Max X",   Float) = 1
        _boundMaxY    ("Bound Max Y",   Float) = 1
        _boundMaxZ    ("Bound Max Z",   Float) = 1

        // ── Houdini VAT ─ Textures ────────────────────────────────────────
        [Header(Houdini VAT Textures)]
        [Space(4)]
        [NoScaleOffset] _posTexture  ("Position Texture",   2D) = "black" {}
        [NoScaleOffset] _rotTexture  ("Rotation Texture",   2D) = "black" {}

        [Toggle(_TWO_TEX_POS)] _B_LOAD_POS_TWO_TEX ("Positions Require Two Textures", Float) = 0
        [NoScaleOffset] _posTexture2 ("Position Texture 2 (for two-tex mode)", 2D) = "black" {}

        // ── Houdini VAT ─ Piece Scale ─────────────────────────────────────
        [Header(Houdini VAT Piece Scale)]
        [Space(4)]
        [ToggleUI] _pscaleAreInPosA ("Piece Scales in Position Alpha", Float) = 1
        _globalPscaleMul            ("Global Piece Scale Multiplier",  Float) = 1

        // ── Houdini VAT ─ Interpolation ───────────────────────────────────
        [Header(Houdini VAT Interpolation)]
        [Space(4)]
        [Toggle(_INTERPOLATE)] _B_interpolate ("Interframe Interpolation", Float) = 1

        // ── Houdini VAT ─ Color ───────────────────────────────────────────
        [Header(Houdini VAT Color)]
        [Space(4)]
        [Toggle(_LOAD_COL_TEX)] _B_LOAD_COL_TEX ("Load Color Texture",   Float) = 0
        [NoScaleOffset] _colTexture             ("Color Texture",          2D) = "white" {}
        [ToggleUI] _interpolateCol              ("Interpolate Color",      Float) = 0

        // ── Material ──────────────────────────────────────────────────────
        [Header(Material)]
        [Space(4)]
        [HDR] _BaseColor    ("Base Color (HDR tint)",  Color) = (1,1,1,1)
        [HDR] _EmissionColor("Emission Color",         Color) = (0,0,0,0)

        // ── Rendering ─────────────────────────────────────────────────────
        [Header(Rendering)]
        [Space(4)]
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend", Float) = 0
        [Enum(UnityEngine.Rendering.CullMode)]  _Cull     ("Cull Mode", Float) = 2
        [Toggle] _ZWrite ("ZWrite", Float) = 1

        [Toggle(_ALPHATEST)] _AlphaTest ("Alpha Test (Cutout)", Float) = 0
        _Cutoff ("Alpha Cutoff", Range(0,1)) = 0.333
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType"     = "Opaque"
            "Queue"          = "Geometry"
        }

        // ─────────────────────────────────────────────────────────────────
        // Forward pass
        // ─────────────────────────────────────────────────────────────────
        Pass
        {
            Name "UniversalForward"
            Tags { "LightMode" = "UniversalForward" }

            Blend  [_SrcBlend] [_DstBlend]
            Cull   [_Cull]
            ZWrite [_ZWrite]
            ZTest  LEqual

            HLSLPROGRAM
            #pragma target 4.5

            #pragma vertex   vert
            #pragma fragment frag

            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX

            #pragma shader_feature_local_vertex _TWO_TEX_POS
            #pragma shader_feature_local_vertex _INTERPOLATE
            #pragma shader_feature_local        _LOAD_COL_TEX
            #pragma shader_feature_local        _ALPHATEST

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            // ── Texture declarations ──────────────────────────────────────
            TEXTURE2D(_posTexture);   SAMPLER(sampler_posTexture);
            TEXTURE2D(_posTexture2);  SAMPLER(sampler_posTexture2);
            TEXTURE2D(_rotTexture);   SAMPLER(sampler_rotTexture);
            TEXTURE2D(_colTexture);   SAMPLER(sampler_colTexture);

            // ── Per-material constants (SRP Batcher) ──────────────────────
            CBUFFER_START(UnityPerMaterial)
                float  _autoPlayback;
                float  _gameTimeAtFirstFrame;
                float  _playbackSpeed;
                float  _houdiniFPS;
                float  _displayFrame;
                float  _animateFirstFrame;

                float  _frameCount;
                float  _boundMinX;
                float  _boundMinY;
                float  _boundMinZ;
                float  _boundMaxX;
                float  _boundMaxY;
                float  _boundMaxZ;

                float  _pscaleAreInPosA;
                float  _globalPscaleMul;
                float  _interpolateCol;

                float4 _BaseColor;
                float4 _EmissionColor;
                float  _Cutoff;
            CBUFFER_END

            // ── Vertex input / output ─────────────────────────────────────
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float4 tangentOS  : TANGENT;
                float4 uv1        : TEXCOORD1;   // piece UV
                float4 uv2        : TEXCOORD2;   // rest pivot X
                float4 uv3        : TEXCOORD3;   // rest pivot YZ
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS  : SV_POSITION;
                float3 normalWS    : TEXCOORD0;
                float4 vatColor    : TEXCOORD1;
                float  fogFactor   : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            // ── Quaternion helpers ────────────────────────────────────────

            // Reconstruct unit quaternion from its 3 smallest components.
            // maxComp (0-3) identifies which component was dropped.
            // Encoding from VAT_RigidBodyDynamics_SSG lines 8686+.
            float4 DecodeQuaternion(float3 xyz, float maxComp)
            {
                float w = sqrt(saturate(1.0 - dot(xyz, xyz)));
                // Default: case 0
                float4 q = float4(xyz.x, xyz.y, xyz.z, w);
                int mc = (int)maxComp;
                if      (mc == 1) q = float4(    w,  xyz.y,  xyz.z,  xyz.x);
                else if (mc == 2) q = float4(xyz.x,     -w,  xyz.z, -xyz.y);
                else if (mc == 3) q = float4(xyz.x,  xyz.y,     -w, -xyz.z);
                return q;
            }

            // Rotate vector v by unit quaternion q.
            // Formula: v' = v + 2 * cross(q.xyz, q.w*v + cross(q.xyz, v))
            float3 RotateByQuat(float3 v, float4 q)
            {
                float3 t = cross(q.xyz, v);
                float3 intermediate = t + v * q.w;
                return v + cross(q.xyz, intermediate) * 2.0;
            }

            // ── VAT decode ────────────────────────────────────────────────

            // Compute the sampling UV for a given frame index.
            // Returns float2(pieceU, frameV).
            float2 ComputeVatUV(float selectedFrame, float uv1r, float uv1g,
                                float OneMinusBoundMaxR, float MultiplyBoundMinB,
                                float totalFrames)
            {
                float wrappedFrame  = fmod(selectedFrame - 1.0, totalFrames);
                float frameNorm     = wrappedFrame / totalFrames;
                float frameOffset   = frameNorm * OneMinusBoundMaxR;
                float vCoordBase    = (1.0 - uv1g) * OneMinusBoundMaxR + frameOffset;
                float vCoordFinal   = 1.0 - vCoordBase;
                return float2(MultiplyBoundMinB, vCoordFinal);
            }

            // ── Vertex shader ─────────────────────────────────────────────
            Varyings vert(Attributes IN)
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                Varyings OUT = (Varyings)0;
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

                // --- Bounds metadata decode ---
                // HDR flag: fractional part of BoundMaxZ*10 >= 0.5
                float boundMaxMul10z    = _boundMaxZ * 10.0;
                float ComparisonBoundMaxb = (frac(boundMaxMul10z) >= 0.5) ? 1.0 : 0.0;

                // Frame row scale: derived from BoundMaxX * (-10) fractional part
                float boundMaxNegR      = _boundMaxX * (-10.0);
                float OneMinusBoundMaxR = 1.0 - frac(boundMaxNegR);

                // Piece U scale: derived from BoundMinZ * 10 ceil-subtract
                float boundMinMul10z        = _boundMinZ * 10.0;
                float SubtractCeilingBoundMinB = ceil(boundMinMul10z) - boundMinMul10z;
                float OneMinusBoundMinB     = 1.0 - SubtractCeilingBoundMinB;
                float MultiplyBoundMinB     = IN.uv1.r * OneMinusBoundMinB;

                // --- Frame selection ---
                float totalFrames   = _frameCount;
                float fps           = _houdiniFPS;
                float elapsedTime   = _Time.y - _gameTimeAtFirstFrame;

                float adjustedFrames    = totalFrames - 0.01;
                float animatedTime      = elapsedTime * (fps / adjustedFrames) * _playbackSpeed;
                float frameFloat        = frac(animatedTime) * totalFrames;
                float nextFrameIndex    = floor(frameFloat) + 1.0;
                float manualFrame       = floor(_displayFrame);

                float selectedFrame     = _autoPlayback ? nextFrameIndex : manualFrame;
                float activeFrameFrac   = frac(_autoPlayback ? frameFloat : _displayFrame);

                // --- Sampling UVs ---
                float2 texcoordUV       = ComputeVatUV(selectedFrame,       IN.uv1.r, IN.uv1.g,
                                                       OneMinusBoundMaxR, MultiplyBoundMinB, totalFrames);
                float2 texcoordNextFrame = ComputeVatUV(selectedFrame + 1.0, IN.uv1.r, IN.uv1.g,
                                                       OneMinusBoundMaxR, MultiplyBoundMinB, totalFrames);

                // --- Sample rotation texture (current frame) ---
                float4 rotSample    = SAMPLE_TEXTURE2D_LOD(_rotTexture, sampler_rotTexture, texcoordUV, 0);
                float4 rotRemapped  = (rotSample - 0.5) * 2.0;           // map [0,1] -> [-1,1]
                float4 rotFinal     = ComparisonBoundMaxb ? rotSample : rotRemapped;
                float3 rotXYZ       = rotFinal.rgb;

                // --- Sample position texture (current frame) ---
                float4 posSample    = SAMPLE_TEXTURE2D_LOD(_posTexture, sampler_posTexture, texcoordUV, 0);
                float3 posRGB       = posSample.rgb;
                float  posA         = posSample.a;

                // MaxComponent index is integer part of posA*4; pscale is fractional part
                float quatMaxIdxScaled  = posA * 4.0;
                float quatMaxIdx        = floor(quatMaxIdxScaled);

                // --- Decode quaternion ---
                float4 q = DecodeQuaternion(rotXYZ, quatMaxIdx);

                // --- Decode piece pivot position ---
                float3 boundsMax    = float3(_boundMaxX, _boundMaxY, _boundMaxZ);
                float3 boundsMin    = float3(_boundMinX, _boundMinY, _boundMinZ);

                float3 posRawForDecode = posRGB;
                #if defined(_TWO_TEX_POS)
                    float4 posSample2 = SAMPLE_TEXTURE2D_LOD(_posTexture2, sampler_posTexture2, texcoordUV, 0);
                    posRawForDecode = posRGB + posSample2.rgb * 0.01;
                #endif

                float3 posDecoded   = posRawForDecode * (boundsMax - boundsMin) + boundsMin;
                float3 piecePos     = ComparisonBoundMaxb ? posRawForDecode : posDecoded;

                // --- Piece scale from posA fractional (decoded via BoundMaxY metadata) ---
                float boundMaxYfracDenom = 1.0 - frac(_boundMaxY * 10.0);
                // Avoid divide-by-zero
                boundMaxYfracDenom = max(boundMaxYfracDenom, 1e-5);
                float pscaleFromPosA = (1.0 - frac(quatMaxIdxScaled)) / boundMaxYfracDenom;
                float pscale         = _pscaleAreInPosA ? pscaleFromPosA : 1.0;
                float totalScale     = _globalPscaleMul * pscale;

                // --- Rest pivot from UV2/UV3 ---
                // VAT3 encodes rest-frame pivot per-vertex:
                //   pivot.x = -uv2.r,   pivot.y = uv3.r,   pivot.z = 1 - uv3.g
                float3 restPivot    = float3(-IN.uv2.r, IN.uv3.r, 1.0 - IN.uv3.g);

                // --- Rotate local offset by piece quaternion, then scale ---
                float3 localOffset  = IN.positionOS - restPivot;
                float3 rotatedLocal = RotateByQuat(localOffset, q);
                float3 scaledLocal  = rotatedLocal * totalScale;

                // --- Interframe position interpolation ---
                float3 finalPiecePos = piecePos;
                #if defined(_INTERPOLATE)
                {
                    float4 posSampleNext = SAMPLE_TEXTURE2D_LOD(_posTexture, sampler_posTexture, texcoordNextFrame, 0);
                    float3 posRGBNext    = posSampleNext.rgb;
                    #if defined(_TWO_TEX_POS)
                    {
                        float4 pos2Next = SAMPLE_TEXTURE2D_LOD(_posTexture2, sampler_posTexture2, texcoordNextFrame, 0);
                        posRGBNext += pos2Next.rgb * 0.01;
                    }
                    #endif
                    float3 posDecodedNext   = posRGBNext * (boundsMax - boundsMin) + boundsMin;
                    float3 piecePosNext     = ComparisonBoundMaxb ? posRGBNext : posDecodedNext;
                    finalPiecePos = lerp(piecePos, piecePosNext, activeFrameFrac);
                }
                #endif

                // --- Assemble final object-space vertex position ---
                float3 animatedPos = scaledLocal + finalPiecePos;

                // Revert to rest pose for frame 0 / first frame (unless _animateFirstFrame is on)
                float wrappedForCheck = fmod(selectedFrame - 1.0, totalFrames);
                bool  isRestFrame     = (wrappedForCheck < 0.5) && !(_animateFirstFrame > 0.5);
                float3 finalPosOS     = isRestFrame ? IN.positionOS : animatedPos;

                // Collapse if vertex has no piece association (uv1.g ~ 0)
                finalPosOS = (IN.uv1.g <= 0.1) ? float3(0, 0, 0) : finalPosOS;

                // --- Normal rotation ---
                float3 rotatedNormalOS = isRestFrame
                                         ? IN.normalOS
                                         : normalize(RotateByQuat(IN.normalOS, q));
                float3 normalWS = TransformObjectToWorldNormal(rotatedNormalOS);

                // --- VAT color ---
                float4 vatColor = float4(1, 1, 1, 1);
                #if defined(_LOAD_COL_TEX)
                {
                    vatColor = SAMPLE_TEXTURE2D_LOD(_colTexture, sampler_colTexture, texcoordUV, 0);
                    #if defined(_INTERPOLATE)
                    if (_interpolateCol > 0.5)
                    {
                        float4 colNext = SAMPLE_TEXTURE2D_LOD(_colTexture, sampler_colTexture, texcoordNextFrame, 0);
                        vatColor = lerp(vatColor, colNext, activeFrameFrac);
                    }
                    #endif
                }
                #endif

                OUT.vatColor   = vatColor * _BaseColor;
                OUT.positionCS = TransformObjectToHClip(finalPosOS);
                OUT.normalWS   = normalWS;
                OUT.fogFactor  = ComputeFogFactor(OUT.positionCS.z);

                return OUT;
            }

            // ── Fragment shader ───────────────────────────────────────────
            half4 frag(Varyings IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

                half4 albedo = IN.vatColor;

                #if defined(_ALPHATEST)
                    clip(albedo.a - _Cutoff);
                #endif

                float3 normalWS = normalize(IN.normalWS);

                // --- Lambert diffuse from main light ---
                Light mainLight = GetMainLight();
                float NdotL     = saturate(dot(normalWS, mainLight.direction));
                float3 diffuse  = mainLight.color * NdotL;

                // --- SH ambient ---
                float3 ambient  = SampleSH(normalWS);

                // --- Combine ---
                float3 finalColor = albedo.rgb * (diffuse + ambient) + _EmissionColor.rgb;
                finalColor = MixFog(finalColor, IN.fogFactor);
                return half4(finalColor, albedo.a);
            }

            ENDHLSL
        }

    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}