# Setting Up XV-6
We will be working with xv6-riscv, therefore we need the RISC-V versions of QEMU 7.2+, GDB 8.3+, GCC, and Binutils

## Installing RISC-V Versions

### Debian / Ubuntu
`sudo apt-get install git build-essential gdb-multiarch qemu-system-misc gcc-riscv64-linux-gnu binutils-riscv64-linux-gnu`

### Arch
`sudo pacman -S riscv64-linux-gnu-binutils riscv64-linux-gnu-gcc riscv64-linux-gnu-gdb qemu-emulators-full`

### Windows
- On windows, you will need a VM or WSL2 to work with xv6.
- If you have a VM then use the respesctive installation command given above to install the required tools.
- Same should work on WSL2

### MacOS
1. Install developer tools
  - `xcode-select --install`
2. Install homebrew
  - `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
3. Install the RISC-V compiler toolchain
  - `brew tap riscv/riscv && brew install riscv-tools`
4. Install QEMU
  - `brew install qemu`

## Testing Your Installation
You can check if you have the required tools using the following: 

```
$ qemu-system-riscv64 --version

QEMU emulator version 9.1.2
Copyright (c) 2003-2024 Fabrice Bellard and the QEMU Project developers
```

You should also have at least one RISC-V version of gcc:

```
$ riscv64-linux-gnu-gcc --version

riscv64-linux-gnu-gcc (GCC) 14.2.0
Copyright (C) 2024 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

```
$ riscv64-unknown-elf-gcc --version

...
```

```
$ riscv64-unknown-linux-gnu-gcc --version

...
```

## Setting Up XV6
1. Clone the xv6-riscv repo
  - `git clone https://github.com/mit-pdos/xv6-riscv.git`
2. `cd` into the cloned directory
  - `cd xv6-riscv`
3. Run `make qemu`

At the end of the output there should be something like:
```
xv6 kernel is booting

hart 2 starting
hart 1 starting
init: starting sh
$
```

indicating that you have booted into the xv6 os.

If you type ls at the prompt, you should see output similar to the following:
```
$ ls
.              1 1 1024
..             1 1 1024
README         2 2 2292
cat            2 3 34176
echo           2 4 33072
forktest       2 5 16216
grep           2 6 37440
init           2 7 33552
kill           2 8 33008
ln             2 9 32824
ls             2 10 40280
mkdir          2 11 33072
rm             2 12 33048
sh             2 13 54648
stressfs       2 14 33944
usertests      2 15 179480
grind          2 16 49080
wc             2 17 35048
zombie         2 18 32424
console        3 19 0
```

**To quit qemu type: `Ctrl-a x` (press `Ctrl` and `a` at the same time, followed by `x`).**

