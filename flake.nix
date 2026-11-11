{
  description = "My programs and configurations";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    systems.url = "github:nix-systems/default";
    # Upstream builds Go 1.27.1 from source until nixpkgs-unstable's
    # go_1_27 catches up, so this works against our nixpkgs pin.
    tailcat = {
      url = "github:tailscale/tailcat";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      stylix,
      disko,
      systems,
      ...
    }@inputs:
    let
      perSystem = callback: nixpkgs.lib.genAttrs (import systems) (system: callback (pkgs system));
      pkgs =
        system:
        import nixpkgs {
          inherit system;
        };
      pkgs-stable =
        system:
        import inputs.nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };
      mkHost =
        hostname:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./host/${hostname}/configuration.nix
            disko.nixosModules.disko
            stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager
          ]
          # Hosts with a declarative disk layout keep it next to their config.
          ++ nixpkgs.lib.optional (builtins.pathExists ./host/${hostname}/disko.nix) ./host/${hostname}/disko.nix
          ++ [
            (
              { config, ... }:
              {
                home-manager = {
                  extraSpecialArgs = {
                    inherit inputs;
                    pkgs-stable = pkgs-stable config.nixpkgs.hostPlatform.system;
                  };
                  useGlobalPkgs = true;
                  users.jack = import ./home/${hostname}.nix;
                  sharedModules = [ stylix.homeModules.stylix ];
                };
              }
            )
          ];
        };
    in
    {
      # Devshell for bootstrapping, accessible through 'nix develop'
      devShells = perSystem (pkgs: import ./shell.nix { inherit pkgs; });

      nixosConfigurations = nixpkgs.lib.genAttrs [
        "lobotomizer"
        "ossifier"
        "giza-power-plant"
        "beguiler"
        "vitrifier"
        "samsara"
      ] mkHost;

      # Reusable overlay so consumers get `pkgs.claude-code` everywhere.
      overlays.default = final: prev: {
        claude-code = final.callPackage ./pkgs/claude-code { };
      };

      packages =
        let
          # claude-code is unfree; allow it so `nix run`/`nix profile install`
          # work without the consumer setting NIXPKGS_ALLOW_UNFREE.
          pkgsFor =
            system:
            import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
        in
        nixpkgs.lib.genAttrs (import systems) (system: {
          claude-code = (pkgsFor system).callPackage ./pkgs/claude-code { };
        });
    };

}
