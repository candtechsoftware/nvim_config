// Combined CRT + Cursor Trail Shader
// CRT monitor aesthetic with Neovide-style cursor warp trail

// === CURSOR TRAIL CONFIG ===
vec4 TRAIL_COLOR = iCurrentCursorColor;
const float DURATION = 0.22;         // trail animation duration in seconds
const float TRAIL_SIZE = 0.6;        // smear amount (0=none, 1=max)
const float MIN_DISTANCE = 1.0;      // min cursor heights to trigger trail
const float TRAIL_BLUR = 2.0;        // trail edge softness
const float TRAIL_GLOW = 0.3;        // glow halo intensity (0=none)

// === CRT CONFIG ===
const float SCANLINE_WEIGHT = 0.01;  // scanline darkness (0=none, 0.15=heavy)
const float VIGNETTE_AMOUNT = 0.03;  // edge darkening (0=none, 0.5=heavy)
const float GLOW_STRENGTH = 0.015;   // phosphor bloom (0=none, 0.15=heavy)
const float GLOW_RADIUS = 1.0;       // bloom sample radius in pixels
const float BRIGHTNESS = 1.01;       // compensate for darkening effects
const float FLICKER = 0.0;           // subtle brightness flicker amplitude

// === FOCUS CONFIG ===
const float UNFOCUS_DIM = 0.4;       // how much to dim when unfocused (0=none, 1=black)
const float UNFOCUS_DESAT = 0.3;     // desaturation when unfocused (0=none, 1=grayscale)
const float FOCUS_FADE_SPEED = 4.0;  // speed of fade transition

// === FILM GRAIN CONFIG ===
const float GRAIN_AMOUNT = 0.005;    // grain intensity (0=none, 0.1=heavy)
const float GRAIN_SPEED = 12.0;      // how fast grain animates

// === CURSOR TRAIL FUNCTIONS ===

float ease(float x) {
    return 1.0 - pow(1.0 - x, 3.0);
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
    s *= mix(1.0, -1.0, step(0.5, c0 * c1 * c2 + (1.0 - c0) * (1.0 - c1) * (1.0 - c2)));
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

vec2 cursorNorm(vec2 v, float isPos) {
    return (v * 2.0 - iResolution.xy * isPos) / iResolution.y;
}

float getDur(float dot_val) {
    float lead = DURATION * (1.0 - TRAIL_SIZE);
    float side = (lead + DURATION) * 0.5;
    float isLead = step(0.5, dot_val);
    float isSide = step(-0.5, dot_val) * (1.0 - isLead);
    return mix(mix(DURATION, side, isSide), lead, isLead);
}

vec4 cursorTrail(vec2 pixelCoord) {
    vec2 vu = cursorNorm(pixelCoord, 1.0);

    vec4 cc = vec4(cursorNorm(iCurrentCursor.xy, 1.0), cursorNorm(iCurrentCursor.zw, 0.0));
    vec4 cp = vec4(cursorNorm(iPreviousCursor.xy, 1.0), cursorNorm(iPreviousCursor.zw, 0.0));

    vec2 off = vec2(-0.5, 0.5);
    vec2 centerCC = cc.xy - cc.zw * off;
    vec2 centerCP = cp.xy - cp.zw * off;

    float dist = distance(centerCC, centerCP);
    float baseProgress = iTime - iTimeCursorChange;

    float sdfCursor = getSdfRect(vu, cc.xy - cc.zw * off, cc.zw * 0.5);

    if (dist < cc.w * MIN_DISTANCE || baseProgress > DURATION) {
        return vec4(0.0);
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

    // Corner durations
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

    // Trail SDF
    float sdfTrail = getSdfQuad(vu, v_tl, v_tr, v_br, v_bl);

    // Antialiased edge
    float blurNorm = cursorNorm(vec2(TRAIL_BLUR), 0.0).x;
    float alpha = TRAIL_COLOR.a * (1.0 - smoothstep(-blurNorm * 0.5, blurNorm, sdfTrail));

    // Glow halo
    float glowAlpha = TRAIL_COLOR.a * TRAIL_GLOW * (1.0 - smoothstep(-blurNorm, blurNorm * 3.0, sdfTrail));
    alpha = max(alpha, glowAlpha);

    // Smooth fade-out over time
    alpha *= 1.0 - smoothstep(DURATION * 0.6, DURATION, baseProgress);

    // Punch hole for native cursor
    alpha *= step(0.0, sdfCursor);

    return vec4(TRAIL_COLOR.rgb, alpha);
}

// === CRT FUNCTIONS ===

float scanline(vec2 uv) {
    float y = uv.y * iResolution.y;
    float scan = sin(y * 3.14159265) * 0.5 + 0.5;
    return 1.0 - SCANLINE_WEIGHT * scan * scan;
}

float vignette(vec2 uv) {
    vec2 centered = uv - 0.5;
    float dist = length(centered * vec2(1.0, iResolution.y / iResolution.x));
    return 1.0 - smoothstep(0.4, 0.9, dist * (1.0 + VIGNETTE_AMOUNT));
}

vec3 phosphorGlow(vec2 uv) {
    vec2 px = vec2(GLOW_RADIUS) / iResolution.xy;
    return (texture(iChannel0, uv + vec2(px.x, 0.0)).rgb
          + texture(iChannel0, uv - vec2(px.x, 0.0)).rgb
          + texture(iChannel0, uv + vec2(0.0, px.y)).rgb
          + texture(iChannel0, uv - vec2(0.0, px.y)).rgb) * 0.25;
}

float filmGrain(vec2 uv, float time) {
    vec3 g = fract(vec3(uv, time * GRAIN_SPEED) * vec3(443.897, 441.423, 437.195));
    g += dot(g, g.yzx + 19.19);
    return fract((g.x + g.y) * g.z) - 0.5;
}

// === MAIN ===

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;

    // Sample texture
    vec3 color = texture(iChannel0, uv).rgb;

    // Phosphor bloom
    vec3 bloom = phosphorGlow(uv);
    color += (bloom - color) * GLOW_STRENGTH;

    // Cursor trail
    vec4 trail = cursorTrail(fragCoord);
    color = mix(color, trail.rgb, trail.a);

    // Scanlines
    color *= scanline(uv);

    // Vignette
    color *= vignette(uv);

    // Brightness compensation + subtle flicker
    color *= BRIGHTNESS + FLICKER * sin(iTime * 8.0);

    // Film grain
    color += filmGrain(uv, iTime) * GRAIN_AMOUNT;

    // Focus dim/fade
    float focusT = clamp((iTime - iTimeFocus) * FOCUS_FADE_SPEED, 0.0, 1.0);
    float blend = float(iFocus) * focusT + (1.0 - float(iFocus)) * (1.0 - focusT);
    float dimFactor = mix(1.0 - UNFOCUS_DIM, 1.0, blend);
    float desatFactor = mix(UNFOCUS_DESAT, 0.0, blend);
    vec3 gray = vec3(dot(color, vec3(0.299, 0.587, 0.114)));
    color = mix(color, gray, desatFactor) * dimFactor;

    fragColor = vec4(color, 1.0);
}
