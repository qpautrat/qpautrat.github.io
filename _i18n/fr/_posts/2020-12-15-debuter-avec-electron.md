---
layout: post
title: Débuter avec Electron
summary: Développer des applications de bureau multi plateformes en utilisant les technologies Web, tour d'horizon !
tags:
 - Electron
 - JavaScript
 - NodeJS

image: /assets/electron.svg
---

Développé et maintenu par Github, Electron est un framework qui permet de développer des **applications de bureau multi plateformes** (OSX, Windows, Linux) en **utilisant les technologies web**, HTML, CSS et JavaScript. Il embarque NodeJS pour le runtime et le moteur de rendu de Chromium pour le rendu graphique. Electron offre en plus une API qui sert d'abstraction pour interagir avec le système d'exploitation. 


Comme fil rouge j'ai décidé de développer un [Digital Asset Management ou DAM](https://cloudinary.com/dam-guide/dam). Je vais développer deux fonctionnalités très simples. Importer un Asset dans l'application et visualiser les Assets déjà importés.

## Créer et lancer l'application

J'utilise le _builder_ [Electron Forge](https://www.electronforge.io) pour créer le projet. [Il en existe d'autres](https://www.electronjs.org/docs/tutorial/boilerplates-and-clis#boilerplates-and-clis).

```bash
npx create-electron-app electron-dam
cd electron-dam
```

Forge met à disposition des *[Templates](https://www.electronforge.io/templates/typescript-+-webpack-template)* afin de commencer avec plus d'outils comme par exemple Webpack et TypeScript.

Je lance l'application:

```bash
npm start
```

![Electron Hello World !](/assets/electron-hello-world.png)

Je peux voir plusieurs choses assez cool. Mon application ressemble à n'importe quelle autre: un titre, un menu, le rendu visuel de ma première page web et même une DevToolBar !

J'ai testé sur Ubuntu 20.04, Windows 10, OSX Catalina.

Ma première impression est très bonne. C'est très simple d'avoir un premier déliverable.

## Bootstraping

Je regarde ce que contient le projet.

```json
// package.json
{
    "main": "src/index.js",
}
```

Comme toute application NodeJS, *main* spécifie le point d'entrée de l'application.


```json
// package.json
{
    "scripts": {
        "start": "electron-forge start",
        "package": "electron-forge package",
        "make": "electron-forge make",
        "publish": "electron-forge publish",
        "lint": "echo \"No linting configured\""
    },
    ...
}
```

Forge met à disposition [plusieurs commandes](https://www.electronforge.io/cli#commands) utiles pour développer et publier son application. 

```json
// package.json
{
    "config": {
        "forge": {
            "makers": [
                {
	            "name": "@electron-forge/maker-squirrel",
	            "config": {
		        "name": "electron_dam"
	            }
	        },
	        {
	            "name": "@electron-forge/maker-zip",
	            "platforms": [
	                "darwin"
	            ]
	        },
	        {
	            "name": "@electron-forge/maker-deb",
	            "config": {}
	        },
	        {
	            "name": "@electron-forge/maker-rpm",
	            "config": {}
	        }
            ]
        }
    }
}
```

Forge propose par défaut plusieurs *[Makers](https://www.electronforge.io/config/makers)* qui permettent de créer des distribuables spécifiques à chaque platforme.

Il y a aussi une section *[Plugins](https://www.electronforge.io/config/plugins)*, qui permet d'étendre les fonctionnalités de Forge. Par exemple il est possible de profiter de Webpack avec le Hot Module Reload.

Le fichier _index.js_ est très bien commenté et l'API d'Electron est simple à appréhender. J'ai très rapidement compris le contenu du fichier.

Les fichiers _index.html_ et _index.css_ contiennent la partie visuelle de mon application comme une application web classique.

Si je modifie le HTML ou le CSS je ne suis pas obligé de relancer l'application. Je peux rafraichir la page avec Ctrl+R pour voir les modifications.

Il est possible d'ajouter du Javascript:

```jsx
<!-- index.html -->
<script>
    document.getElementsByTagName('h1')[0].addEventListener("click", (event) => { 
	alert('Welcome !');
    });
</script>
```

![Electron Welcome !](/assets/electron-welcome.png)

Cependant si je veux changer par exemple la taille de ma fenêtre:

```jsx
const mainWindow = new BrowserWindow({
  width: 1200,
  height: 800,
});
```

Je suis obligé de relancer mon application.

⚠️ **Le fichier index.js est exécuté par NodeJS alors que les fichiers html et css sont eux interprétés par le navigateur. Le fichier index.js fait office de Backend tandis que le html fait office de Frontend.** 

## Importer un Asset

Afin de stocker les Assets et être en mesure de jouer avec je dois d'abord définir un répertoire de référence sur l'ordinateur de l'utilisateur.

### Initialiser le répertoire de stockage

Au lancement de l'application je vais vérifier si le dossier existe. Si non je vais le créer. J'ai décidé de choisir arbitrairement le dossier de destination. Dans le futur je pourrais laisser le choix à l'utilisateur.

```jsx
// index.js - Main process
const { app } = require('electron');
const path = require('path');
const fs = require("fs");

const assetsFolder = path.join(
  app.getPath('documents'), '/electron-dam-assets'
);

try {
  if (!fs.existsSync(assetsFolder)) {
    fs.mkdirSync(assetsFolder);
  }
} catch (err) {
  console.error(err);
}
```

La méthode *[app.getPath](https://www.electronjs.org/docs/all#appgetpathname)* offre plusieurs options possibles. D'un point de vue développeur elle permet de s'abstraire de l'OS sur lequel l'application est exécutée.

Après avoir relancer mon application, je vérifie qu'il existe maintenant un dossier _electron-dam-assets_ dans mes Documents:

```bash
ls -al ~/Documents
```

### Ajouter un menu

Comme intéraction je propose à l'utilisateur un menu d'application supplémentaire _Asset_. Par défaut Electron initialise un menu. Lorsque l'application est *[ready](https://www.electronjs.org/docs/all#event-ready)* il est possible de le modifier via l'API *[Menu](https://www.electronjs.org/docs/api/menu)* et *[MenuItem](https://www.electronjs.org/docs/api/menu-item)*. Lorsque l'utilisateur va cliquer sur _Import_ l'application va lui ouvrir une fenêtre pour sélectionner un fichier sur son ordinateur. Tout comme *Menu* et *MenuItem*, l'objet *[dialog](https://www.electronjs.org/docs/api/dialog)* permet de faire cela sans se soucier de l'OS.

```javascript
// index.js
import { Menu, MenuItem, dialog } from 'electron';

app.on('ready', () => {
  let menu = Menu.getApplicationMenu();
  menu.append(new MenuItem({
    'label': 'Asset',
    'submenu': [{ 
      'label': 'Import',
      'click': () => {
    	  let filepaths = dialog.showOpenDialogSync({ 
          properties: ['openFile'] 
        });
        if (filepaths === undefined) {
          return;
        }
      }
    }]
  }));
  Menu.setApplicationMenu(menu);
}
```
![Electron Menu](/assets/electron-menu.png)

![Electron dialog](/assets/electron-dialog.png)

### Sauvegarder le fichier

J'ajoute une fonction _importAsset_ pour copier le fichier sélectionné par l'utilisateur dans le dossier d'Assets.

```javascript
'click': () => {
  ...
  importAsset(filepaths.shift());
}

const importAsset = (filepath) => {
  let filename = path.basename(filepath);
  let newFilepath = path.join(assetsFolder, filename);
  fs.copyFile(filepath, newFilepath, (err) => {
    if (err) throw err;
  })
}
```
En testant la fonctionnalité je m'assure que l'Asset a bien été importé:

![Electron asset saved !](/assets/electron-asset-saved.png)

## Afficher la liste des Assets

La prochaine étape est maintenant d'afficher les Assets importés sur la fenêtre principale.

```html
<!-- index.html -->
<div id="assets"></div>
```

```css
// index.css
#assets {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  grid-gap: 10px;
}

.asset {
  background-color: tomato;
  width: 200px;
  height: 200px;
  border: black solid 2px;
}
```

Pour chaque instance de _[BrowserWindow](https://www.electronjs.org/docs/api/browser-window#new-browserwindowoptions)_ est associé un **processus de rendu (renderer proces)**. J'ajoute deux options à la création de ma fenêtre principale. Je vais d'abord autorisé l'integration de NodeJS dans ce processus de rendu et je lui passe le chemin vers le dossier d'assets. C'est une des façons de communiquer entre le **processus principal (main process)** et un processus de rendu. J'explique dans le chapitre suivant la notion de processus dans Electron qui est très importante.

```javascript
// index.js
const mainWindow = new BrowserWindow({
	...
  webPreferences: {
    nodeIntegration: true,
    additionalArguments: [assetsFolder]
  }
});
```

Dans mon script coté client je vais récupérer le chemin du dossier de mes Assets. Ensuite pour chaque fichier dans ce dossier je vais ajouter un nouvel élément *<img>* dans mon HTML avec pour attribut _src_ le chemin vers le fichier.

```javascript
// index.html
const path = require("path");
const fs = require("fs");

let assets = document.getElementById('assets')
assets.innerHTML = '';
let assetsFolder = process.argv.slice(-1)[0]
fs.readdir(assetsFolder, function (err, files) {
    if (err) {
        return console.log('Unable to scan directory: ' + err);
    } 
    files.forEach(function (file) {
        let img = document.createElement("img");
        img.src = path.resolve(assetsFolder, file);
        img.className = "asset";
        assets.appendChild(img);
    });
});
```

Si je relance l'application je devrais être en mesure de voir les Assets que j'ai déjà importé !

![Electron asset list](/assets/electron-asset-list.png)

J'ai terminé l'implémentation des deux fonctionnalités. Je vais maintenant expliquer quelques concepts que j'estime extrêmement important à saisir.

## Le système de Processus

Electron a deux types de processus.

### MainProcess

Il n'y a qu'un seul processus principal. Le *MainProcess* va servir principalement à créer des pages web à l'aide de _BrowserWindow_ et à interagir avec le système grâce à NodeJS et à l'API d'Electron. C'est l'idée de **Backend** auquel je faisais référence un peu plus tôt.

### Renderer process

Pour chaque instance de *BrowserWindow* (donc pour chaque page web) Electron associe un processus de rendu *RendererProcess*. Il peut donc y avoir autant de processus de rendu que de page web. Quand l'instance de *BrowserWindow* est détruite, le processus de rendu est lui aussi détruit. Le processus de rendu a pour but d'intéragir avec l'utilisateur. L'idée est de capter une action et de fournir un visuel adéquat. Le _RendererProcess_ a accès aux API web classiques.

[Plus d'informations sur la documentation.](https://www.electronjs.org/docs/tutorial/quick-start#main-and-renderer-processes)

## Sécurité

J'ai rendu possible l'accès à NodeJS depuis le processus de rendu pour faciliter l'implémentation.

⚠️ **Donner l'accès à NodeJS au processus de rendu est très pratique mais rend mon application totalement vulnérable**. Si par exemple je charge du contenu distant (ce qui arrive souvent) j'expose mon système à des attaques de type injection XSS.

**Par défaut, [Electron désactive l'intégration de NodeJS](https://www.electronjs.org/docs/tutorial/security#2-do-not-enable-nodejs-integration-for-remote-content) dans le processus de rendu et respecte [le principe du moindre privilège](https://en.wikipedia.org/wiki/Principle_of_least_privilege).**

La documentation officielle fournit une [liste de recommandations](https://www.electronjs.org/docs/tutorial/security#checklist-security-recommendations) à propos de la sécurité des applications.

Si il est très déconseillé de laisser la possibilité au processus de rendu d'accéder au système, comment notre **Frontend** va t'il pouvoir communiquer avec notre **Backend** comme on pourrait le faire en Web avec des appels HTTP ?

## IPC (Inter-Processes Communication)

Pour que les deux processus communiquent, l'API d'Electron met à disposition deux modules *IpcMain* et *IpcRenderer.*

```javascript
ipcRenderer.send(channel, data); // Send data to main process
ipcRenderer.on(channel, (event, ...args) => func(...args)); // Receive data from main process

ipcMain.on(channel, (event, ...args) => func(...args)); // Receive data from a renderer process
BrowserWindow.webContents.send(channel, data); //Send data to a specific renderer process
```

Puisque *ipcRenderer* fait partie de l'API Electron, il n'est pas possible de l'utiliser depuis le processus de rendu. Il manque une dernière étape que les développeurs d'Electron ont implémenté sous forme de *preloading*.

Lorsque l'on créé une nouvelle page web on peut exécuter un script de *preload*:

```javascript
// index.js
const mainWindow = new BrowserWindow({
    ...
    webPreferences: {
        preload: path.join(__dirname, "preload.js")
    }
  });
```

Ce script a accès à NodeJS et va nous servir de passerelle entre le processus principal et celui de rendu de la fenêtre courante. Le but de ce script est d'implémenter le principe de moindre privilège. On va pouvoir étendre les capacités du processus de rendu avec ce qui est seulement nécessaire.

```javascript
// preload.js
const { contextBridge,ipcRenderer } = require('electron');
contextBridge.exposeInMainWorld(
    "api", {
        send: (channel, data) => {
            ipcRenderer.send(channel, data);
        },
        receive: (channel, func) => {
            ipcRenderer.on(channel, (event, ...args) => func(...args));
        }
    }
);
```

Grâce à cela notre processus de rendu a maintenant accès à une nouvelle interface _api_.

```javascript
//index.html
window.api.receive("channel", (data) => {
    console.log(`Received ${data} from main process`);
});
window.api.send("channel", "some data");
```

Pour comprendre un peu mieux le sujet sur la sécurité, la communication inter-processus, le principe de moindre responsabilité ainsi que le preloading il y a un [excellent commentaire](https://github.com/electron/electron/issues/9920#issuecomment-575839738) sur le sujet et un [fichier Markdown](https://github.com/reZach/secure-electron-template/blob/master/docs/secureapps.md#building-a-secure-app).

## Tests & Debug

Il existe plusieurs moyens de tester et debugger son application Electron. Je survole le sujet.

- [Chrome DevTools](https://developers.google.com/web/tools/chrome-devtools) pour analyser son rendu, comme sur un site web classique
- [Debugger avec VSCode](https://www.electronjs.org/docs/tutorial/debugging-vscode)
- [Tests unitaires avec Jest](https://jestjs.io/)
- [Tests d'intégration](https://www.electronjs.org/docs/tutorial/using-selenium-and-webdriver)

## Packager et publier son application

Electron Forge fournit plusieurs utilitaires pour aider à partager son application.

- [https://www.electronforge.io/config/makers](https://www.electronforge.io/config/makers) 
- [https://www.electronforge.io/config/publishers](https://www.electronforge.io/config/publishers)

## Aller plus loin

La [documentation officielle](https://www.electronjs.org/docs) d'Electron est **très complète**. Toute l'API du framework est disponible. La [section tutoriel](https://www.electronjs.org/docs/tutorial) couvrira la plupart des besoins en terme de développement.

Voici une liste d'applications développées avec Electron que j'utilise au quotidien sur différents systèmes et qui fonctionnent bien:

- Slack
- Discord
- Notion
- VSCode
- WhatsApp
- Twitch
- Figma
- ...

## Conclusion

L'initialisation d'une nouvelle application et la voir fonctionner en seulement deux commandes est très appréciable.

**La promesse du multi platformes à l'air vraiment d'être tenue**. Je pense qu'il y a forcément des exceptions mais l'impression que j'en ai jusque là est bonne.

L'expérience développeur est agréable aussi. La maturité grandissante de l'écosystème JavaScript aide en ce sens. L'utilisation de TypeScript ou Webpack par exemple est un gros plus. Il est possible d'utiliser des frameworks front tel que React ou Vue si besoin.

Un développeur JavaScript n'aura absolument **aucun mal à prendre en main** le framework.

Il y a quand même quelques notions difficiles à appréhender. Malgré que l'on retrouve vite nos habitudes de développeur web, **l'environnement est différent et impose des contraintes différentes**.

Globalement l'expérience est très positive et jusque là je ne vois aucune raison de ne pas utiliser Electron comme framework de développement d'application de bureau !