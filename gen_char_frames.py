#!/usr/bin/env python3
"""Generate a Godot SpriteFrames .tres from a LimeZu character animation sheet.

Usage:  python3 gen_char_frames.py John.png [john_frames.tres]
        python3 gen_char_frames.py Lily.png            # -> lily_frames.tres

Sheet layout is 56 cols x 20 rows regardless of scale, so frame size is derived
from the image: 32x64 for the 32x32 pack, 16x32 for the 16x16 pack.
Within a row, frames are grouped per direction in the order: right, up, left, down.
Edit ROWS below to rename animations or change fps.
"""
import os
import re
import sys

from PIL import Image

COLS, ROWS_N = 56, 20
DIRS = ("right", "up", "left", "down")

src = sys.argv[1] if len(sys.argv) > 1 else "John.png"
out = sys.argv[2] if len(sys.argv) > 2 else os.path.splitext(os.path.basename(src))[0].lower() + "_frames.tres"

W, H = Image.open(src).size
if W % COLS or H % ROWS_N:
    sys.exit("%s is %dx%d, not a 56x20 sheet" % (src, W, H))
FW, FH = W // COLS, H // ROWS_N

src_path = "res://" + src.replace(os.sep, "/")
src_uid = ""
if os.path.exists(src + ".import"):
    m = re.search(r'^uid="([^"]+)"', open(src + ".import").read(), re.M)
    if m:
        src_uid = 'uid="%s" ' % m.group(1)

# name, row, frames-per-direction, directions, fps, loop
ROWS = [
    ("idle_static", 0, 1, DIRS,               5.0, True),
    ("idle",       1,  6, DIRS,               6.0, True),
    ("walk",       2,  6, DIRS,               8.0, True),
    ("sleep",      3,  6, (None,),            3.0, True),
    ("sit_ground", 4,  6, ("right", "left"),  6.0, True),
    ("sit_chair",  5,  6, ("right", "left"),  6.0, True),
    ("phone",      6, 12, ("down",),          8.0, False),
    ("read",       7, 12, ("down",),          8.0, False),
    ("run",        8,  6, DIRS,              12.0, True),
    ("pick_up",    9, 12, DIRS,               8.0, False),
    ("lift",      10, 10, DIRS,               8.0, False),
    ("attack_a",  11, 14, DIRS,              10.0, False),
    ("attack_b",  12, 14, DIRS,              10.0, False),
    ("punch",     13,  6, DIRS,              10.0, False),
    ("punch_alt", 14,  6, DIRS,              10.0, False),
    ("throw",     15,  6, DIRS,              10.0, False),
    ("gun_grab",  16,  4, DIRS,              10.0, False),
    ("gun_idle",  17,  6, DIRS,               8.0, True),
    ("gun_shoot", 18,  3, DIRS,              12.0, False),
    ("hurt",      19,  3, DIRS,              10.0, False),
]

# sub-loops flagged on the sheet itself ("4-9 loop", "1-6 loop")
SUBLOOPS = [
    ("phone_loop", 6, range(4, 10), ("down",), 8.0, True),
    ("read_loop",  7, range(0, 6),  ("down",), 8.0, True),
]

atlas = {}   # (col,row) -> sub-resource id
order = []


def tex(col, row):
    key = (col, row)
    if key not in atlas:
        atlas[key] = "AtlasTexture_%d_%d" % (col, row)
        order.append(key)
    return atlas[key]


anims = []


def add(name, row, cols, fps, loop):
    frames = ",".join('{\n"duration": 1.0,\n"texture": SubResource("%s")\n}' % tex(c, row) for c in cols)
    anims.append('{\n"frames": [%s],\n"loop": %s,\n"name": &"%s",\n"speed": %s\n}'
                 % (frames, "true" if loop else "false", name, fps))


for name, row, n, dirs, fps, loop in ROWS:
    for i, d in enumerate(dirs):
        cols = range(i * n, i * n + n)
        add(name if d is None else "%s_%s" % (name, d), row, cols, fps, loop)

for name, row, rel, dirs, fps, loop in SUBLOOPS:
    for i, d in enumerate(dirs):
        add(name if d is None else "%s_%s" % (name, d), row, rel, fps, loop)

subs = "\n".join(
    '[sub_resource type="AtlasTexture" id="%s"]\natlas = ExtResource("1_sheet")\nregion = Rect2(%d, %d, %d, %d)\n'
    % (atlas[(c, r)], c * FW, r * FH, FW, FH) for c, r in order)

text = ('[gd_resource type="SpriteFrames" load_steps=%d format=3]\n\n'
        '[ext_resource type="Texture2D" %spath="%s" id="1_sheet"]\n\n'
        '%s\n[resource]\nanimations = [%s]\n'
        % (len(order) + 2, src_uid, src_path, subs, ", ".join(anims)))

open(out, "w").write(text)
print("wrote %s: frame %dx%d, %d animations, %d frames" % (out, FW, FH, len(anims), len(order)))
