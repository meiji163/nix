{ pkgs, ... }:
let
  my-emacs = pkgs.emacs30.override {
    withNativeCompilation = true;
    withSQLite3 = true;
    withTreeSitter = true;
    withWebP = true;
  };
in
(pkgs.emacsPackagesFor my-emacs).emacsWithPackages (
  epkgs: with epkgs; [
    pkgs.mu
    vterm
    multi-vterm
    pdf-tools
    treesit-grammars.with-all-grammars
  ]
)
