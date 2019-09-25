let
  bootstrap = import <nixpkgs> { };

  nixpkgs-pinned = builtins.fromJSON (builtins.readFile ./nixpkgs.json);

  nixpkgs-src = bootstrap.fetchFromGitHub {
    owner = "NixOS";
    repo  = "nixpkgs";
    inherit (nixpkgs-pinned) rev sha256;
  };

  nixpkgs = import nixpkgs-src { };

in
  import ./default.nix { nixpkgs = nixpkgs; }
