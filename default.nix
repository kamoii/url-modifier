{ nixpkgs ? import <nixpkgs> {}, compiler ? "default", doBenchmark ? false }:

let

  inherit (nixpkgs) pkgs lib;

  # デフォルトの pcre だと withStatic のオプションを取ってくれないため
  pcre-static = pkgs.callPackage ./nix/pkgs/development/libraries/pcre { withStatic = true; };

  f = { mkDerivation, base, bytestring, pcre-heavy, protolude
      , safe-exceptions, stdenv, tagsoup, text
      }:
      mkDerivation {
        pname = "url-modifier";
        version = "0.1.0.0";
        src = lib.cleanSource ./.;
        isLibrary = true;
        isExecutable = true;
        libraryHaskellDepends = [
          base bytestring protolude safe-exceptions tagsoup text
        ];
        executableHaskellDepends = [
          base bytestring pcre-heavy protolude text
        ];
        homepage = "https://github.com/githubuser/url-modifier#readme";
        description = "Initial project template from stack";
        license = stdenv.lib.licenses.bsd3;
        # 静的コンパンル用のオプション
        enableSharedExecutables = false;
        enableSharedLibraries = false;
        configureFlags = [
          "--ghc-option=-optl=-static"
          "--ghc-option=-optl=-pthread"
          "--ghc-option=-optl=-L${pkgs.gmp6.override { withStatic = true; }}/lib"
          "--ghc-option=-optl=-L${pkgs.zlib.static}/lib"
          "--ghc-option=-optl=-L${pkgs.glibc.static}/lib"
          "--ghc-option=-optl=-L${pcre-static.out}/lib"
        ];
      };

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  variant = if doBenchmark then pkgs.haskell.lib.doBenchmark else pkgs.lib.id;

  drv = variant (haskellPackages.callPackage f {});

in

  if pkgs.lib.inNixShell then drv.env else drv
