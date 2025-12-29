{
  description = "A development shell with cowsay and lolcat";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
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

            tailwindcss_4
            esbuild

            inotify-tools
            watchman
        ];

      env = {
        TAILWIND_BINARY = "${pkgs.tailwindcss_4}/bin/tailwindcss";
        ESBUILD_BINARY = "${pkgs.esbuild}/bin/esbuild";
        PGDATA = ".postgres";
        PGHOST = ".postgres";
      };

      shellHook = ''

        if [ ! -d $PGDATA ]; then
          initdb --auth-host=trust --auth-local=trust
          # Enable TCP connections
          echo "listen_addresses = 'localhost'" >> $PGDATA/postgresql.conf
          echo "port = 5432" >> $PGDATA/postgresql.conf
          
          # Start PostgreSQL temporarily to create the postgres user
          pg_ctl start -o "-k $PWD -h localhost" -w
          psql -h localhost -d postgres -c "CREATE USER postgres WITH SUPERUSER PASSWORD 'postgres';"
          pg_ctl stop -w
        fi
        pg_ctl start -o "-k $PWD -h localhost"
        echo "PostgreSQL started with postgres user. You can now run: mix ecto.create"
      '';
      };
    };
}

