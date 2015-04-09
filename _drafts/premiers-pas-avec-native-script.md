---
layout: post
title: Premiers pas avec NativeScript
summary: Débuter avec le framework en développant une application mobile d'aggrégation de flux HackerNews.
tags:
  - mobile
  - native
  - nativescript
  - telerik
  - javascript
  - css
---

Le 12 Juin 2014, l'éditeur d'outils de développement [Telerik](http://www.telerik.com/) [annonce](http://blogs.telerik.com/blogs/14-06-12/announcing-nativescript---cross-platform-framework-for-building-native-mobile-applications) la sortie de leur nouvelle solution de conception d'applications mobiles natives et multiplateformes.

A l'instar de [Titanium](http://www.appcelerator.com/titanium/), [NativeScript](https://www.nativescript.org/) rejoint la cour des frameworks multiplateformes et natifs.
A l'heure ou j'écris un petit nouveau à fait son apparition, enfin petit ca reste encore à voir, puisqu'il s'agit de [React Native](http://facebook.github.io/react-native/) conçu par **Facebook**. J'espère d'ailleurs pouvoir en parler dans un prochain billet.

## Plateformes

* **iOS**
* **Android**
* Windows Phone (prévu pour la v1.0, en avril 2015 selon la [roadmap](https://www.nativescript.org/roadmap))

## Comment ca fonctionne

NativeScript permet d'abstraire l'API native de la plateforme grâce aux technologies web. Ainsi le templating de votre application se fait grâce à des templates **XML**, le styling est réalisé en **CSS3** et l'accès aux fonctionnalités de la plateforme via du javascript natif ES5. Celà permet aux développeurs de se dispenser de l'apprentissage de nouveaux langages.
Vous pourrez avoir un aperçu plus technique [ici](http://javascript.developpez.com/actu/82307/Telerik-annonce-NativeScript-son-framework-Open-source-de-developpement-d-applications-mobiles-natives/).

## Objectifs




Debugging: pas dispo (juste e nconsole.) Mais prevu dans la v1

Windows phoen pas supporte (prevu v1)


### Installation

Deux options s'offrent à vous:

* Utiliser _NativeScript CLI_ (en local sur votre machine)
* Utiliser _AppBuilder Tool Set_ (sur le cloud)

La procédure d'installation est très bien documenté sur le [site officiel](http://docs.nativescript.org/setup/quick-setup.html).

J'ai décidé d'utiliser la _CLI_ avec uniquement l'environnement iOS.


### Initialisation


Créer le projet

```bash
tns create hacker-news
```

Ajouter la(les) plateforme(s) de votre choix

```bash
cd hacker-news
tns platform add ios
```

Tester le projet sur l'émulateur

```bash
tns run ios --emulator
```

_A chaque modification de code, vous devrez relancer votre application via cette commande._

### Bootstraping

Jetons un oeil sur le fichier `app/app.js`

```javascript
var application = require("application");
application.mainModule = "app/main-page";
application.start();
```

C'est le point d'entrée de votre application. Le module `application` nous permet d'agir sur le comportement global de l'application. La propriété `mainModule` doit être obligatoirement renseigné. Elle attend un chemin relatif vers le fichier javascript qui doit être exécute en premier. Ensuite on peut démarrer l'application grâce à la fonction `start()`.

_la fonction `start()` doit être à la fin de votre fichier. Tout code appelé après cette fonction ne fonctionnera pas._

#### Aperçu du module `application`

* Système hôte

```javascript
if (application.ios) {
    // iOS app
}
```

* Fichier css principal

```javascript
application.cssFile = "app/main.css";
```

* Cycle de vie

```javascript
application.onExit = function () {
    // Do something
}
```

_[Documentation](http://docs.nativescript.org/ApiReference/application/HOW-TO.html) sur le module `application`_

### Debugging

* Popin in-app

```javascript
alert('text');
```

* Composant console natif

```javascript
console.log(application.cssFile);
```

![Trouver la console sur l'émulateur iOS](/assets/ios-emulator-debug.png)

```
Apr  8 12:27:38 iMac-de-Quentin.local hacker-news[8479]: /app/app.js:4:12: CONSOLE LOG app/app.css
```
_Fichier css par défaut_

Difficile de trouver le log.
Impossible de connaître ce que contient un objet

```
Apr  8 12:32:02 iMac-de-Quentin.local hacker-news[9166]: /app/app.js:4:12: CONSOLE LOG [object Object]
``
