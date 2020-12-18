---
layout: post
title: Getting started with Electron
summary: "Developing cross platform desktop application using web technologies: Overview !"
tags:
 - Electron
 - JavaScript
 - NodeJS

image: /assets/electron-logo.png
---

Developed and maintened by Github, Electron is a framework helping you to build **cross platform desktop applications** (OSX, Windows, Linux) using **web technologies** HTML, CSS and JavaScript. It ships NodeJS as runtime and Chromium rendering engine. In addition to NodeJS, Electron provides a nice API to interact with the operating system.


As common thread I decided to build a [Digital Asset Management or DAM](https://cloudinary.com/dam-guide/dam). I will implement two basic feature:
- Import an Asset
- List imported Assets

## Create and start the application

I use [Electron Forge](https://www.electronforge.io) as _builder_ to initialize the project. [There are more](https://www.electronjs.org/docs/tutorial/boilerplates-and-clis#boilerplates-and-clis).

```bash
npx create-electron-app electron-dam
cd electron-dam
```

Forge provides *[Templates](https://www.electronforge.io/templates/typescript-+-webpack-template)* in order to start easily with tools like Webpack or TypeScript.

Then I run the app.

```bash
npm start
```

![Electron Hello World !](/assets/electron-hello-world.png)

I can see several things pretty cool here. My app looks like any other. There are a title, a menu, an visual interface with text and emoji. There is even a DevToolBar !

I tested this hello-world app on Ubuntu 20.04, Windows 10 and OSX Catalina, so far so good.

My first impression is really good. It's pretty simple to build and running a first small application.

## Bootstraping

I look what is inside the project.


```json
// package.json
{
    "main": "src/index.js",
}
```

As any NodeJS app, *main* is the entrypoint.


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

Forge provides [several useful commands](https://www.electronforge.io/cli#commands) to publish its application.


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

*[Makers](https://www.electronforge.io/config/makers)* make specific platform package.

*[Plugins](https://www.electronforge.io/config/plugins)* are used to extend Forge. For example it's possible to take advantage of Hot Module Reload.

_index.js_ is very well documented. Electron API is intuitive.

_index.html_ and _index.css_ define graphical rendering like any web app.


If I change HTML or CSS, there is no need to reboot the app. I can refresh as I could do in my web browser to see modifications.

Of course it's possible to add JavaScript:

```jsx
<!-- index.html -->
<script>
    document.getElementsByTagName('h1')[0].addEventListener("click", (event) => { 
	alert('Welcome !');
    });
</script>
```

![Electron Welcome !](/assets/electron-welcome.png)

However, if I want to change something in _index.js_ like increase window size:


```jsx
const mainWindow = new BrowserWindow({
  width: 1200,
  height: 800,
});
```

I have to run the app again.

⚠️ **index.js is executed by NodeJS when HTML and CSS files are interpreted by the browser. If I use web app comparison, I would say index.js act as the backend while HTML act as the frontend.**


## Import an Asset

In order to store Assets, I have to set a directory on user's computer.


### Initialize storage directory

At launch, I check if folder exists. If not, I create it. I chose destination folder but in the future I could let user choose.


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

*[app.getPath](https://www.electronjs.org/docs/all#appgetpathname)* offers multiple options. From a developer perspective it's handy because I don't need to worry about operating system details like how filesystem works.


After restarting my app, I check if there is a folder _electron-dam-assets_ in my Documents:

```bash
ls -al ~/Documents
...
drw-rw-r--  2 quentin quentin 4096 déc.   8 18:49 electron-dam-assets
```

### Add a menu

I provide to the user a new menu _Asset_. By default Electron initialize a basic menu.
I can override and extend the menu when the app is *[ready](https://www.electronjs.org/docs/all#event-ready)* with *[Menu](https://www.electronjs.org/docs/api/menu)* and *[MenuItem](https://www.electronjs.org/docs/api/menu-item)*. When user clicks on _Asset_, then _Import_, a _[dialog](https://www.electronjs.org/docs/api/dialog)_ will prompt to select on his/her computer which file he/she wants to import.

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

### Save the file

_importAsset_ copies selected file into Assets folder. 


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
I can check file has been copied:

![Electron asset saved !](/assets/electron-asset-saved.png)

## Display Assets

Next step is to show to the user all imported Assets on the main window.


```html
<!-- index.html -->
<div id="assets"></div>
```

```css
/* index.css */
#assets {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  grid-gap: 10px;
}

.asset {
  width: 200px;
  height: 200px;
  border: black solid 2px;
}
```

For each _[BrowserWindow](https://www.electronjs.org/docs/api/browser-window#new-browserwindowoptions)_ instance a **renderer process** is created. I add two options. First I authorize NodeJS integration into renderer process. Then I provide Assets folder path as process argument. I explain later how processes work in Electron.

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

From client side, I get Assets folder path from [_process'_ arguments](https://nodejs.org/api/process.html#process_process_argv). Then for each file I add a new element _img_ in DOM with _src_ attribute containing file path.


```javascript
// index.html
const path = require("path");
const fs = require("fs");

let assetsFolder = process.argv.slice(-1)[0];
let assets = document.getElementById('assets')
assets.innerHTML = '';
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

When I reload the app I should see all my imported Assets !

![Electron asset list](/assets/electron-asset-list.png)

With these two small features I gave you an overview on how build an app on Electron.
However there are, in my opinion, some concept that are very important to grasp.

## Processes

Electron has two types of process.

### MainProcess

There is only one main process. Running from NodeJS, _MainProcess_ will interact with the system using NodeJS API and Electron API. Like I said above, it's like our **backend** in a web application.

### Renderer process

For each _BrowserWindow_ instance Electron provides a renderer process. It means there can be as many renderer processes as there are windows. If _BrowserWindow_ instance is destroyed the same is true for renderer process. Because Electron uses Chromium to render view as web page, renderer process has access to browser's API. It's the **frontend part** of your web application.


There are more about processes in the [documentation](https://www.electronjs.org/docs/tutorial/quick-start#main-and-renderer-processes).

## Security

For convenience I made NodeJS available from renderer process possible.

⚠️ **Giving access to NodeJS from renderer process is handy but makes my application vulnerable**. For instance if I load remote content I expose my system to XSS injection attack.

**By default, [Electron disables NodeJS integration](https://www.electronjs.org/docs/tutorial/security#2-do-not-enable-nodejs-integration-for-remote-content) and follows [the least privilege principle](https://en.wikipedia.org/wiki/Principle_of_least_privilege).**

Official documentation provides [recommendations](https://www.electronjs.org/docs/tutorial/security#checklist-security-recommendations) about application security.

Having this in mind, my frontend **must be able to send messages**, queries and commands, to my backend. In a web application I typically do this by sending HTTP requests to backend API and waiting for response. Electron provides IPC system to do that.

## Inter-Processes Communication

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

## Performance

https://www.electronjs.org/docs/tutorial/performance

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