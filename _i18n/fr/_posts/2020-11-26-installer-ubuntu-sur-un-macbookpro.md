---
layout: post
title: Installer Ubuntu sur son MacBookPro
summary: Installer Ubuntu sur son MacBookPro, est-ce viable ? Comment faire ?
tags:
 - Ubuntu
 - OSX
 - Operating System
 - Docker
image: /assets/logo-ubuntu.png
redirect_to: /2020/11/26/installer-ubuntu-sur-un-macbookpro/
---

Après plus de 5 ans j'ai enfin craqué ! Je n'en pouvais plus de ces performances désastreuses de `Docker4Mac`. Faire fonctionner un monolithe d'environ 10 ans sur `Docker4Mac` est une vraie plaie.

Alors oui, `Docker` n'est pas le seul à blamer. Un couplage fort avec une multitude de systèmes n'aide pas non plus (mais c'est un autre sujet). Néanmoins, j'ai aussi constaté la lenteur de ma machine sur des projets bien plus petit. De plus j'ai utilisé très intensivement ma machine et je la sentais en bout de course. Il était temps de lui donner un second souffle.

*Merci à [@kipit](https://twitter.com/rcasagraude) pour son aide précieuse !*

## Matériel

- MacBookPro Mi 2015
- CPU Intel(R) Core(TM) i5-5287U CPU @ 2.90GHz
- RAM 2 X DDR3 Synchrone 1867 MHz
- Webcam Broadcom 720p FaceTime HD Camera
- WiFi Broadcom BCM43602 802.11ac Wireless LAN
- SATA APPLE SSD SM0256

## 1/ Sauvegarder ses données

Je pars sur une installation d'un nouveau système d'exploitation. Je compte écraser tout ce qui se trouve déjà sur mon disque donc je prends le soin de garder tout ce qui me parait important.

Les documents personnels et professionnels, mais aussi des fichiers de configuration. Par exemple mon fichier `.zshrc` ou encore `gitconfig.`

## 2/ Avoir un OSX sous la main

L'installation d'`Ubuntu` peut échouer ou peut tout simplement ne pas me satisfaire. Je dois pouvoir réinstaller le système d'exploitation d'Apple à tout moment. Le support documente bien cette procédure [ici](https://support.apple.com/en-us/HT201372) .

## 3/ Télécharger l'image d'Ubuntu

La dernière version LTS est disponible sur le site d'`Ubuntu`. Il est possible d'avoir des soucis de vitesse de téléchargement. Il existe des [serveurs mirroir](https://launchpad.net/ubuntu/+cdmirrors) si besoin.

## 4/ Transformer une clé USB en image Bootable

J'ai utilisé [Balena Etcher](https://www.balena.io/etcher/) qui est un petit utilitaire extrèmement simple d'utilisation. Il suffit de sélectionner le fichier qui sert d'image puis le disque qui va servir de support.

*NB: J'ai rencontré un petit problème lors de cette étape. L'outil m'indiquait que le disque sur lequel je voulais écrire était occupé. J'ai dû utiliser la commande suivante pour régler le soucis:*

```bash
diskutil umount /path/to/your/disk
```

## 5/ Démarrer l'installation d'Ubuntu

Je redémarre le Mac tout en maintenant la touche `Option (ou alt).` Le menu de `boot` apparait et je peux sélectionner ma clé USB contenant `Ubuntu`.

L'installation est très simple. L'assistant nous guide à travers les étapes essentielles.

Le clavier Mac est reconnu sans problème et disponible dans la liste des claviers disponibles.

Le WiFi fonctionne très bien aussi. Je n'ai eu aucun soucis à me connecter à un réseau sans fil avec un excellent débit (\~100Mbits/s).

Il est aussi possible de chiffrer son disque.

## 6/ Docker & docker-compose

Pour installer `docker` je n'ai pas eu de soucis particulier. Tout est très bien expliqué [ici](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository). 

⚠️ Prenez soin de bien lire le paragraphe en fin d'installation sur la gestion des droits et groupes. Un `group` `docker` est ajouté mais il n'y a personne dedans. Ce qui veut dire que seul l'utilisateur `root` peut exécuter des commandes `docker`. Si vous voulez utiliser `docker` sans `sudo`, la documentation est [ici](https://docs.docker.com/engine/install/linux-postinstall/).

Pour installer `docker-compose` j'ai utilisé `apt`:

```bash
sudo apt install docker-compose
```

## 7/ Python

Pour développer en local sur le monolithe j'ai besoin de `python` (2!) et `fabric`. Pour éviter d'avoir des conflits entre `python2` et `python3`, j'ai décidé d'utiliser [pyenv](https://github.com/pyenv/pyenv#the-automatic-installer) (je vous conseille de bien lire tout le `README`).

Une fois `pyenv` installer, je peux installer une version de `python` spécifique:

```bash
pyenv install 2.7.18
```

Pour installer `fabric`:

```bash
$(pyenv root)/versions/2.7.18/bin/pip install fabric==1.14.0
```

J'utilise l'`aliasing` pour rendre les futures manipulations plus rapide:

```bash
#.zshrc
alias fab="$(pyenv root)/versions/2.7.18/bin/fab"
```

## 8/ Productivité

Sur `Ubuntu Software`, qui est l'équivalent de l'`App Store` sur `Ubuntu`, j'ai pu installer `Discord`, `Slack`, `Todoist`, `Miro` ou encore `PHPStorm`. Je n'ai pas rencontré de problème particulier. Les applications ont l'air de bien fonctionner. Je n'ai par contre pas trouvé `Notion` mais leur `Webapp` fonctionne très bien sur `Firefox`.

## 9/ AirPods

J'ai pu connecter mes `AirPods` avec ma machine en `Bluetooth`. Cependant le son est de moins bonne qualité. La captation du micro aussi me semble moins performante et surtout j'ai l'impression que la distance permise pour continuer à fonctionner est bien moindre que sur OSX. 

## 10/ Webcam

Faire fonctionner la webcam a finalement été le plus gros soucis. A priori il n'y a pas de pilotes disponibles dans `Ubuntu` pour la faire fonctionner. Cependant j'ai trouvé comment faire. Quelqu'un a développé [un pilote sur github](https://github.com/patjak/bcwc_pcie/wiki/Get-Started). La procédure en résumé est disponible [ici](https://askubuntu.com/a/1215628).

## 11/ Les raccourcis clavier

C'est encore quelque chose qui me gêne après quelques heures d'utilisation mais j'ai commencé à prendre les bons réflexes. Cependant j'ai peur d'utiliser de nouveau OSX sur une autre machine et perdre ces habitudes. Je n'ai pas trouvé de solution encore pour adapter mon Ubuntu aux raccourcis utilisés sur OSX.