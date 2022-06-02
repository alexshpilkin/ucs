#!/usr/bin/env -S nix develop -f

{ pkgs ? import <nixpkgs> { }, stdenv ? pkgs.stdenv, ... }@args:

pkgs.mkShell.override { inherit stdenv; } {
	inputsFrom = [ (import ./. args) ];
	packages = with pkgs;
		[
			llvmPackages_latest.libllvm # for llvm-objdump
		];
}
