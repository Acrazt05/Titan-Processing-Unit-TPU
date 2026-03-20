import pygame
import time

WIDTH = 512
HEIGHT = 256
SCALE = 2

pygame.init()
screen = pygame.display.set_mode((WIDTH*SCALE, HEIGHT*SCALE))
clock = pygame.time.Clock()

def read_screen():
    pixels = [[0]*WIDTH for _ in range(HEIGHT)]
    try:
        with open("screen.bin", "r") as f:
            lines = f.readlines()

        for addr, line in enumerate(lines):
            val = int(line.strip(), 16)
            y = addr // 32
            x_base = (addr % 32) * 16

            for b in range(16):
                if val & (1 << b):
                    pixels[y][x_base + b] = 1
    except:
        pass

    return pixels

def write_keyboard(value):
    with open("keyboard.bin", "w") as f:
        f.write(str(value))

running = True

while running:
    screen.fill((255,255,255))

    # Handle keyboard
    keys = pygame.key.get_pressed()
    key_val = 0

    if keys[pygame.K_a]: key_val = 65
    if keys[pygame.K_b]: key_val = 66
    if keys[pygame.K_c]: key_val = 67
    if keys[pygame.K_SPACE]: key_val = 32

    write_keyboard(key_val)

    # Draw screen
    pixels = read_screen()

    for y in range(HEIGHT):
        for x in range(WIDTH):
            if pixels[y][x]:
                pygame.draw.rect(
                    screen,
                    (0,0,0),
                    (x*SCALE, y*SCALE, SCALE, SCALE)
                )

    pygame.display.flip()

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

    clock.tick(120)

pygame.quit()