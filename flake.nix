{
	outputs = { self, nixpkgs }:
		with nixpkgs.lib;
		let
			supportedSystems = systems.flakeExposed;
			supportedStdenvs =
				[ "default" "gcc" "gcc49" "gcc11" "clang" "clang5" "clang13" ];
			stdenvAttr = n: if n == "default" then "stdenv" else "${n}Stdenv";

			forAllArgs = f:
				genAttrs supportedSystems (system:
					let pkgs = nixpkgs.legacyPackages.${system};
					in genAttrs supportedStdenvs (stdenv:
						f {
							inherit pkgs;
							stdenv = pkgs.${stdenvAttr stdenv};
						}));
		in {
			packages = forAllArgs (import ./.);
			devShells = forAllArgs (import ./shell.nix);
		};
}
