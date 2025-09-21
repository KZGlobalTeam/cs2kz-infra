{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-depotdownloader.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    cs2kz-api.url = "github:KZGlobalTeam/cs2kz-api";
  };

  outputs = { nixpkgs, flake-utils, ... }@inputs:
    let inherit (nixpkgs) lib; in
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        formatter = pkgs.treefmt;
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [ treefmt nixpkgs-fmt taplo shfmt ];
        };
      })) // {
      nixosConfigurations = {
        cs2kz-api = let system = "aarch64-linux"; in lib.nixosSystem {
          specialArgs = {
            inherit system inputs;
            cs2kz-api = inputs.cs2kz-api.packages.${system}.cs2kz-api;
            sshKeys = [
              ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB4SBKTQ7WJcihtw3QocLXi+xEc/6HklXigYoltI8iNH alphakeks@dawn''
              ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPe34iB4eZ5KnO8nKXHtH4V0QZNb7Ro/YxZw7xuCEJ7C max@framework''
            ];
          };
          modules = [ ./systems/oracle.nix ];
        };
      };
    };
}

