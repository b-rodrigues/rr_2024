let
  # On définit les dépôts à utiliser
  # il s'agit ici du repo officiel 'nixpkgs' officiel de NixOS
  # on pointe sur le "head" de master, donc cette expression ne
  # sera par reproductible!
  # On peut remplacer le lien par un lien qui pointe vers un commit
  # pour assurer la reproductibilité ou même utiliser un fork!
  pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/refs/heads/master.tar.gz") {};

  # Liste de paquets "système"
  system_packages = builtins.attrValues {
    inherit (pkgs) R python312;
  };

  # Liste de paquets à installer depuis Github
  git_pkgs = [
    (pkgs.rPackages.buildRPackage {
        name = "rix";
        src = pkgs.fetchgit {
        url = "https://github.com/b-rodrigues/rix/";
        branchName = "master";
        rev = "2bcd605e5b3f00582ec5262abf5f0cbefe26f905";
        sha256 = "sha256-7GAx0oVSSMYLOSBttQC1JxsLxaCriPJYCr59DhAiU+E=";
       };
       propagatedBuildInputs = builtins.attrValues {
         inherit (pkgs.rPackages) codetools curl httr jsonlite sys;
       };
    })

    (pkgs.rPackages.buildRPackage {
        name = "fusen";
        src = pkgs.fetchgit {
        url = "https://github.com/ThinkR-open/fusen";
        branchName = "main";
        rev = "d617172447d2947efb20ad6a4463742b8a5d79dc";
        sha256 = "sha256-TOHA1ymLUSgZMYIA1a2yvuv0799svaDOl3zOhNRxcmw=";
       };
       propagatedBuildInputs = builtins.attrValues {
         inherit (pkgs.rPackages)
           attachment
           cli
           desc
           devtools
           glue
           here
           magrittr
           parsermd
           roxygen2
           stringi
           tibble
           tidyr
           usethis
           yaml;
       };
    })
  ];

  # Liste de paquets R à installer depuis nixpkgs
  rpkgs = builtins.attrValues {
    inherit (pkgs.rPackages) 
      chronicler
      data_table
      reticulate;
  };

  # Liste de paquets Python à installer depuis nixpkgs
  pypkgs = builtins.attrValues {
    inherit (pkgs.python312Packages) 
      polars
      plotnine;
  };

 # Liste de paquets LaTeX à installer depuis nixpkgs
  tex = (pkgs.texlive.combine {
    inherit (pkgs.texlive)
      scheme-small
      amsmath
      booktabs
      setspace
      lineno
      cochineal
      tex-gyre
      framed
      multirow
      wrapfig
      fontawesome5
      tcolorbox
      orcidlink
      environ
      tikzfill
      pdfcol;
  });

in
  # pkgs.mkShell crée le 'shell' ou environmment de dév
  pkgs.mkShell {

    # On définit les inputs de l'environnement de dév
    buildInputs = [ system_packages rpkgs pypkgs git_pkgs tex ];

    # On définit une commande, optionnelle, à executer à l'entrée du shell
    shellHook = "R --vanilla";
  }
