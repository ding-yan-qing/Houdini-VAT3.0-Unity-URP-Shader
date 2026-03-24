// VAT_SoftBody_Lit_Simple.shader
// URP 最简光照 VAT3 Soft Body Deformation shader
// 光照模型：Lambert 漫反射 + SH 环境光（球谐函数）
// 只有 UniversalForward Pass，无阴影投射
//
// 与 RBD 版本的关键区别：
//   - 位置：加法位移（positionOS + 解码位移），无 pivot/pscale/四元数置换
//   - 法线：rotTexture 存储完整 float4 四元数（RGBA=xyzw），
//           HDR remap 作用于全部 4 通道
//           normalOS = RotateByQuat(float3(0,1,0), rotFinal)
//   - 可选压缩法线：posTexture.a * 1024 spheremap 解码（_B_UNLOAD_ROT_TEX）

Shader "SideFX/VAT_SoftBody_Lit_Simple"
{
    Properties
    {
        [Header(Houdini VAT Playback)]
        [Space(4)]
        [ToggleUI] _autoPlayback       ("Auto Playback",            Float) = 1
        _gameTimeAtFirstFrame          ("Game Time at First Frame", Float) = 0
        _playbackSpeed                 ("Playback Speed",           Float) = 1
        _houdiniFPS                    ("Houdini FPS",              Float) = 24
        _displayFrame                  ("Display Frame (Auto=off)", Float) = 0

        [Header(Houdini VAT Data)]
        [Space(4)]
        _frameCount  ("Frame Count",  Float) = 1
        _boundMinX   ("Bound Min X",  Float) = -1
        _boundMinY   ("Bound Min Y",  Float) = -1
        _boundMinZ   ("Bound Min Z",  Float) = -1
        _boundMaxX   ("Bound Max X",  Float) = 1
        _boundMaxY   ("Bound Max Y",  Float) = 1
        _boundMaxZ   ("Bound Max Z",  Float) = 1

        [Header(Houdini VAT Textures)]
        [Space(4)]
        [NoScaleOffset] _posTexture  ("Position Texture",  2D) = "black" {}
        [NoScaleOffset] _rotTexture  ("Rotation Texture",  2D) = "black" {}
        [Toggle(_TWO_TEX_POS)] _B_LOAD_POS_TWO_TEX ("Positions Require Two Textures", Float) = 0
        [NoScaleOffset] _posTexture2 ("Position Texture 2", 2D) = "black" {}
        // 使用 posTexture.a 压缩法线（不加载 rotTexture）
        [Toggle(_B_UNLOAD_ROT_TEX)] _UnloadRotTex ("Use Compressed Normals (no rotTex)", Float) = 0

        [Header(Material)]
        [Space(4)]
        _BaseColor    ("Base Color",    Color) = (1,1,1,1)
        [Toggle(_LOAD_COL_TEX)] _B_LOAD_COL_TEX ("Load VAT Color Texture", Float) = 0
        [NoScaleOffset] _colTexture    ("VAT Color Texture",   2D) = "white" {}

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
            #pragma shader_feature_local_vertex _TWO_TEX_POS
            #pragma shader_feature_local_vertex _B_UNLOAD_ROT_TEX
            #pragma shader_feature_local        _LOAD_COL_TEX
            #pragma shader_feature_local        _ALPHATEST

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            // ── Textures ──────────────────────────────────────────────────
            TEXTURE2D(_posTexture);   SAMPLER(sampler_posTexture);
            TEXTURE2D(_posTexture2);  SAMPLER(sampler_posTexture2);
            TEXTURE2D(_rotTexture);   SAMPLER(sampler_rotTexture);
            TEXTURE2D(_colTexture);   SAMPLER(sampler_colTexture);

            // ── Per-material CBUFFER (SRP Batcher) ────────────────────────
            CBUFFER_START(UnityPerMaterial)
                float  _autoPlayback;
                float  _gameTimeAtFirstFrame;
                float  _playbackSpeed;
                float  _houdiniFPS;
                float  _displayFrame;
                float  _frameCount;
                float  _boundMinX, _boundMinY, _boundMinZ;
                float  _boundMaxX, _boundMaxY, _boundMaxZ;
                float4 _BaseColor;
                float  _Cutoff;
            CBUFFER_END

            // ── Structs ───────────────────────────────────────────────────
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float4 uv1        : TEXCOORD1;   // VAT: piece U (r), frame V weight (g)
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS  : SV_POSITION;
                float3 normalWS    : TEXCOORD0;   // animated world-space normal
                float3 positionWS  : TEXCOORD1;
                float4 vatColor    : TEXCOORD2;
                float  fogFactor   : TEXCOORD3;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            // ── VAT3 Soft Body helper functions ───────────────────────────

            // 用单位四元数旋转向量
            // 公式: v' = v + 2 * cross(q.xyz, q.w*v + cross(q.xyz, v))
            float3 RotateByQuat(float3 v, float4 q)
            {
                float3 t = cross(q.xyz, v);
                return v + cross(q.xyz, t + v * q.w) * 2.0;
            }

            // 计算指定帧的 VAT 采样 UV（与 RBD 相同）
            float2 VatUV(float selectedFrame, float uv1r, float uv1g,
                         float OneMinusBoundMaxR, float MultiplyBoundMinB, float totalFrames)
            {
                float wrapped = fmod(selectedFrame - 1.0, totalFrames);
                float vBase   = (1.0 - uv1g) * OneMinusBoundMaxR
                                + (wrapped / totalFrames) * OneMinusBoundMaxR;
                return float2(MultiplyBoundMinB, 1.0 - vBase);
            }

            // 从 posTexture.a 解码压缩法线（5-bit spheremap）
            // posA 编码：scaledA = posA * 1024
            //   xIdx = floor(scaledA / 32),  yRaw = scaledA - xIdx * 32
            //   xNorm = xIdx / 31.5,  yNorm = yRaw / 31.5
            //   xy = [0,1] → [-2,2]; d = dot(xy,xy)
            //   normal = float3(-sqrt(1-d/4)*xy.x, 1 - d/2, sqrt(1-d/4)*xy.y)
            float3 DecodeCompressedNormal(float posA)
            {
                float scaledA = posA * 1024.0;
                float xIdx    = floor(scaledA / 32.0);
                float yRaw    = scaledA - xIdx * 32.0;
                float xNorm   = xIdx / 31.5;
                float yNorm   = yRaw / 31.5;
                float2 xy     = float2(xNorm, yNorm) * 4.0 - 2.0;
                float d       = dot(xy, xy);
                float sqrtF   = sqrt(saturate(1.0 - d * 0.25));
                return float3(-sqrtF * xy.x, 1.0 - d * 0.5, sqrtF * xy.y);
            }

            // ── Vertex shader ─────────────────────────────────────────────
            Varyings vert(Attributes IN)
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                Varyings OUT = (Varyings)0;
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

                // ---------- Bounds 元数据解码 ----------
                // HDR 标志：BoundMaxZ * 10 小数 >= 0.5
                float ComparisonBoundMaxb = (frac(_boundMaxZ * 10.0) >= 0.5) ? 1.0 : 0.0;

                // 帧行缩放因子（来自 BoundMaxX * -10 的小数部分）
                float OneMinusBoundMaxR   = 1.0 - frac(_boundMaxX * (-10.0));

                // Piece U 缩放（来自 BoundMinZ * 10 的 ceil-subtract）
                float boundMinMul10z      = _boundMinZ * 10.0;
                float OneMinusBoundMinB   = 1.0 - (ceil(boundMinMul10z) - boundMinMul10z);
                float MultiplyBoundMinB   = IN.uv1.r * OneMinusBoundMinB;

                // ---------- 帧选择 ----------
                float totalFrames   = _frameCount;
                float animTime      = (_Time.y - _gameTimeAtFirstFrame)
                                      * (_houdiniFPS / (totalFrames - 0.01))
                                      * _playbackSpeed;
                float frameFloat    = frac(animTime) * totalFrames;
                float selectedFrame = _autoPlayback
                                      ? floor(frameFloat) + 1.0
                                      : floor(_displayFrame);

                // ---------- 采样 UV ----------
                float2 texUV = VatUV(selectedFrame, IN.uv1.r, IN.uv1.g,
                                     OneMinusBoundMaxR, MultiplyBoundMinB, totalFrames);

                // ---------- 采样位置纹理 ----------
                float4 posSample = SAMPLE_TEXTURE2D_LOD(_posTexture, sampler_posTexture, texUV, 0);
                float3 posRGB    = posSample.rgb;
                float  posA      = posSample.a;
                #if defined(_TWO_TEX_POS)
                {
                    float4 pos2 = SAMPLE_TEXTURE2D_LOD(_posTexture2, sampler_posTexture2, texUV, 0);
                    posRGB += pos2.rgb * 0.01;
                }
                #endif

                // ---------- 解码位移（Soft Body 关键：加法！非替换） ----------
                float3 boundsMax    = float3(_boundMaxX, _boundMaxY, _boundMaxZ);
                float3 boundsMin    = float3(_boundMinX, _boundMinY, _boundMinZ);
                float3 posDecoded   = posRGB * (boundsMax - boundsMin) + boundsMin;
                float3 displacement = ComparisonBoundMaxb ? posRGB : posDecoded;

                // Soft Body: 原始位置 + 位移
                float3 finalPosOS = IN.positionOS + displacement;

                // ---------- 法线解码 ----------
                float3 normalOS;
                #if defined(_B_UNLOAD_ROT_TEX)
                    // 压缩法线：从 posTexture.a spheremap 解码
                    normalOS = normalize(DecodeCompressedNormal(posA));
                #else
                    // rotTexture 存储完整 float4 四元数（RGBA = xyzw）
                    // HDR remap 作用于全部 4 通道
                    float4 rotSample = SAMPLE_TEXTURE2D_LOD(_rotTexture, sampler_rotTexture, texUV, 0);
                    float4 rotFinal  = ComparisonBoundMaxb ? rotSample : (rotSample - 0.5) * 2.0;
                    // 将世界上方向 (0,1,0) 用存储的四元数旋转 → 得到动画法线（OS）
                    normalOS = normalize(RotateByQuat(float3(0.0, 1.0, 0.0), rotFinal));
                #endif

                float3 normalWS = TransformObjectToWorldNormal(normalOS);

                // ---------- VAT 颜色 ----------
                float4 vatColor = float4(1, 1, 1, 1);
                #if defined(_LOAD_COL_TEX)
                    vatColor = SAMPLE_TEXTURE2D_LOD(_colTexture, sampler_colTexture, texUV, 0);
                #endif

                OUT.positionCS = TransformObjectToHClip(finalPosOS);
                OUT.positionWS = TransformObjectToWorld(finalPosOS);
                OUT.normalWS   = normalWS;
                OUT.vatColor   = vatColor * _BaseColor;
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

                // --- SH 环境光（球谐函数） ---
                float3 ambient  = SampleSH(normalWS);

                // --- 合并 ---
                float3 lighting   = diffuse + ambient;
                float3 finalColor = albedo.rgb * lighting;
                finalColor        = MixFog(finalColor, IN.fogFactor);

                return half4(finalColor, albedo.a);
            }

            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
