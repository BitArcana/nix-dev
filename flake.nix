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

            globals.mapleader = " ";

            keymaps = [
              # Disable space in normal/visual (leader key)
              { mode = ["n" "x"]; key = "<Space>"; action = "<Nop>"; options.silent = true; }

              # Better j/k for wrapped lines
              { mode = ["n" "x"]; key = "j"; action = "v:count == 0 ? 'gj' : 'j'"; options = { expr = true; silent = true; }; }
              { mode = ["n" "x"]; key = "k"; action = "v:count == 0 ? 'gk' : 'k'"; options = { expr = true; silent = true; }; }

              # Window navigation
              { mode = "n"; key = "<C-h>"; action = "<C-w>h"; options = { silent = true; desc = "Go to left window"; }; }
              { mode = "n"; key = "<C-j>"; action = "<C-w>j"; options = { silent = true; desc = "Go to lower window"; }; }
              { mode = "n"; key = "<C-k>"; action = "<C-w>k"; options = { silent = true; desc = "Go to upper window"; }; }
              { mode = "n"; key = "<C-l>"; action = "<C-w>l"; options = { silent = true; desc = "Go to right window"; }; }

              # Window resize
              { mode = "n"; key = "<C-Up>";    action = "<cmd>resize +2<CR>";          options = { silent = true; desc = "Increase window height"; }; }
              { mode = "n"; key = "<C-Down>";  action = "<cmd>resize -2<CR>";          options = { silent = true; desc = "Decrease window height"; }; }
              { mode = "n"; key = "<C-Left>";  action = "<cmd>vertical resize -2<CR>"; options = { silent = true; desc = "Decrease window width"; }; }
              { mode = "n"; key = "<C-Right>"; action = "<cmd>vertical resize +2<CR>"; options = { silent = true; desc = "Increase window width"; }; }

              # Window splits
              { mode = "n"; key = "<leader>-";  action = "<C-w>s"; options = { silent = true; desc = "Split window below"; }; }
              { mode = "n"; key = "<leader>|";  action = "<C-w>v"; options = { silent = true; desc = "Split window right"; }; }
              { mode = "n"; key = "<leader>wd"; action = "<C-w>c"; options = { silent = true; desc = "Delete window"; }; }

              # Buffer navigation
              { mode = "n"; key = "<S-h>"; action = "<cmd>BufferLineCyclePrev<CR>"; options = { silent = true; desc = "Prev buffer"; }; }
              { mode = "n"; key = "<S-l>"; action = "<cmd>BufferLineCycleNext<CR>"; options = { silent = true; desc = "Next buffer"; }; }
              { mode = "n"; key = "[b";    action = "<cmd>BufferLineCyclePrev<CR>"; options = { silent = true; desc = "Prev buffer"; }; }
              { mode = "n"; key = "]b";    action = "<cmd>BufferLineCycleNext<CR>"; options = { silent = true; desc = "Next buffer"; }; }
              { mode = "n"; key = "<leader>bd"; action = "<cmd>bdelete<CR>";        options = { silent = true; desc = "Delete buffer"; }; }
              { mode = "n"; key = "<leader>bo"; action = "<cmd>%bdelete|edit#|bdelete#<CR>"; options = { silent = true; desc = "Delete other buffers"; }; }
              { mode = "n"; key = "<leader>bb"; action = "<C-^>";                   options = { silent = true; desc = "Switch to other buffer"; }; }

              # File
              { mode = "n"; key = "<leader>fn"; action = "<cmd>enew<CR>"; options = { silent = true; desc = "New file"; }; }

              # File tree
              { mode = "n"; key = "<leader>e"; action = "<cmd>Neotree toggle<CR>"; options = { silent = true; desc = "Toggle file tree"; }; }

              # Search (telescope)
              { mode = "n"; key = "<leader>/"; action = "<cmd>Telescope live_grep<CR>";  options = { silent = true; desc = "Live grep"; }; }

              # Diagnostics
              { mode = "n"; key = "]d"; action = "<cmd>lua vim.diagnostic.goto_next()<CR>"; options = { silent = true; desc = "Next diagnostic"; }; }
              { mode = "n"; key = "[d"; action = "<cmd>lua vim.diagnostic.goto_prev()<CR>"; options = { silent = true; desc = "Prev diagnostic"; }; }
              { mode = "n"; key = "]e"; action = "<cmd>lua vim.diagnostic.goto_next({severity=vim.diagnostic.severity.ERROR})<CR>"; options = { silent = true; desc = "Next error"; }; }
              { mode = "n"; key = "[e"; action = "<cmd>lua vim.diagnostic.goto_prev({severity=vim.diagnostic.severity.ERROR})<CR>"; options = { silent = true; desc = "Prev error"; }; }
              { mode = "n"; key = "<leader>cd"; action = "<cmd>lua vim.diagnostic.open_float()<CR>"; options = { silent = true; desc = "Line diagnostics"; }; }
            ];

            plugins.bufferline.enable = true;

            plugins.neo-tree = {
              enable = true;
              settings.window.mappings = {
                "l" = "open";
                "h" = "close_node";
                "<space>" = "none";
              };
            };

            colorschemes.tokyonight = {
              enable = true;
              settings = {
                style = "moon";
                transparent = false;
                styles = {
                  sidebars = "dark";
                  floats = "dark";
                };
              };
            };

            plugins.treesitter = {
              enable = true;
              settings = {
                highlight.enable = true;
                indent.enable = true;
                ensure_installed = [ "lua" "nix" "vim" "vimdoc" ];
              };
            };

            plugins.telescope = {
              enable = true;
              keymaps = {
                "<leader>ff" = "find_files";
                "<leader>fg" = "git_files";
                "<leader>fF" = { action = "find_files"; options.desc = "Find files (cwd)"; };
                "<leader>fr" = "oldfiles";
                "<leader>fb" = "buffers";
              };
            };
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
