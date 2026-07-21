{
  description = "QuickNotes reproducible build with Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system} = {
        quicknotes = pkgs.buildGoModule rec {
          pname = "quicknotes";
          version = "0.1.0";
          src = ./app;
          vendorHash = null;
          env.CGO_ENABLED = 0;
          ldflags = [ "-s" "-w" ];
        };

        docker = pkgs.dockerTools.buildImage {
          name = "quicknotes";
          tag = "latest";
          created = "1970-01-01T00:00:00Z";
contents = [ self.packages.${system}.quicknotes ];  # <-- добавляем бинарник
          config = {
            Cmd = [ "/bin/quicknotes" ];
            ExposedPorts = {
              "8080/tcp" = {};
            };
            User = "65532";
WorkingDir = "/tmp";
          };
        };

        default = self.packages.${system}.quicknotes;
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          go_1_24
          gopls
          golangci-lint
        ];
      };
    };
}
