{
  description = "a quick tool to toggle systemd services";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1"; # unstable Nixpkgs

  outputs =
    { self, ... }@inputs:

    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forEachSupportedSystem =
        f:
        inputs.nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            inherit system;
            pkgs = import inputs.nixpkgs { inherit system; };
          }
        );
    in
    {
      overlays.default = final: prev: {
        systemctl-toggle = final.callPackage ./package.nix { };
      };

      devShells = forEachSupportedSystem (
        { pkgs, system }:
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              go
              gotools
              golangci-lint
              self.formatter.${system}
              gh
            ];
          };
        }
      );

      packages = forEachSupportedSystem (
        { pkgs, ... }:
        {
          default = pkgs.callPackage ./package.nix { };
        }
      );

      formatter = forEachSupportedSystem ({ pkgs, ... }: pkgs.nixfmt-tree);
    };
}
