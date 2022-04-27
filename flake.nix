{
  description = "tool that transforms SHAX models into SHACL, XSD and JSON Schema";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      rec {
        packages = flake-utils.lib.flattenTree rec {
          shax-src = pkgs.stdenv.mkDerivation rec {
            name = "shax-src";
            src = ./.;
            buildCommand = ''
              mkdir -p $out
              cp -r ${src}/bin/* $out/
            '';
          };
          shax = pkgs.writeScriptBin "shax" ''
            #!${pkgs.runtimeShell}
            ${pkgs.basex}/bin/basex -b $1 ${shax-src}/shax.xq
          '';
          xsd2shax = pkgs.writeScriptBin "xsd2shax" ''
            #!${pkgs.runtimeShell}
            ${pkgs.basex}/bin/basex -b "request=xsd2shax?xsd=$1" ${shax-src}/shax.xq
          '';
          shax2jsonschema = pkgs.writeScriptBin "shax2jsonschema" ''
            #!${pkgs.runtimeShell}
            ${pkgs.basex}/bin/basex -b "request=jschema?shax=$1" ${shax-src}/shax.xq
          '';
          shax2shacl = pkgs.writeScriptBin "shax2shacl" ''
            #!${pkgs.runtimeShell}
            ${pkgs.basex}/bin/basex -b "request=shacl?shax=$1" ${shax-src}/shax.xq
          '';
        };
        devShell = pkgs.mkShel {
          buildInputs = with pkgs;[ basex ];
        };
        defaultPackage = packages.shax;
      }
    );
}
