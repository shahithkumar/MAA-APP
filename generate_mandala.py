import math

cx, cy = 500, 500
svg = ['<svg viewBox="0 0 1000 1000" xmlns="http://www.w3.org/2000/svg">']

def get_p(r, a): return cx + r*math.cos(a), cy + r*math.sin(a)

def draw_circle(r, lw=4):
    p1 = get_p(r, 0)
    p2 = get_p(r, math.pi)
    svg.append(f'<path d="M {p1[0]},{p1[1]} A {r},{r} 0 1,1 {p2[0]},{p2[1]} A {r},{r} 0 1,1 {p1[0]},{p1[1]} Z" fill="#FFFFFF" stroke="#222222" stroke-width="{lw}" stroke-linejoin="round" />')

def draw_layer(num, r_in, r_out, w, off=0, style=0):
    for i in range(num):
        a = off + (i * 2 * math.pi / num)
        p1 = get_p(r_in, a - w)
        p2 = get_p(r_out, a)
        p3 = get_p(r_in, a + w)
        
        if style == 0:
            cp1 = get_p(r_in + (r_out-r_in)*0.4, a - w*1.5)
            cp2 = get_p(r_out*0.8, a)
            cp3 = get_p(r_out*0.8, a)
            cp4 = get_p(r_in + (r_out-r_in)*0.4, a + w*1.5)
            svg.append(f'<path d="M {cx},{cy} L {p1[0]},{p1[1]} C {cp1[0]},{cp1[1]} {cp2[0]},{cp2[1]} {p2[0]},{p2[1]} C {cp3[0]},{cp3[1]} {cp4[0]},{cp4[1]} {p3[0]},{p3[1]} Z" fill="#FFFFFF" stroke="#222222" stroke-width="4" stroke-linejoin="round" />')
        elif style == 1: 
            svg.append(f'<path d="M {cx},{cy} L {p1[0]},{p1[1]} L {p2[0]},{p2[1]} L {p3[0]},{p3[1]} Z" fill="#FFFFFF" stroke="#222222" stroke-width="4" stroke-linejoin="round"/>')

draw_circle(480, 8)
draw_layer(32, 380, 480, math.pi/32, math.pi/32, 1)
draw_layer(16, 260, 440, math.pi/24, 0, 0)
draw_circle(280)
draw_layer(24, 160, 270, math.pi/24, math.pi/24, 1)
draw_circle(170)
draw_layer(12, 60, 160, math.pi/12, 0, 0)
draw_layer(8, 20, 75, math.pi/8, math.pi/8, 1)
draw_circle(30)

svg.append('</svg>')
        
with open('c:/Users/shahi/OneDrive/Documents/Mental_Health_App_Backend/mental_health_app_frontend/assets/images/mandala_zen.svg', 'w') as f:
    f.write("\n".join(svg))
print("Successfully generated mandala_zen.svg with 96 distinct colorable geometric nodes!")
