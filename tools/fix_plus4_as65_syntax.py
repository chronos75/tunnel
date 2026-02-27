#!/usr/bin/env python3
"""Normalize common Plus/4 asm syntax issues for as65-style sources.

Transforms:
- #(lo label) -> #<label
- #(hi label) -> #>label
- optional label colon insertion for bare label lines
"""
from __future__ import annotations
import re
import sys
from pathlib import Path


def add_label_colons(text: str) -> str:
    out = []
    # likely opcodes/directives to avoid converting
    skip = {
        'org','dw','db','include','incbin','equ','byte','word','text','asc','cmap',
        'lda','sta','ldx','ldy','tax','tay','txa','tya','tsx','txs','pha','pla','php','plp',
        'jmp','jsr','rts','rti','bne','beq','bcc','bcs','bpl','bmi','bvc','bvs','cmp','cpx','cpy',
        'adc','sbc','and','ora','eor','asl','lsr','rol','ror','inc','dec','inx','iny','dex','dey',
        'clc','sec','cli','sei','cld','sed','nop','bit',
    }
    for line in text.splitlines():
        s = line.strip()
        if not s or s.startswith(';'):
            out.append(line)
            continue
        # already labeled or assignment/directive/opcode line
        head = s.split()[0]
        if ':' in head or '=' in s or head.lower() in skip or s.startswith('.') or s.startswith('!'):
            out.append(line)
            continue
        # bare identifier line -> label
        if re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]*', s):
            indent = line[: len(line) - len(line.lstrip())]
            out.append(f"{indent}{s}:")
            continue
        out.append(line)
    return '\n'.join(out) + ('\n' if text.endswith('\n') else '')


def normalize(text: str) -> str:
    text = re.sub(r'#\(\s*lo\s+([A-Za-z_][A-Za-z0-9_]*)\s*\)', r'#<\1', text, flags=re.IGNORECASE)
    text = re.sub(r'#\(\s*hi\s+([A-Za-z_][A-Za-z0-9_]*)\s*\)', r'#>\1', text, flags=re.IGNORECASE)
    # compact spaces around self-modifying offsets
    text = re.sub(r'([A-Za-z_][A-Za-z0-9_]*)\s*\+\s*([0-9]+)', r'\1+\2', text)
    text = add_label_colons(text)
    return text


def main() -> int:
    if len(sys.argv) not in (2, 3):
        print('Usage: fix_plus4_as65_syntax.py <input.asm> [output.asm]')
        return 2
    inp = Path(sys.argv[1])
    out = Path(sys.argv[2]) if len(sys.argv) == 3 else inp.with_name(inp.stem + '_fixed.asm')
    text = inp.read_text(encoding='utf-8', errors='ignore')
    out.write_text(normalize(text), encoding='utf-8')
    print(f'Wrote: {out}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
