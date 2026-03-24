// VAT_ParticleSprites_Lit_Simple.shader
// URP 最简光照 VAT3 Particle Sprites shader
// 光照模型：Lambert 漫反射 + SH 环境光（球谐函数）
// 只有 UniversalForward Pass，无阴影投射
//
// 与 RBD / SoftBody / DynamicRemeshing 的关键区别：
//   - Bounds 元数据槽位完全不同：
//       HDR 标志         = frac(boundMinZ * 10) >= 0.5        （非 boundMaxZ）
//       帧行缩放         = 1 - frac(-boundMinX * 10)          （非 -boundMaxX）
//       Piece U 缩放     = 1 - (ceil(boundMaxZ*10) - boundMaxZ*10) （非 boundMinZ）
//       Pscale 分母      = 1 - frac(boundMinY * 10)           （非 boundMaxY）
//   - UV 布局：uv0 = 精灵角点(r,g)，uv1 = VAT 帧数据(r=particleU, g=frameV)
//   - 位置：绝对坐标（来自 posTexture），顶点着色器用 uv0 角点偏移构建 billboard
//   - 法线：视图前方方向（始终朝向摄像机）

Shader "SideFX/VAT_ParticleSprites_Lit_Simple"
{
    Properties
    {
        [Header(Houdini VAT Playback)]
        [Space(4)]
        [ToggleUI] _B_autoPlayback     ("Auto Playback",            Float) = 1
        _gameTimeAtFirstFrame          ("Game Time at First Frame", Float) = 0
        _playbackSpeed                 ("Playback Speed",           Float) = 1
        _houdiniFPS                    ("Houdini FPS",              Float) = 60
        _displayFrame                  ("Display Frame (Auto=off)", Float) = 1
        [ToggleUI] _B_interpolate      ("Interframe Interpolation", Float) = 0

        [Header(Houdini VAT Data)]
        [Space(4)]
        _frameCount  ("Frame Count",  Float) = 1
        _boundMinX   ("Bound Min X",  Float) = 0
        _boundMinY   ("Bound Min Y",  Float) = 0
        _boundMinZ   ("Bound Min Z",  Float) = 0
        _boundMaxX   ("Bound Max X",  Float) = 1
        _boundMaxY   ("Bound Max Y",  Float) = 1
        _boundMaxZ   ("Bound Max Z",  Float) = 1

        [Header(Houdini VAT Textures)]
        [Space(4)]
        [NoScaleOffset] _posTexture  ("Position Texture",              2D) = "black" {}
        [Toggle(_B_LOAD_POS_TWO_TEX)] _B_LOAD_POS_TWO_TEX ("Positions Require Two Textures", Float) = 0
        [NoScaleOffset] _posTexture2 ("Position Texture 2",            2D) = "black" {}
        [Toggle(_B_LOAD_COL_TEX)] _B_LOAD_COL_TEX ("Load Color Texture", Float) = 1
        [NoScaleOffset] _colTexture  ("Color Texture",                  2D) = "white" {}

        [Header(Particle Scale)]
        [Space(4)]
        [ToggleUI] _B_pscaleAreInPosA    ("Particle Scales in Position Alpha", Float) = 1
        _globalPscaleMul                 ("Global Particle Scale Multiplier",  Float) = 1
        _widthBaseScale                  ("Particle Width Base Scale",          Float) = 0.2
        _heightBaseScale                 ("Particle Height Base Scale",         Float) = 0.2
        [ToggleUI] _B_hideOverlappingOrigin ("Hide Particles Overlapping Origin", Float) = 1
        _originRadius                    ("Origin Effective Radius",            Float) = 0.02

        [Header(Particle Spin)]
        [Space(4)]
        [Toggle(_B_CAN_SPIN)] _B_CAN_SPIN ("Particles Can Spin", Float) = 0
        [ToggleUI] _B_spinFromHeading  ("Compute Spin from Heading Vector", Float) = 0
        _spinPhase                     ("Particle Spin Phase",              Float) = 0
        _scaleByVelAmount              ("Scale by Velocity Amount",         Float) = 1

        [Header(Particle UV)]
        [Space(4)]
        _particleTexUScale ("Particle Texture U Scale", Float) = 1
        _particleTexVScale ("Particle Texture V Scale", Float) = 1

        [Header(Material)]
        [Space(4)]
        _BaseColor ("Base Color", Color) = (1,1,1,1)

        [Header(Rendering)]
        [Space(4)]
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull Mode", Float) = 2
        [Toggle] _ZWrite ("ZWrite", Float) = 1
        [Toggle(_ALPHATEST)] _AlphaTest ("Alpha Test", Float) = 0
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

        Pass
        {
            Name "UniversalForward"
            Tags { "LightMode" = "UniversalForward" }

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
            #pragma shader_feature_local_vertex _B_LOAD_POS_TWO_TEX
            #pragma shader_feature_local_vertex _B_CAN_SPIN
            #pragma shader_feature_local        _B_LOAD_COL_TEX
            #pragma shader_feature_local        _ALPHATEST

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            // ── Textures ──────────────────────────────────────────────────
            TEXTURE2D(_posTexture);   SAMPLER(sampler_posTexture);
            TEXTURE2D(_posTexture2);  SAMPLER(sampler_posTexture2);
            TEXTURE2D(_colTexture);   SAMPLER(sampler_colTexture);

            // ── Per-material CBUFFER (SRP Batcher) ────────────────────────
            CBUFFER_START(UnityPerMaterial)
                float  _B_autoPlayback;
                float  _gameTimeAtFirstFrame;
                float  _playbackSpeed;
                float  _houdiniFPS;
                float  _displayFrame;
                float  _B_interpolate;
                float  _frameCount;
                float  _boundMinX, _boundMinY, _boundMinZ;
                float  _boundMaxX, _boundMaxY, _boundMaxZ;
                float  _B_pscaleAreInPosA;
                float  _globalPscaleMul;
                float  _widthBaseScale;
                float  _heightBaseScale;
                float  _B_hideOverlappingOrigin;
                float  _originRadius;
                float  _B_spinFromHeading;
                float  _spinPhase;
                float  _scaleByVelAmount;
                float  _particleTexUScale;
                float  _particleTexVScale;
                float4 _BaseColor;
                float  _Cutoff;
            CBUFFER_END

            // ── Structs ───────────────────────────────────────────────────
            struct Attributes
            {
                float3 positionOS : POSITION;   // 网格原始位置（billboard 会完全覆盖它）
                float3 normalOS   : NORMAL;
                // uv0: r=精灵 X 角点 [0,1], g=精灵 Y 角点 [0,1]（减去 0.5 得到 [-0.5, 0.5]）
                float4 uv0        : TEXCOORD0;
                // uv1: r=particle U 坐标, g=particle V 权重（与 RBD 的 uv1 含义相同）
                float4 uv1        : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS  : SV_POSITION;
                float3 normalWS    : TEXCOORD0;
                float4 vatColor    : TEXCOORD1;
                float2 particleUV  : TEXCOORD2;
                float  fogFactor   : TEXCOORD3;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            // ── VAT UV 公式（与其他 VAT 类型相同） ───────────────────────
            float2 VatUV(float selectedFrame, float uv1r, float uv1g,
                         float OneMinusBoundMaxR, float MultiplyBoundMinB, float totalFrames)
            {
                float wrapped = fmod(selectedFrame - 1.0, totalFrames);
                float vBase   = (1.0 - uv1g) * OneMinusBoundMaxR
                                + (wrapped / totalFrames) * OneMinusBoundMaxR;
                return float2(MultiplyBoundMinB, 1.0 - vBase);
            }

            // ── Vertex shader ─────────────────────────────────────────────
            Varyings vert(Attributes IN)
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                Varyings OUT = (Varyings)0;
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

                // ---------- Bounds 元数据解码（与 RBD / SoftBody 相同槽位） ----------
                // HDR 标志：frac(boundMaxZ * 10) >= 0.5
                float ComparisonBoundMaxb = (frac(_boundMaxZ * 10.0) >= 0.5) ? 1.0 : 0.0;

                // 帧行缩放：来自 boundMaxX * -10 的小数
                float OneMinusBoundMaxR   = 1.0 - frac(-_boundMaxX * 10.0);

                // Piece U 缩放：来自 boundMinZ * 10 的 ceil-subtract
                float boundMinZmul10      = _boundMinZ * 10.0;
                float OneMinusBoundMinB   = 1.0 - (ceil(boundMinZmul10) - boundMinZmul10);
                float MultiplyBoundMinB   = IN.uv1.r * OneMinusBoundMinB;

                // Pscale 分母：来自 boundMaxY * 10 的小数
                float pscaleDenom         = max(1.0 - frac(_boundMaxY * 10.0), 1e-5);

                // ---------- 帧选择 ----------
                float totalFrames   = _frameCount;
                float animTime      = (_Time.y - _gameTimeAtFirstFrame)
                                      * (_houdiniFPS / (totalFrames - 0.01))
                                      * _playbackSpeed;
                float frameFloat    = frac(animTime) * totalFrames;
                float selectedFrame = _B_autoPlayback
                                      ? floor(frameFloat) + 1.0
                                      : floor(_displayFrame);
                float frameAlpha    = frac(_B_autoPlayback ? frameFloat : _displayFrame);

                // ---------- VAT 采样 UV（当前帧 + 下一帧） ----------
                float2 vatUV      = VatUV(selectedFrame,       IN.uv1.r, IN.uv1.g,
                                          OneMinusBoundMaxR, MultiplyBoundMinB, totalFrames);
                float2 vatUV_next = VatUV(selectedFrame + 1.0, IN.uv1.r, IN.uv1.g,
                                          OneMinusBoundMaxR, MultiplyBoundMinB, totalFrames);

                // ---------- 采样位置纹理（当前帧 + 下一帧） ----------
                float4 posSample      = SAMPLE_TEXTURE2D_LOD(_posTexture, sampler_posTexture, vatUV,      0);
                float4 posSample_next = SAMPLE_TEXTURE2D_LOD(_posTexture, sampler_posTexture, vatUV_next, 0);

                float3 posRGB      = posSample.rgb;
                float3 posRGB_next = posSample_next.rgb;
                float  posA        = posSample.a;
                float  posA_next   = posSample_next.a;

                #if defined(_B_LOAD_POS_TWO_TEX)
                {
                    float4 pos2      = SAMPLE_TEXTURE2D_LOD(_posTexture2, sampler_posTexture2, vatUV,      0);
                    float4 pos2_next = SAMPLE_TEXTURE2D_LOD(_posTexture2, sampler_posTexture2, vatUV_next, 0);
                    posRGB      += pos2.rgb      * 0.01;
                    posRGB_next += pos2_next.rgb * 0.01;
                }
                #endif

                // ---------- 解码粒子中心坐标（绝对坐标） ----------
                float3 boundsMax = float3(_boundMaxX, _boundMaxY, _boundMaxZ);
                float3 boundsMin = float3(_boundMinX, _boundMinY, _boundMinZ);

                float3 posDecoded      = posRGB      * (boundsMax - boundsMin) + boundsMin;
                float3 posDecoded_next = posRGB_next * (boundsMax - boundsMin) + boundsMin;

                float3 particlePos      = ComparisonBoundMaxb ? posRGB      : posDecoded;
                float3 particlePos_next = ComparisonBoundMaxb ? posRGB_next : posDecoded_next;

                // 帧间插值（粒子中心位置）
                float3 particlePosF = _B_interpolate
                                      ? lerp(particlePos, particlePos_next, frameAlpha)
                                      : particlePos;

                // ---------- Pscale 计算 ----------
                float posA_f    = _B_interpolate ? lerp(posA, posA_next, frameAlpha) : posA;
                float pscaleRaw = posA_f / pscaleDenom;

                // 每粒子随机缩放（与参考 Shader 完全一致）
                // 参考 Shader 中 additionalPscaleMul = 1 + RandomRange(uv1.rg, 0, 1) ∈ [1,2]
                // 以 uv1.rg 为种子的 hash，每粒子固定、跨帧一致
                float perParticleRandom  = frac(sin(dot(float2(IN.uv1.r, IN.uv1.g),
                                                        float2(12.9898, 78.233))) * 43758.5453);
                float additionalPscaleMul = 1.0 + perParticleRandom; // ∈ [1, 2]

                // 原点遮挡（距原点过近的粒子比例清零）
                float distThis = distance(particlePos,      float3(0, 0, 0));
                float distNext = distance(particlePos_next, float3(0, 0, 0));
                float maskThis = saturate(sign(distThis - _originRadius));
                float maskNext = saturate(sign(distNext - _originRadius));
                float maskF    = _B_interpolate ? lerp(maskThis, maskNext, frameAlpha) : maskThis;

                float pscaleFinal;
                if (_B_pscaleAreInPosA)
                {
                    pscaleFinal = _B_hideOverlappingOrigin
                                  ? pscaleRaw * _globalPscaleMul * additionalPscaleMul * maskF
                                  : pscaleRaw * _globalPscaleMul * additionalPscaleMul;
                }
                else
                {
                    pscaleFinal = _B_hideOverlappingOrigin
                                  ? _globalPscaleMul * additionalPscaleMul * maskF
                                  : _globalPscaleMul * additionalPscaleMul;
                }

                // ---------- 颜色采样（VAT 颜色纹理） ----------
                float4 vatColor        = float4(1, 1, 1, 1);
                float3 headingViewDir  = float3(0, 0, 0);

                #if defined(_B_LOAD_COL_TEX)
                {
                    float4 colThis = SAMPLE_TEXTURE2D_LOD(_colTexture, sampler_colTexture, vatUV,      0);
                    float4 colNext = SAMPLE_TEXTURE2D_LOD(_colTexture, sampler_colTexture, vatUV_next, 0);
                    vatColor = _B_interpolate ? lerp(colThis, colNext, frameAlpha) : colThis;
                    // 从颜色通道读取 heading 方向（SideFX 约定：R 取反，G/B 直接用）
                    headingViewDir = float3(-colThis.r, colThis.g, colThis.b);
                }
                #endif

                // ---------- Billboard 方向轴（视图空间 → 世界 → 物体空间） ----------
                // 无自旋：视图空间 right=(1,0,0), up=(0,1,0)
                // 有自旋：从 heading 或旋转角度重新计算 right/up
                float3 viewRight  = float3(1, 0, 0);
                float3 viewUp     = float3(0, 1, 0);
                float  velStretch = 1.0;

                #if defined(_B_CAN_SPIN)
                {
                    if (_B_spinFromHeading)
                    {
                        // 从颜色通道 heading XY 计算旋转轴
                        float2 hXY = headingViewDir.xy;
                        float  hLen = length(hXY);
                        float2 hDir = (hLen > 1e-5) ? hXY / hLen : float2(1, 0);
                        viewRight = float3(hDir.x, hDir.y, 0);
                        viewUp    = cross(viewRight, float3(0, 0, -1));
                        velStretch = _scaleByVelAmount * hLen;
                    }
                    else
                    {
                        // 从 _spinPhase 均匀旋转角度
                        float angle = frac(_spinPhase) * 6.283185;
                        float c = cos(angle);
                        float s = sin(angle);
                        viewRight = float3(c, s, 0);
                        viewUp    = cross(viewRight, float3(0, 0, -1));
                    }
                }
                #endif

                // 视图空间 → 世界空间（方向）
                float3 worldRight = mul((float3x3)UNITY_MATRIX_I_V, viewRight);
                float3 worldUp    = mul((float3x3)UNITY_MATRIX_I_V, viewUp);
                float3 worldFwd   = mul((float3x3)UNITY_MATRIX_I_V, float3(0, 0, 1));

                // 世界空间 → 物体空间（方向）
                float3 rightOS  = normalize(TransformWorldToObjectDir(worldRight));
                float3 upOS     = normalize(TransformWorldToObjectDir(worldUp));
                float3 normalOS = normalize(TransformWorldToObjectDir(worldFwd));

                // ---------- Billboard 顶点偏移 ----------
                // uv0.r/g 在 [0,1] 范围内，减去 0.5 得到以粒子中心为原点的偏移
                float cornerX = IN.uv0.r - 0.5;
                float cornerY = IN.uv0.g - 0.5;

                float3 offsetX = rightOS * cornerX * _widthBaseScale  * pscaleFinal;
                float3 offsetY = upOS    * cornerY * _heightBaseScale * pscaleFinal * velStretch;

                float3 finalPosOS = particlePosF + offsetX + offsetY;

                // 崩塌：uv1.g <= 0.1 的顶点（不属于任何粒子）移到原点
                finalPosOS = (IN.uv1.g <= 0.1) ? float3(0, 0, 0) : finalPosOS;

                // ---------- 法线（始终朝向摄像机） ----------
                float3 normalWS = TransformObjectToWorldNormal(normalOS);

                // ---------- 粒子 UV（用于精灵图像采样，居中缩放） ----------
                float2 uvScale    = float2(_particleTexUScale, _particleTexVScale);
                float2 particleUV = IN.uv0.rg * uvScale + (float2(0.5, 0.5) - uvScale * 0.5);

                // ---------- 输出 ----------
                OUT.positionCS = TransformObjectToHClip(finalPosOS);
                OUT.normalWS   = normalWS;
                OUT.vatColor   = vatColor * _BaseColor;
                OUT.particleUV = particleUV;
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

                // --- 主平行光 Lambert 漫反射 ---
                Light mainLight = GetMainLight();
                float NdotL     = saturate(dot(normalWS, mainLight.direction));
                float3 diffuse  = mainLight.color * NdotL;

                // --- SH 环境光 ---
                float3 ambient  = SampleSH(normalWS);

                // --- 合并 ---
                float3 finalColor = albedo.rgb * (diffuse + ambient);
                finalColor = MixFog(finalColor, IN.fogFactor);
                return half4(finalColor, albedo.a);
            }

            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
