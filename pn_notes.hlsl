// multipliers when doing interpolation : corner b_i=1, edge b_ij=3, interior b_ij=9
// computation of edge b_ij divides by 3 and interior by 9, so this is undone when interpolating
// reorganize computations to not have factors when interpolating. care for interior b_ij computation which reuses edge b_ij

float2 uv = float2(u, v);
float4 muv_uv = float4 (1 - uv, uv);
float4 muv2_uv2 = muv_uv * muv_uv;
float4 mu3_umu2_u2mu_u3 = muv_uv.xzxz * muv2_uv2.xxzz; // (1-u)^3, u(1-u)^2, u^2(1-u), u^3
float4 mv3_vmv2_v2mv_v3 = muv_uv.ywyw * muv2_uv2.yyww; // (1-v)^3, v(1-v)^2, v^2(1-v), v^3

float4x3 mat_mv3 = float4x3 (row0, row1, row2, row3); // build schematic of which float3 is which with respect to uv
float4x3 mat_mv2v, mat_mvv2, mat_v3;
float3 pos = mul (mv3_vmv2_v2mv_v3.x * mu3_umu2_u2mu_u3, mat_mv3) + mul (mv3_vmv2_v2mv_v3.y * mu3_umu2_u2mu_u3, mat_mv2v) + ...;
