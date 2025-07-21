{
  description = "A Nix flake";


  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs }: {
    defaultPackage.x86_64-linux = let
      pkgs = import nixpkgs {
         system = "x86_64-linux";
         config = {
           allowUnfree = true;
         };
      };
    in pkgs.mkShell {
      buildInputs = with pkgs; [
      ];

      shellHook = ''
        '';

    };
  };
  
}

