{
  description = "I like to schmove schmove it";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }: {
    devShells.x86_64-linux.default = let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
      pkgs.mkShell {
        name = "Schmovement dev shell";
        packages = with pkgs; [
          godot_4
        ];
        shellHook = ''
          zsh
        '';
      };
  };
}
