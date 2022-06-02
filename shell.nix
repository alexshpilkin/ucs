#!/usr/bin/env -S nix develop -f

{ pkgs ? import <nixpkgs> { }
, stdenv ? pkgs.stdenv
, gdb ? pkgs.gdb
, valgrind ? pkgs.valgrind
, llvmPackages ? pkgs.llvmPackages_latest # FIXME
, clang ? llvmPackages.clang
, libllvm ? llvmPackages.libllvm
, ...
}@args:

pkgs.mkShell.override { inherit stdenv; } {
	inputsFrom = [ (import ./. args) ];
	packages = [ clang gdb libllvm valgrind ];
	hardeningDisable = [ "all" ];
}
