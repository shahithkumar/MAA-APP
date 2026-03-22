import math

# --- SVG 1: SACRED SUN ---
def generate_sacred_sun():
    cx, cy = 500, 500
    svg = ['<svg viewBox="0 0 1000 1000" xmlns="http://www.w3.org/2000/svg">']
    def get_p(r, a): return cx + r*math.cos(a), cy + r*math.sin(a)

    def draw_layer(num, r_in, r_out, w, style=0, thick=3, off=0):
        for i in range(num):
            a = off + (i * 2 * math.pi / num)
            p1 = get_p(r_in, a - w)
            p2 = get_p(r_out, a)
            p3 = get_p(r_in, a + w)
            
            if style == 0: # Pointy triangle array
                svg.append(f'<path d="M {cx},{cy} L {p1[0]},{p1[1]} L {p2[0]},{p2[1]} L {p3[0]},{p3[1]} Z" fill="#FFFFFF" stroke="#000" stroke-width="{thick}" stroke-linejoin="round"/>')
            elif style == 1: # Sun flares (curves)
                cp1 = get_p(r_in*1.2, a - w)
                cp2 = get_p(r_out*0.8, a)
                cp3 = get_p(r_out*0.8, a)
                cp4 = get_p(r_in*1.2, a + w)
                svg.append(f'<path d="M {cx},{cy} L {p1[0]},{p1[1]} C {cp1[0]},{cp1[1]} {cp2[0]},{cp2[1]} {p2[0]},{p2[1]} C {cp3[0]},{cp3[1]} {cp4[0]},{cp4[1]} {p3[0]},{p3[1]} Z" fill="#FFFFFF" stroke="#000" stroke-width="{thick}" stroke-linejoin="round"/>')

    def draw_circle(r, lw=4):
        p1 = get_p(r, 0)
        p2 = get_p(r, math.pi)
        svg.append(f'<path d="M {p1[0]},{p1[1]} A {r},{r} 0 1,1 {p2[0]},{p2[1]} A {r},{r} 0 1,1 {p1[0]},{p1[1]} Z" fill="#FFFFFF" stroke="#000" stroke-width="{lw}" />')

    draw_circle(490, 8)
    draw_layer(36, 350, 480, math.pi/40, 1, 4)
    draw_layer(24, 250, 400, math.pi/24, 0, 4, math.pi/24)
    draw_circle(300, 5)
    draw_layer(48, 200, 290, math.pi/48, 1, 3)
    draw_layer(16, 120, 220, math.pi/16, 0, 4)
    draw_circle(140, 4)
    draw_layer(12, 40, 130, math.pi/12, 1, 3, math.pi/12)
    draw_circle(50, 3)
    draw_layer(8, 0, 45, math.pi/8, 0, 2)
    
    svg.append('</svg>')
    with open('c:/Users/shahi/OneDrive/Documents/Mental_Health_App_Backend/mental_health_app_frontend/assets/images/sacred_sun.svg', 'w') as f:
        f.write("\n".join(svg))
    print("Successfully generated sacred_sun.svg!")

# --- SVG 2: STAR BURST ---
def generate_star_burst():
    cx, cy = 500, 500
    svg = ['<svg viewBox="0 0 1000 1000" xmlns="http://www.w3.org/2000/svg">']
    def get_p(r, a): return cx + r*math.cos(a), cy + r*math.sin(a)
    
    def draw_circle(r, lw=4):
        p1 = get_p(r, 0)
        p2 = get_p(r, math.pi)
        svg.append(f'<path d="M {p1[0]},{p1[1]} A {r},{r} 0 1,1 {p2[0]},{p2[1]} A {r},{r} 0 1,1 {p1[0]},{p1[1]} Z" fill="#FFFFFF" stroke="#000" stroke-width="{lw}" />')

    def draw_stars(num, r_inner, r_outer, base_width, offset=0):
        for i in range(num):
            angle = offset + (i * 2 * math.pi / num)
            p1 = get_p(r_inner, angle - base_width)
            p_tip = get_p(r_outer, angle)
            p2 = get_p(r_inner, angle + base_width)
            
            svg.append(f'<path d="M {cx},{cy} L {p1[0]},{p1[1]} L {p_tip[0]},{p_tip[1]} L {p2[0]},{p2[1]} Z" fill="#FFFFFF" stroke="#111" stroke-width="3" stroke-linejoin="round"/>')

    draw_circle(490, 8)
    draw_stars(64, 400, 490, math.pi/64)
    draw_circle(420, 5)
    draw_stars(32, 300, 410, math.pi/32, math.pi/32)
    draw_circle(320, 5)
    draw_stars(16, 200, 310, math.pi/16)
    draw_circle(210, 4)
    draw_stars(12, 100, 200, math.pi/12, math.pi/24)
    draw_circle(110, 4)
    draw_stars(8, 30, 100, math.pi/8)
    draw_circle(40, 3)

    svg.append('</svg>')
    with open('c:/Users/shahi/OneDrive/Documents/Mental_Health_App_Backend/mental_health_app_frontend/assets/images/star_burst.svg', 'w') as f:
        f.write("\n".join(svg))
    print("Successfully generated star_burst.svg!")

generate_sacred_sun()
generate_star_burst()
