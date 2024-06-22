# rix: environnements de développement reproductibles pour développeurs R

## Intro

Le but de ce tutoriel est de présenter le gestionnaire de paquets Nix et comment
celui-ci peu être utilisé pour créer des environnements de développement
reproductibles pour les utilisateurs du langage R.

Afin de simplifier la prise en main de Nix, j’ai développé un paquet (pas encore
dispo sur le CRAN) appelé {rix}. Vous pouvez trouver le dépôt Github du paquet
[ici](https://github.com/b-rodrigues/rix) et le site pkgdown
[ici](https://b-rodrigues.github.io/rix/).

{rix} est actuellement en train d’être évalué pour une éventuelle intégration à
la suite de paquets rOpensci
[ici](https://github.com/ropensci/software-review/issues/625).

## Fonctionnement de base

Nix est un gestionnaire de paquets fonctionnel et déclaratif. On peut malgré
tout l’utiliser de manière interactive et impérative pour installer des
logiciels, mais cela va à l’encontre de la philosophie de Nix.

Qu’est-ce que cela veut dire que Nix est un gestionnaire de paquets
"fonctionnel"? Cela signifie que Nix utilise les principes de la programmation
fonctionnelle pour installer des logiciels. Pour faire simple, dans la
programmation fonctionnelle, `f(x)` va toujours retourner `y`. On dit que `f`
est une fonction "pure". Cela peut sembler évident, mais il existe en
programmation beaucoup de fonctions qui ne sont pas pures. Par exemple,
`rnorm()` ou `install.packages()`. `install.packages("dplyr")` ne va pas
toujours retourner le même résultat, selon la date à laquelle on exécute cette
ligne (une version différente de `dplyr` sera installée) ou selon les dépôts
CRAN configurés.

Et qu’est-ce que cela signifie que Nix est un gestionnaire de paquets
déclaratif? Cela signifie qu’il suffit de déclarer comment un paquet doit
s’installer plutôt que de détailler les étapes. Prenons l’exemple suivant: pour
additionner les 100 premiers nombres entiers, en programmation fonctionnelle on
va écrire:

```
Reduce(sum, seq(1,100))
```

alors qu’en programmation non-fonctionnelle, il va falloir détailler les étapes:

```
result <- 0

for (i in 1:100){
  result <- result + i
}

print(result)
```

Dans l’approche fonctionnelle, il aura suffit de déclarer notre intention.
L’implémentation de la fonction `sum()` et `Reduce()` sont une donnée. Nix va
utiliser ce concept pour installer des logiciels.

Mais qu’est-ce que cela signifie concrètement? Lorsque Nix va installer un
logiciel (R, un paquet R ou n’importe quel autre logiciel disponible dans ses
dépôts), Nix va s’assurer d’installer toujours exactement la même version des
logiciels demandés. Autrement dit, si `f` est une fonction Nix qui installe un
logiciel, alors `f("logiciel")` va toujours installer exactement la même version
de "logiciel" quelque soit la plateforme, la date, bref, quelque soit "l’état du
monde".

Pour réaliser cela, Nix installe les logiciels "à sa façon":

- Aucune connexion internet n’est autorisée lors du processus de compilation.
  Toutes les ressources nécessaires doivent être déclarées au préalable et sont
  téléchargées avant toute chose.

- Aucune dépendance non déclarée ne peut être utilisée. Si installer un logiciel
  X nécessite une dépendance Y, alors Y sera aussi installée avec Nix, même si
  une version de Y est déjà disponible sur la machine. Il en va de même pour les
  dépendances Z de Y et ainsi de suite jusqu'au dépendances les plus "bas niveau"
  nécessaires.

- Aucune variable d’environnement ne peut-être utilisée: il faut les déclarer
  avec Nix aussi.

En conclusion, cela signifie que pour installer un logiciel, ou un environnement
complet, il va falloir écrire un script dans lequel nous déclarerons tout ce qui
est nécessaire.

Si vous n’avez pas déjà installé Nix, c’est maintenant le moment de le faire, en
utilisant l’installateur de [Determinate
Systems](https://github.com/DeterminateSystems/nix-installer). Lancez la
commande depuis la ligne de commande sous Linux ou macOS:

```
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

et pour Windows, lisez
[ici](https://github.com/DeterminateSystems/nix-installer?tab=readme-ov-file#in-wsl2).

## default.nix

Un fichier `default.nix` est un fichier qui contient une expression écrite dans
le langage Nix. Évaluer cette expression résultera dans l’installation d’un
logiciel, ou dans ce qui nous intéresse: un environnement de développement
reproductible. Ouvrez le fichier `basic/default.nix`. Celui-ci contient à peu
près tout ce que vous devez connaître du langage pour pouvoir l’utiliser.

Vous pouvez installer l’environnement en utilisant la commande `nix-build`
depuis la ligne de commande (terminal sous Linux ou macOS, WSL2 depuis Windows).
Cela va télécharger les logiciels depuis le cache public de NixOS (une
distribution Linux utilisant Nix comme gestionnaire de paquets) et installer
l’environnement. Vous verrez un fichier `result` apparaître dans le même
dossier. Il s’agit d’un raccourci vers le dossier d’installation de
l’environnement dans le *Nix store*. Pour récupérer de la place, si vous n’avez
plus besoin d’un environnement, vous pouvez effacer ce fichier `result` et
ensuite appeler `nix-store --gc`.

Pour pouvoir utiliser l’environnement, utilisez `nix-shell`. Après quelques
instants l’environnement est chargé et vous pouvez l’utiliser. Lancer `which R`
par exemple ou `which python`. Démarrez R dans ce shell avec `R` et chargez le
paquet `{reticulate}`:

```
library(reticulate)

py_run_string("print('coucou depuis Python')")
```

Ce fichier illustre les fonctionnalités principales qui nous intéressent:
installer n’importe quel logiciel depuis les dépôts de Nix (cherchez des paquets
[ici](https://search.nixos.org/packages)), installer des paquets depuis Github
et définir une commande à exécuter quand on démarre le *shell* Nix (à partir de
maintenant, je vais utiliser le mot *shell* pour parler d’environnement de
développement).

## Générer des expressions avec rix()

Écrire ces expressions peut être assez complexe, c’est pourquoi on va utiliser
la fonction `rix()` du paquet `{rix}` afin de les générer. Pour l’instant,
`{rix}` n’est pas disponible sur le CRAN, mais vous pouvez l’installer avec les
commandes suivantes:

```
install.packages("rix", repos = c("https://b-rodrigues.r-universe.dev",
  "https://cloud.r-project.org"))
```

Ou si vous êtes sur un système sur lequel R n’est pas installé mais sur lequel
Nix est installé, vous pouvez aussi lancer cette commande:

```
nix-shell --expr "$(curl -sl https://raw.githubusercontent.com/b-rodrigues/rix/master/inst/extdata/default.nix)"
```

Cette commande va démarrer un shell avec R et `{rix}` installé. Une fois `{rix}`
installé ouvrez `tuto/rix_intro/generate_env_vscode.R` et
`tuto/rix_intro/generate_env_rstudio.R`. Ces deux scripts montrent comment
utiliser `rix()`; lancez la fonction et ouvrez le fichier `default.nix` qui est
généré. Il faut savoir qu’il est possible d’utiliser un shell Nix avec un IDE,
néanmoins, RStudio est un peu particulier et doit aussi être installé avec Nix
pour fonctionner. Le problème est que RStudio n’est pas disponible ni pour macOS
ni pour architecture ARM pour Linux via Nix. Il n’y a toutefois pas de soucis
sous Linux ou si vous utilisez un autre éditeur comme VS Code ou Emacs ou
Vim. Si vous utilisez WSL2, vous devez configurer WSL2 de sorte à ce qu’il soit
possible de lancer des applications graphiques pour pouvoir utiliser une
interface installée via Nix, voir
[ici](https://learn.microsoft.com/en-us/windows/wsl/tutorials/gui-apps).

Si le paquet `{languageserver}` est nécessaire pour utiliser votre éditeur
préféré, n'oubliez pas de le rajouter à l'environnement. Cela est fait
automatiquement pour VS Code.

## Nix et {targets}

Ouvrez le dossier `tuto/nix_targets_pipeline` et inspectez le fichier
`_targets.R` et ensuite `create_env.R`. Exécuter `create_env.R` génère un
fichier `default.nix` qui défini un shell dans lequel la pipeline `{targets}`
peut s’exécuter de manière totalement reproductible. La pipeline s’exécute au
lancement du shell. Il est ensuite possible d’inspecter les éléments soit dans
le même shell Nix, soit dans votre environnement R "système" en chargeant
simplement les *targets* avec `targets::tar_load(nom_du_target)`. Il est aussi
possible d’exécuter la pipeline sur Github Actions. Lancez `rix::tar_nix_ga()`
pour écrire le fichier YAML nécessaire. Vous pouvez ensuite *commit* et *push*
et voir la pipeline s’exécuter sur Github Actions. Regardez
[ici](https://github.com/b-rodrigues/nix_targets_pipeline/tree/master) pour un
exemple.

## Exécuter du code dans un subshell

Il est possible d’exécuter du code dans un *subshell* avec `with_nix()`. Cela
signifie que l’on va exécuter une fonction dans un shell Nix qui peut être
différent de l’environnement principal et que l’on récupère ensuite l’output de
cette fonction dans la session principale. Regardez `tuto/subshell/` pour un tel
exemple.

## Docker et Nix

Nix n'est pas une alternative à Docker, même s'il permet de résoudre des
problèmes similaires. Autrement dit, il est tout à fait possible d'utiliser Nix
pour créer une image Docker de manière reproductible. Pour cela, utilisez un
script `{rix}` pour générer le `default.nix` qu'il vous faut, ensuite copiez le
et utilisez le lors du build de l'image Docker. Vous avez maintenant une image
avec les outils qu'il vous faut.

Étant donné que Nix s'occupe de générer un environnement reproductible, vous
pouvez utiliser `ubuntu:latest` comme image de base sans aucun risques. Regardez
dans `tuto/docker`. Cela signifie aussi que vous pouvez utiliser le même
`default.nix` pour développer ou *dockerizer* une analyse ou même l'exécuter sur
Github Actions.

## Shiny et Nix

Il est aussi possible de définir un environnement qui pour développer une
application Shiny, regardez `tuto/shiny`. En utilisant le même `default.nix`
vous pouvez développer localement, et ensuite dockerizer l'application si vous
souhaitez la déployer, toujours en utilisant le même `default.nix`. Il serait
aussi possible de simplement lancer l'application depuis l'environnement sur un
serveur.

## Le cycle de publication des paquets CRAN sur nixpkgs et créer un cache de binaires

Lorsqu'on installe des paquets avec Nix ceux-ci sont compilés localement, sauf
s'ils l'ont été au préalable par Hydra, un service de CI utilisé par la
communauté NixOS. La majorité des paquets sont compilés au préalable et donc
installer des paquets revient à simplement les télécharger. Les paquets seront
donc téléchargés depuis [cache.nixos.org](https://cache.nixos.org/). Toutefois,
il faut savoir que les paquets R du CRAN et Bioconductor disponibles sur
`nixpkgs` ne sont pas mis à jour quotidiennement, autour d'une sortie d'une
nouvelle version de R, environ tous les 3 mois.

S'il vous faut des paquets plus récents, vous pouvez utiliser les options
`"bleeding_edge"` et `"frozen_edge"` de `rix()`. Regardez dans `tuto/bleeding`
pour y trouver un exemple. Les options `"bleeding_edge"` et `"frozen_edge"`
utiliseront un fork de `nixpkgs` dans lequel les paquets R sont mis à jour
quotidiennement de manière automatique, cela signifie que vous pourrez utiliser
des paquets aussi récents que sur CRAN ou Bioconductor. Toutefois, cela signifie
aussi que les paquets n'auront pas eu l'occasion d'être compilés par Hydra, et
qu'il faudra donc les installer en les compilant localement. Cela peut prendre
énormément de temps, donc nous avons aussi mis en place un cache de paquets
en utilisant un service appelé [cachix.org](https://cachix.org/). Vous pouvez
donc utiliser ce cache ce qui vous évitera de devoir compiler des paquets.

L'espace disponible gratuitement est toutefois limité et nous ne pouvons pas
compiler tous les paquets du CRAN, mais nous nous sommes concentrés sur les
paquets qui sont les plus longs à compiler. Pour utiliser notre cache, veuillez
d'abord installer Cachix:

```
nix-env -iA cachix -f https://cachix.org/api/v1/install
```

vous pourrez ensuite activer le cache:

```
cachix use rstats-on-nix
```

Notre cache ne va seulement contenir les paquets qui ne sont pas déjà disponibles
sur le cache publique.

Vous pouvez aussi très facilement créer votre propre cache. Pour cela, créez un
repository Github contenant un fichier `default.nix` dans lequel vous listerez
tous les paquets qu'il vous faut. Ensuite, lancez la fonction
`rix::ga_cachix(cache_name = "", path = ".")` en précisent le nom de votre cache
et le chemin vers votre `default.nix`. Cela va placer un fichier `.yaml` dans
`.github/workflows` qui va compiler les paquets sur Github Actions à chaque fois
que vous pousserez sur master ou main.

Créez ensuite un compte sur [Cachix](https://www.cachix.org/); un compte gratuit
vous donne 5go d'espace. Créez et récupérez votre token d'authentification que
vous devrez coller dans Github. Sur Github, allez dans les options du repository,
ensuite *Secrets et variables*, *Actions* et copiez le token dans le champ
`Secret` et nommez le secret `CACHIX_AUTH`. Maintenant, l'action que nous avons
créé avec `rix::ga_cachix()` va pouvoir s'authentifier et pousser les binaires
dans votre cache!

N'importe qui pour télécharger des binaires depuis votre cache, donc si vous
travaillez en équipe, vous pouvez pré-compiler vos environnements de développement.
Il est possible de compiler les binaires pour Linux/Windows ou macOS sur Github
Actions.

Regardez comment cela est fait pour le paquet `{rix}`
[ici](https://github.com/b-rodrigues/rix/blob/master/.github/workflows/cachix-dev-env.yml).

## Pour en savoir plus

- Documentation officielle de Nix: [https://nix.dev/](https://nix.dev/)

- Nix pills: [https://nixos.org/guides/nix-pills/00-preface](https://nixos.org/guides/nix-pills/00-preface)

- Tuto Nix par l'INRIA: [https://nix-tutorial.gitlabpages.inria.fr/nix-tutorial/](https://nix-tutorial.gitlabpages.inria.fr/nix-tutorial/)

- Site de rix: [https://b-rodrigues.github.io/rix/](https://b-rodrigues.github.io/rix/)

- Github de rix: [https://github.com/b-rodrigues/rix](https://github.com/b-rodrigues/rix)

- Mon blog: [https://www.brodrigues.co/tags/nix/](https://www.brodrigues.co/tags/nix/)

- Mon livre (ne parle pas de Nix, mais de reproductibilité avec Docker et renv): [https://raps-with-r.dev/](https://raps-with-r.dev/)

