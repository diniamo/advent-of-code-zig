{pkgs ? import <nixpkgs> {}}:
with pkgs;
  mkShellNoCC {
    packages = [zig];
  }
