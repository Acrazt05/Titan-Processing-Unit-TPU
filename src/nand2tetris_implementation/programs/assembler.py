import sys

# =========================
# Lookup Tables
# =========================

comp_table = {
    # a = 0
    "0":   ("0", "101010"),
    "1":   ("0", "111111"),
    "-1":  ("0", "111010"),
    "D":   ("0", "001100"),
    "A":   ("0", "110000"),
    "!D":  ("0", "001101"),
    "!A":  ("0", "110001"),
    "-D":  ("0", "001111"),
    "-A":  ("0", "110011"),
    "D+1": ("0", "011111"),
    "A+1": ("0", "110111"),
    "D-1": ("0", "001110"),
    "A-1": ("0", "110010"),
    "D+A": ("0", "000010"),
    "D-A": ("0", "010011"),
    "A-D": ("0", "000111"),
    "D&A": ("0", "000000"),
    "D|A": ("0", "010101"),

    # a = 1 (using M)
    "M":   ("1", "110000"),
    "!M":  ("1", "110001"),
    "-M":  ("1", "110011"),
    "M+1": ("1", "110111"),
    "M-1": ("1", "110010"),
    "D+M": ("1", "000010"),
    "D-M": ("1", "010011"),
    "M-D": ("1", "000111"),
    "D&M": ("1", "000000"),
    "D|M": ("1", "010101"),
}

dest_table = {
    None: "000",
    "M":   "001",
    "D":   "010",
    "DM":  "011",
    "MD":  "011",
    "A":   "100",
    "AM":  "101",
    "MA":  "101",
    "AD":  "110",
    "DA":  "110",
    "ADM": "111",
    "AMD": "111",
    "DAM": "111",
    "DMA": "111",
    "MAD": "111",
    "MDA": "111",
}

jump_table = {
    None: "000",
    "JGT": "001",
    "JEQ": "010",
    "JGE": "011",
    "JLT": "100",
    "JNE": "101",
    "JLE": "110",
    "JMP": "111",
}

# =========================
# Parsing Helpers
# =========================

def parse_line(line):
    """Split code and comment"""
    if "//" in line:
        code, comment = line.split("//", 1)
        return code.strip(), "//" + comment.strip()
    return line.strip(), ""

def assemble_A(value):
    """A-instruction: @xxxx (hex input assumed)"""
    val = int(value, 16)
    if val < 0 or val > 32767:
        raise ValueError(f"A value out of range: {value}")
    return "0" + format(val, "015b")

def assemble_C(code):
    """C-instruction"""
    dest, comp, jump = None, None, None

    # split jump
    if ";" in code:
        code, jump = code.split(";")
        jump = jump.strip()

    # split dest
    if "=" in code:
        dest, comp = code.split("=")
        dest = dest.strip()
        comp = comp.strip()
    else:
        comp = code.strip()

    if comp not in comp_table:
        raise ValueError(f"Invalid comp: {comp}")

    a, c_bits = comp_table[comp]
    d_bits = dest_table.get(dest, "000")
    j_bits = jump_table.get(jump, "000")

    return "111" + a + c_bits + d_bits + j_bits

def to_hex(binary_str):
    return format(int(binary_str, 2), "04X")

# =========================
# Main Assembler
# =========================

def assemble_file(input_file, output_mode="bin"):
    output_lines = []

    with open(input_file, "r") as f:
        for line in f:
            raw_line = line.rstrip("\n")

            code, comment = parse_line(raw_line)

            if not code:
                continue

            if code.startswith("@"):
                binary = assemble_A(code[1:])
            else:
                binary = assemble_C(code)

            if output_mode == "hex":
                out = to_hex(binary)
            else:
                out = binary

            # Preserve original line as comment
            output_lines.append(f"{out} //{code} {comment}".strip())

    output_file = input_file.replace(".tpu", ".mem")

    with open(output_file, "w") as f:
        for line in output_lines:
            f.write(line + "\n")

    print(f"Output written to {output_file}")

# =========================
# CLI Usage
# =========================

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python assembler.py file.tpu [bin|hex]")
        sys.exit(1)

    input_file = sys.argv[1]
    mode = "bin"

    if len(sys.argv) >= 3:
        mode = sys.argv[2]

    assemble_file(input_file, mode)