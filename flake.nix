{
  description = "My portable Neovim configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim.url = "github:nix-community/nixvim";
  };

  outputs = { self, nixpkgs, nixvim, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems f;
    in
    {
      packages = forAllSystems (system:
        let
          nvim = nixvim.legacyPackages.${system}.makeNixvim {
            # Basic editor settings
            opts = {
              number = true;
              relativenumber = true;
              tabstop = 2;
              shiftwidth = 2;
              expandtab = true;
              wrap = false;
              scrolloff = 8;
              hlsearch = false;
              incsearch = true;
              termguicolors = true;
            };

            # Keymaps
            keymaps = [
              {
                mode = "n";
                key = "<Space>";
                action = "<Nop>";
                options.silent = true;
              }
            ];

            globals.mapleader = " ";
          };
        in
        {
          default = nvim;
          neovim = nvim;
        });

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          tmuxConf = pkgs.writeText "tmux.conf" ''
            set -g default-shell ${pkgs.fish}/bin/fish
          '';

          tmux = pkgs.writeShellScriptBin "tmux" ''
            exec ${pkgs.tmux}/bin/tmux -f ${tmuxConf} "$@"
          '';
        in
        {
          default = pkgs.mkShell {
            shellHook = ''
              exec ${pkgs.fish}/bin/fish --init-command '
                functions --copy fish_prompt _original_fish_prompt
                function fish_prompt
                  echo -n "🚀 "
                  _original_fish_prompt
                end
              '
            '';
            packages = [
              self.packages.${system}.default
              pkgs.ripgrep
              pkgs.fd
              pkgs.fzf
              pkgs.git
              pkgs.bat
              tmux
            ];
          };
        });
    };
}
