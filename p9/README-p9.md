# p9 — Enhanced parser (LRU register allocation)

This folder contains an enhanced version of the p9 practical: a small parser/lexer that emits three-address code (TAC) and uses a simple LRU register allocator.

Files added:

- `enhanced.y` — Bison/Yacc grammar that emits TAC and uses `getreg()` (LRU) to allocate registers.
- `enhanced.l` — Flex lexer for the grammar.
- `build-p9.ps1` — PowerShell script to build the project using `win_bison`, `win_flex`, and `gcc`.
- `sample9.txt` — Sample input to test the parser.

Build & run (PowerShell):

1. From `p9` directory run:

```powershell
.\build-p9.ps1
```

2. Run the produced executable and feed it the sample file:

```powershell
Get-Content sample9.txt | .\enhanced.exe
```

Notes:

- The allocator uses 8 registers (change `MAX_REGS` in `enhanced.y`).
- On MinGW the flex runtime `-lfl` is often not required; the build script compiles without `-lfl`.
