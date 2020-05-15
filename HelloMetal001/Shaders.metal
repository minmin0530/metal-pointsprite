//
//  Shaders.metal
//  HelloMetal001
//
//  Created by Yoshiki Izumi on 2019/12/28.
//  Copyright © 2019 Yoshiki Izumi. All rights reserved.
//

// File for Metal kernel and shader functions

#include <metal_stdlib>
#include <simd/simd.h>

// Including header shawhite_edge between this Metal shader code and Swift/C code executing Metal API commands
#import "ShaderTypes.h"

using namespace metal;

struct InOut {
    float4 position [[position]];
    float4 color;
    float3 normal;
};

struct InOut2 {
    float4 position [[position]];
    float pointSize [[point_size]];
    float4 color;
    float3 normal;
    float3 light;
};

vertex InOut2 vertexShader(constant InOut *vertices [[buffer(0)]],
                          uint vid [[vertex_id]],
                          constant Uniforms & uniforms [[ buffer(1) ]]
                          ) {
    InOut2 out;
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * (vertices[vid].position);
    out.color = vertices[vid].color;
    out.normal = ( uniforms.projectionMatrix * uniforms.modelViewMatrix * float4(vertices[vid].normal.xyz, 1.0) ).xyz;
    out.light = uniforms.lightPosition;
    out.pointSize = 256.0 * vertices[vid].color.r * vertices[vid].color.g * vertices[vid].color.b;
    return out;
}


fragment float4 fragmentShader(InOut2 vert [[stage_in]],
                               float2 pointCoord [[point_coord]]
                               ) {    
    float3 n;
    n.xy = pointCoord * 2.0 - 1.0;
    n.z  = 1.0 - dot(n.xy, n.xy);
    if (n.z < 0.0) { discard_fragment(); }
    float4 fragColor = vert.color;
    fragColor.a = (1.0 - cos(n.z * 2.0)) / 3.0 + 0.85;
//    fragColor.r = pow(fragColor.r, 4.0);
//    fragColor.g = pow(fragColor.g, 4.0);
//    fragColor.b = pow(fragColor.b, 4.0);
    fragColor.a = pow(fragColor.a, 12.0);
    return fragColor;
}
