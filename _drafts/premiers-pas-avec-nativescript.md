---
layout: post
title: Premiers pas avec NativeScript
summary: Débuter avec le framework en développant une application mobile d'aggrégation de flux HackerNews.
tags:
  - mobile
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

Le but est de faire une petit tour du framework. Pour ça nous allons réaliser une mini app Hacker News.
L'application devra présenter une liste de top stories. Chaque top story pourra être consulter dans une webview.

### 1.Installation

Deux options s'offrent à nous:

* Utiliser _NativeScript CLI_ (en local sur votre machine)
* Utiliser _AppBuilder Tool Set_ (sur le cloud)

La procédure d'installation est très bien documenté sur le [site officiel](http://docs.nativescript.org/setup/quick-setup.html).

J'ai décidé d'utiliser la _CLI_ avec l'environnement iOS.


### 2.Initialisation


Créer le projet:

```bash
tns create hacker-news
```

Ajouter la(les) plateforme(s) de votre choix:

```bash
cd hacker-news
tns platform add ios
```

Tester le projet sur l'émulateur:

```bash
tns run ios --emulator
```

Changer le device: tns run ios --emulator --device=iPhone-6
Lister les devices: tns emulate ios --availableDevices

Pas de **live reload** comme sur [Ionic](http://blog.ionic.io/live-reload-all-things-ionic-cli/) ou sur [React Native](http://facebook.github.io/react-native/docs/debugging.html#live-reload).

EDIT: https://github.com/NativeScript/NativeScript/issues/32
http://docs.telerik.com/platform/appbuilder/nativescript/running-your-app/livesync-app

### 3.Bootstraping

Jetons un oeil sur le fichier `app/app.js`:

```javascript
// app.js

var application = require("application");
application.mainModule = "app/main-page";
application.start();
```

Le module `application` donne accès à la configuration globale de l'application. Par exemple:

* La première page de votre application.

```javascript
application.mainModule = "app/main-page";
```

* Démarrer l'application.

```javascript
application.start();
```

_Tout code appelé après cette fonction ne fonctionnera pas ([source](http://docs.nativescript.org/ApiReference/application/README.html))._

* Système d'exploitation

```javascript
if (application.ios) {
    // iOS app
}
```

* Fichier CSS principal

```javascript
application.cssFile = "app/main.css";
```

 Cycle de vie

```javascript
application.onExit = function () {
    // Do something
}
```

_[Documentation](http://docs.nativescript.org/ApiReference/application/HOW-TO.html) sur le module `application`_

### 4.Debugging

* Popin in-app

```javascript
alert('text');
```

* Composant console natif

```javascript
console.log(application.cssFile);
```

![Console de debug sur émulateur iOS - NativeScript](/assets/ios-emulator-debug.png)

```
Apr  8 12:27:38 iMac-de-Quentin.local hacker-news[8479]: /app/app.js:4:12: CONSOLE LOG app/app.css
```
_Fichier css par défaut_

Difficile de trouver les messages de log.

```
Apr  8 12:32:02 iMac-de-Quentin.local hacker-news[9166]: /app/app.js:4:12: CONSOLE LOG [object Object]
```

Impossible de connaître ce que contient un objet.

### 5.Templating

Commençons notre mini application en supprimant les fichiers relatifs au projet d'exemple:

```bash
rm app/app/main-*
```

Ensuite créons notre premier vue:

{% highlight xml startinline %}
{% raw %}
// topstories.xml

<Page xmlns="http://www.nativescript.org/tns.xsd" loaded="pageLoaded">
    <ListView items="{{ topstories }}">
        <ListView.itemTemplate>
            <StackLayout>
                <Label text="{{ title }}" />
                <StackLayout orientation="horizontal">
                    <Label text="{{'By ' + by + ' - ' + score + ' points'}}" />
                </StackLayout>
            </StackLayout>
        </ListView.itemTemplate>
    </ListView>
</Page>
{% endraw %}
{% endhighlight %}

* NativeScript déclenche un évenement quand une page est chargée. Nous pouvons intéragir avec cet évenement grâce à l'attribut `loaded`.
* Une `ListView` qui attend un tableau d'élements `items`.
* Des `Label` avec une propriété `text`
* Un moteur de template (`{% raw %}{{ topstories }}{% endraw %}`) pour binder les données à la vue

### 6.Code behind:

```javascript
{% raw %}
// topstories.js

var model = {
    'topstories' : [
        {
            'title': 'Nokia Agrees to Buy Alcatel-Lucent for $16.6B',
            'by': 'alphadevx',
            'score': 39
        },
        {
            'title': 'Boolean parameters to API functions considered harmful (2011)',
            'by': 'luu',
            'score': 69
        },
        {
            'title': '32-bit X86 Position Independent Code – It\'s That Bad',
            'by': 'cremno',
            'score': 63
        },
        {
            'title': 'Finding bugs in SQLite, the easy way',
            'by': 'robin_reala',
            'score': 275
        },
        {
            'title': 'New Mexico outlaws civil asset forfeiture',
            'by': 'hackercurious',
            'score': 78
        }
    ]
};

exports.pageLoaded = function(args) {
    var page = args.object;
    page.bindingContext = model;
}
{% endraw %}
```

* Initialisation d'une variable qui sera le model relié à la vue.
* `exports` expose à la vue fonctions et attributs.
* Binding du model à la vue `page.bindingContext = model`.

Un aperçu de notre version [0.1.0](https://github.com/qpautrat/native-hacker-news/tree/0.1.0):

![HackerNews avec NativeScript](/assets/native-hacker-news1.png)

### 7.Styling

NativeScript utilise le **CSS** comme mecanisme de stylisation.
Attention tout même, toutes les fonctionnalités ne sont pas implémentées ([loin de là même](http://docs.nativescript.org/styling.html#supported-properties)).

Ajoutons quelques `cssClass` à notre vue:

```xml
{% raw %}
// topstories.xml

<Page xmlns="http://www.nativescript.org/tns.xsd" loaded="pageLoaded">
    <ListView items="{{ topstories }}">
        <ListView.itemTemplate>
            <StackLayout cssClass="topstory">
                <Label text="{{ title }}" />
                <StackLayout>
                    <Label cssClass="author" text="{{'By ' + by + ' - ' + score + ' points'}}" />
                </StackLayout>
            </StackLayout>
        </ListView.itemTemplate>
    </ListView>
</Page>
{% endraw %}
```

Afin de styliser notre page topstories nous devons créer une feuille de style css portant le même nom *topstories.css*:

```css
/* topstories.css */

.topstory {
    background-color: #EAEAD0;
    padding-left: 5px;
    padding-top: 5px;
    padding-bottom: 5px;
    color: #000000;
    font-size: 10px;
}

.author {
    color: #828282;
    font-size: 8px;
}
```

Aperçu de la version [0.1.1](https://github.com/qpautrat/native-hacker-news/tree/0.1.1):

![HackerNews avec NativeScript + CSS](/assets/native-hacker-news2.png)

Afin de coller un peu plus au style du site, ajoutons une barre en haut de notre page:

```xml
{% raw %}
// topstories.xml

<Page xmlns="http://www.nativescript.org/tns.xsd" loaded="pageLoaded">
    <StackLayout>
        <StackLayout cssClass="topbar">
            <Label text="HackerNews with NativeScript" />
        </StackLayout>
        <ListView items="{{ topstories }}">
            <ListView.itemTemplate>
                <StackLayout cssClass="topstory">
                    <Label text="{{ title }}" />
                    <StackLayout>
                        <Label cssClass="author" text="{{'By ' + by + ' - ' + score + ' points'}}" />
                    </StackLayout>
                </StackLayout>
            </ListView.itemTemplate>
        </ListView>
    </StackLayout>
</Page>
{% endraw %}
```

* `Page` ne peut contenir qu'un seul élément.

```css
{% raw %}
/* topstories.css */

.topbar {
    background-color: #FF6600;
    color: #000000;
    font-size: 10px;
    padding-left: 5px;
    padding-top: 3px;
    padding-bottom: 3px;
}
{% endraw %}
```

* La propriété `font-weight` n'est pas gérée.

Aperçu de la version [0.1.2](https://github.com/qpautrat/native-hacker-news/tree/0.1.2):

![HackerNews avec NativeScript + CSS](/assets/native-hacker-news3.png)

### 8.ViewModel

La documentation et les exemples sur **NativeScript** encouragent à utiliser le pattern *ViewModel* dans votre application.
Celà vous permet de séparer le code métier des intéractions avec la vue.
Si vous êtes développeur javascript (ce que je ne suis pas) vous devriez savoir de quoi je parle.

J'ai donc créé un nouveau fichier js:

```javascript
{% raw %}
// topstories-viewmodel.js

viewModel = {};

viewModel.topstories = [];

viewModel.loadStories = function() {
    this.topstories = [
        {
            'title': 'Nokia Agrees to Buy Alcatel-Lucent for $16.6B',
            'by': 'alphadevx',
            'score': 39
        },
        {
            'title': 'Boolean parameters to API functions considered harmful (2011)',
            'by': 'luu',
            'score': 69
        },
        {
            'title': '32-bit X86 Position Independent Code – It\'s That Bad',
            'by': 'cremno',
            'score': 63
        },
        {
            'title': 'Finding bugs in SQLite, the easy way',
            'by': 'robin_reala',
            'score': 275
        },
        {
            'title': 'New Mexico outlaws civil asset forfeiture',
            'by': 'hackercurious',
            'score': 78
        }
    ];
}

module.exports = viewModel;
{% endraw %}
```

La dernière ligne nous permet d'exposer notre view model en tant que module.

```javascript
{% raw %}
// topstories.js
var model = require("./topstories-viewmodel");

exports.pageLoaded = function(args) {
    var page = args.object;
    model.loadStories();
    page.bindingContext = model;
}
{% endraw %}
```

Le fichier `topstories.js` est simplifié.

[0.1.3](https://github.com/qpautrat/native-hacker-news/tree/0.1.3)

### 9.Pagination

De façon très classique nous allons afficher les éléments suivants une fois que l'utilisateur aura atteint le bas de la liste.
Le composant *ListView* déclenche un événement `loadMoreItems`:


```javascript
{% raw %}
// topstories.js

var model = require("./topstories-viewmodel");

exports.pageLoaded = function(args) {
    console.log("pageLoaded");
    var page = args.object;

    // L'API ne fournit qu'une liste d'id.
    model.getStoryIds();

    // Initialisation des premières stories
    model.loadNextStories();

    page.bindingContext = model;
};

exports.loadMoreItems = function(data) {
    console.log("loadMoreItems");

    // Récupérons les informations des prochaines stories à afficher
    model.loadNextStories();
};
{% endraw %}
```

```javascript
{% raw %}
// topstories-viewmodel.js

var observableArray = require("data/observable-array");

viewModel = {
    'storyIds': [],
    'topstories': new observableArray.ObservableArray(),
    'perPage': 20
};

viewModel.getStoryIds = function() {
    for (i = 0; i < 500; i++) {
        this.storyIds.push(i + 1);
    }
}

viewModel.loadStory = function(id) {
    return {
        'title': 'Story (' + id + ')',
        'by': 'foo',
        'score': 0
    };
}

viewModel.loadNextStories = function() {
    for (i = 0; i < this.perPage; i++) {
        this.topstories.push(this.loadStory(this.storyIds[this.topstories.length]));
    }
}

module.exports = viewModel;
{% endraw %}
```

* `topstories` n'est plus un array simple. Il s'agit maintenant d'un `observable-array`. Grâce à ce module notre vue va pouvoir automatiquement se mettre à jour en fonction du contenu de `topstories`.

[0.1.4](https://github.com/qpautrat/native-hacker-news/tree/0.1.4)


### 10.HTTP

Remplaçons maintenant notre liste statique de *topstories* par la <u>**vraie**</u> liste grâce à l'**API**.
Pour celà nous allons utiliser le composant [http](http://docs.nativescript.org/ApiReference/http/HOW-TO.html) du framework.

### Specifications

* Liste d'id des 500 topstories https://hacker-news.firebaseio.com/v0/topstories.json
* Chaque resource est un *item*
* Données d'un *item* https://hacker-news.firebaseio.com/v0/item/{id}.json

Modification du code JS du view model à cause de l'asynchrone

```javascript
{% raw %}
// topstories-viewmodel.js

var observableArray = require("data/observable-array");
var http = require('http');

viewModel = {
    'storyIds': [],
    'topstories': new observableArray.ObservableArray()
};

viewModel.getStoryIds = function() {
    var _this = this;
    http.getJSON("https://hacker-news.firebaseio.com/v0/topstories.json").then(function (json) {
        _this.storyIds = json;
        _this.loadNextStories(10);
    });
}

viewModel.loadNextStories = function(nb) {
    if (!nb) {
        nb = 1;
    }

    var _this = this;
    http.getJSON("https://hacker-news.firebaseio.com/v0/item/" + this.storyIds.shift() + ".json").then(function (json) {
        if (json) {
            _this.topstories.push(json);
            nb--;
            if (nb != 0) {
                _this.loadNextStories(nb);
            }
        }
    });
}

module.exports = viewModel;
{% endraw %}
```

```javascript
{% raw %}
// topstories.js

var model = require("./topstories-viewmodel");

exports.pageLoaded = function(args) {
    console.log("pageLoaded");
    var page = args.object;

    model.getStoryIds();
    model.loadNextStories();

    page.bindingContext = model;
};

exports.loadMoreItems = function(data) {
    console.log("loadMoreItems");
    model.loadNextStories(5);
};
{% endraw %}
```

Problème: pas de liste !
Comparaison entre 2 screens

| Statique | Dynamique |
|------|---|
| ![HackerNews avec NativeScript + CSS](/assets/native-hacker-news3.png) | ![HackerNews avec NativeScript + HTTP](/assets/native-hacker-news4.png) |

Ma première pensée fût de me dire que quelque chose clochait avec les requêtes http. Mon code ? Un bug dans le code du framework ?
J'ai compris que les requêtes HTTP étaient bonnes. Je récupérais les bon json. J'ajoutais ces données de la même façon qu'en statique. Ou est donc le problème ?
Je suis donc repartit d'un cleansheet. J'ai donc mit une listeview dans ma vue, et j'ai copié collé le code js. Et la magie ca fonctionne.
Je ne sais pas pourquoi mais il semblerait qu'il y ai un problème avec le layout et la liste view. Est -ce dû aux appels asynchrone ? Pas la moindre idée.

Du coup je susi obligé de supprimer une partie de mon template pour n'afficher que ma liste.

```xml
{% raw %}
// topstories.xml

<Page xmlns="http://www.nativescript.org/tns.xsd" loaded="pageLoaded">
    <ListView items="{{ topstories }}" loadMoreItems="loadMoreItems">
        <ListView.itemTemplate>
            <StackLayout cssClass="topstory">
                <Label text="{{ title }}" />
                <StackLayout>
                    <Label text="{{'By ' + by + ' - ' + score + ' points'}}" cssClass="author" />
                </StackLayout>
            </StackLayout>
        </ListView.itemTemplate>
    </ListView>
</Page>
{% endraw %}
```

J'arrive **enfin** à avoir une liste de topstories, que j'actualise à chaque fois que l'utilisateur arrive en bas.

[0.2.0](https://github.com/qpautrat/native-hacker-news/tree/0.2.0)

![HackerNews avec NativeScript + HTTP](/assets/native-hacker-news5.png)
