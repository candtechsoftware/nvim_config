// Neovide-style cursor warp trail
// Smooth, fast, minimal

// --- CONFIG ---
vec4 TRAIL_COLOR = iCurrentCursorColor;
const float DURATION = 0.15;
const float TRAIL_SIZE = 0.7;        // smear amount (0=none, 1=max)
const float MIN_DISTANCE = 1.5;      // min cursor heights to show trail
const float BLUR = 1.5;

// EaseOutCirc - smooth deceleration
float ease(float x) {
    return sqrt(1.0 - pow(x - 1.0, 2.0));
}

float getSdfRect(vec2 p, vec2 center, vec2 half_size) {
    vec2 d = abs(p - center) - half_size;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float seg(vec2 p, vec2 a, vec2 b, inout float s, float d) {
    vec2 e = b - a;
    vec2 w = p - a;
    vec2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    d = min(d, dot(p - proj, p - proj));

    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);
    s *= mix(1.0, -1.0, step(0.5, c0 * c1 * c2 + (1.0-c0) * (1.0-c1) * (1.0-c2)));
    return d;
}

float getSdfQuad(vec2 p, vec2 v1, vec2 v2, vec2 v3, vec2 v4) {
    float s = 1.0;
    float d = dot(p - v1, p - v1);
    d = seg(p, v1, v2, s, d);
    d = seg(p, v2, v3, s, d);
    d = seg(p, v3, v4, s, d);
    d = seg(p, v4, v1, s, d);
    return s * sqrt(d);
}

vec2 norm(vec2 v, float isPos) {
    return (v * 2.0 - iResolution.xy * isPos) / iResolution.y;
}

float getDur(float dot_val) {
    float lead = DURATION * (1.0 - TRAIL_SIZE);
    float side = (lead + DURATION) * 0.5;
    float isLead = step(0.5, dot_val);
    float isSide = step(-0.5, dot_val) * (1.0 - isLead);
    return mix(mix(DURATION, side, isSide), lead, isLead);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    vec2 vu = norm(fragCoord, 1.0);

    vec4 cc = vec4(norm(iCurrentCursor.xy, 1.0), norm(iCurrentCursor.zw, 0.0));
    vec4 cp = vec4(norm(iPreviousCursor.xy, 1.0), norm(iPreviousCursor.zw, 0.0));

    vec2 off = vec2(-0.5, 0.5);
    vec2 centerCC = cc.xy - cc.zw * off;
    vec2 centerCP = cp.xy - cp.zw * off;

    float dist = distance(centerCC, centerCP);
    float baseProgress = iTime - iTimeCursorChange;

    // Current cursor SDF
    float sdfCursor = getSdfRect(vu, cc.xy - cc.zw * off, cc.zw * 0.5);

    // Skip if too close or animation done
    if (dist < cc.w * MIN_DISTANCE || baseProgress > DURATION) {
        return;
    }

    // Current cursor corners
    vec2 cc_tl = vec2(cc.x, cc.y);
    vec2 cc_tr = vec2(cc.x + cc.z, cc.y);
    vec2 cc_bl = vec2(cc.x, cc.y - cc.w);
    vec2 cc_br = vec2(cc.x + cc.z, cc.y - cc.w);

    // Previous cursor corners
    vec2 cp_tl = vec2(cp.x, cp.y);
    vec2 cp_tr = vec2(cp.x + cp.z, cp.y);
    vec2 cp_bl = vec2(cp.x, cp.y - cp.w);
    vec2 cp_br = vec2(cp.x + cp.z, cp.y - cp.w);

    // Movement direction
    vec2 s = sign(centerCC - centerCP);

    // Corner durations based on movement alignment
    float dur_tl = getDur(dot(vec2(-1., 1.), s));
    float dur_tr = getDur(dot(vec2( 1., 1.), s));
    float dur_bl = getDur(dot(vec2(-1.,-1.), s));
    float dur_br = getDur(dot(vec2( 1.,-1.), s));

    // Eased progress per corner
    float prog_tl = ease(clamp(baseProgress / dur_tl, 0.0, 1.0));
    float prog_tr = ease(clamp(baseProgress / dur_tr, 0.0, 1.0));
    float prog_bl = ease(clamp(baseProgress / dur_bl, 0.0, 1.0));
    float prog_br = ease(clamp(baseProgress / dur_br, 0.0, 1.0));

    // Interpolate corners
    vec2 v_tl = mix(cp_tl, cc_tl, prog_tl);
    vec2 v_tr = mix(cp_tr, cc_tr, prog_tr);
    vec2 v_bl = mix(cp_bl, cc_bl, prog_bl);
    vec2 v_br = mix(cp_br, cc_br, prog_br);

    // Trail shape
    float sdfTrail = getSdfQuad(vu, v_tl, v_tr, v_br, v_bl);

    // Antialiased edge
    float blurNorm = norm(vec2(BLUR), 0.0).x;
    float alpha = TRAIL_COLOR.a * (1.0 - smoothstep(0.0, blurNorm, sdfTrail));

    // Composite trail, punch hole for cursor
    vec4 result = mix(fragColor, vec4(TRAIL_COLOR.rgb, fragColor.a), alpha);
    fragColor = mix(result, fragColor, step(sdfCursor, 0.0));
}
