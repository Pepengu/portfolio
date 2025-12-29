{
  description = "A development shell with cowsay and lolcat";

  inputs = {
    # Pin nixpkgs to a specific version for reproducibility
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
            elixir
            elixir-ls
            postgresql
        ];

      };
    };
}

