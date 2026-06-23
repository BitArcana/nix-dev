{ pkgs, baseShell }:
pkgs.mkShell {
  inputsFrom = [ baseShell ];
  packages = [
    pkgs.clang-tools  # clangd + clang-format
    pkgs.cmake
    pkgs.ninja
    pkgs.gdb
  ];
}
