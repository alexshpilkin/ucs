{
	outputs = { self, nixpkgs }:
		let
			inherit (nixpkgs.lib) genAttrs mapAttrs optionalAttrs systems;

			supportedSystems = systems.flakeExposed or systems.supported.hydra;
			supportedStdenvs =
				[ "default" "gcc" "gcc49" "gcc11" "clang" "clang5" "clang13" ];

			forAllArgs = f:
				genAttrs supportedSystems (system:
					let pkgs = nixpkgs.legacyPackages.${system};
					in genAttrs supportedStdenvs (stdenv:
						f ({
							inherit pkgs;
						} // optionalAttrs (stdenv != "default") {
							stdenv = pkgs."${stdenv}Stdenv";
						})));
		in {
			packages = forAllArgs (import ./.);
			defaultPackage = mapAttrs (systems: pkgs: pkgs.default) self.packages;
			devShells = forAllArgs (import ./shell.nix);
			devShell = mapAttrs (systems: shells: shells.default) self.devShells;
		};
}
