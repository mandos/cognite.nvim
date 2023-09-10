{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  };

  outputs = { self, nixpkgs }:
    {
      devShells.x86_64-linux =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
        {
          default =
            pkgs.mkShell {
              buildInputs = with pkgs; [
                pkgs.git
                pkgs.neovim
                pkgs.python311Packages.watchdog
                pkgs.lua-language-server
                pkgs.stylua
              ];
            };
          nvim =
            pkgs.mkShell {
              buildInputs = with pkgs; [
                pkgs.vim
              ];
            };
        };
    };
}
