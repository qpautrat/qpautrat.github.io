---
layout: post
title: Install Ubuntu on MacBookPro
summary: Install Ubuntu on MacBookPro, is it worth it ? How to do it ?
tags:
 - Ubuntu
 - OSX
 - Operating System
 - Docker
image: /assets/logo-ubuntu.png
---

After more than 5 years I couldn't stand the disastrous performance of `Docker4Mac` anymore. Running a monolith that is about 10 years old is a real pain in the ass.

`Docker` is not the only one to blame here. Tight coupling between numerous systems does not help either. Nevertheless, I saw how slow my laptop was even on very small projects.

Moreover I used my machine very intensively and I felt it at the end of the race. It was time to give it a second wind.


*Thanks [@kipit](https://twitter.com/rcasagraude) for his precious help !*

## Hardware

- MacBookPro Mi 2015
- CPU Intel(R) Core(TM) i5-5287U CPU @ 2.90GHz
- RAM 2 X DDR3 Synchrone 1867 MHz
- Webcam Broadcom 720p FaceTime HD Camera
- WiFi Broadcom BCM43602 802.11ac Wireless LAN
- SATA APPLE SSD SM0256

## 1/ Data backup

With a fresh new Operating System install,  I plan to overwrite everything already on my disk so I take care to keep everything that seems important to me.

Personal and professional documents, but also configuration files. For example my `.zshrc` or `gitconfig.` file.

## 2/ Having OSX just in case

The installation of Ubuntu may fail or I may be disappointed with the new OS.
I should be able to go back and reinstall Apple's Operating System.
[The procedure is well explained](https://support.apple.com/en-us/HT201372).

## 3/ Download Ubuntu

Last LTS version is available on [Ubuntu's website](https://ubuntu.com/download/desktop).
You could have download speed issue. If it's the case you can try [mirrors](https://launchpad.net/ubuntu/+cdmirrors).


## 4/ Turning a USB flash drive into a bootable image

I used [Balena Etcher](https://www.balena.io/etcher/) which is a small tool very simple to use.
You select the file (on your disk or from HTTP) then the USB flash drive.


*I encountered a small problem during this stage. The tool told me that the disc I wanted to write to was busy. I had to use the following command to solve the problem:*

```bash
diskutil umount /path/to/your/disk
```

## 5/ Install Ubuntu

I reboot the Mac while holding down the `Option (or alt) key.` The `boot` menu appears and I can select my USB flash drive containing `Ubuntu`.

The installation is very simple. The wizard guides us through the essential steps.

The Mac keyboard is recognized without any problem and is available in the list of available keyboards.

WiFi works very well too. I had no problems connecting to a wireless network with an excellent download speed (\~100Mbits/s).

It is also possible to encrypt your disk.


## 6/ Docker & docker-compose

To install `docker` I didn't have any particular worries. [Everything is very well explained](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository).



⚠️ Take care to read the paragraph at the end of the installation on the management of rights and groups. A `group` `docker` is added but there is nobody in it. This means that only the `root` user can execute `docker` commands. If you want to use `docker` without `sudo`, [follow this documentation](https://docs.docker.com/engine/install/linux-postinstall/).

To install `docker-compose` I used `apt`:

```bash
sudo apt install docker-compose
```

## 7/ Python

To make the monolith working on my machine I need `python` (2!) and `fabric`.

To avoid conflicts between `python` versions I use [pyenv](https://github.com/pyenv/pyenv#the-automatic-installer). I suggest you to read whole `README`.

Once `pyenv` is installed, I can install whatever `python` version I want:

```bash
pyenv install 2.7.18
```

Then `fabric`:

```bash
$(pyenv root)/versions/2.7.18/bin/pip install fabric==1.14.0
```

I set an `alias` to make `fabric` easier to use:

```bash
#.zshrc
alias fab="$(pyenv root)/versions/2.7.18/bin/fab"
```

## 8/ Productivity

On `Ubuntu Software`, which is the equivalent of the `App Store` on `Ubuntu`, I was able to install `Discord`, `Slack`, `Todoist`, `Miro` and `PHPStorm`. I didn't encounter any particular problem. The applications seem to work well. I didn't find `Notion` but their webapp works very well on `Firefox`.

## 9/ AirPods

I was able to connect my `AirPods` with my machine with `Bluetooth`. However the sound quality is not as good. Moreover I have the impression that the distance allowed between the laptop and the airpods to continue to function is much less than on OSX. 

## 10/ Webcam

Making the webcam work was ultimately the biggest worry. There are no official drivers available in `Ubuntu`. However someone has developed [a driver on github](https://github.com/patjak/bcwc_pcie/wiki/Get-Started). [There is a summry of the procedure](https://askubuntu.com/a/1215628).