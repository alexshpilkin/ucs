#!/usr/bin/env -S nix build -f

{ pkgs ? import <nixpkgs> { }, stdenv ? pkgs.stdenv, ... }:

stdenv.mkDerivation {
	name = "libucs";
	src = ./.;
	installPhase = "make prefix=$prefix install";
}
