{
  inputs.nixpkgs.url = "nixpkgs/nixos-23.05";

  outputs = { self, nixpkgs, systems }:
  let
    version = "2023.1125";
    forEachSystem = nixpkgs.lib.genAttrs (import systems);
    nixpkgsFor = forEachSystem (system: import nixpkgs { inherit system; });
  in {
    packages = forEachSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        bumpver = pkgs.python3.pkgs.buildPythonApplication rec {
          pname = "bumpver";
          inherit version;

          src = ./.;

          propagatedBuildInputs = with pkgs.python3.pkgs; [
            pathlib2
            click
            toml
            lexid
            colorama
            setuptools
            rich
            looseversion
          ];

          nativeCheckInputs = [
            pkgs.python3.pkgs.pytestCheckHook
            pkgs.git
            pkgs.mercurial
          ];

          disabledTests = [
            # fails due to more aggressive setuptools version specifier validation
            "test_parse_default_pattern"
          ];
        };
      }
    );

    defaultPackage = forEachSystem (system: self.packages.${system}.bumpver);
  };
}
