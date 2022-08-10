# Lucee, Docker and VSCode in 2022
August 2022

*I suggest you use the VSCode Markdown Preview for easiest use of this tutorial.*

This repo contains a tutorial and associated files to facilitate running [Lucee](https://www.lucee.org/) in [Docker](https://hub.docker.com/) on a [Digital Ocean](https://www.digitalocean.com/) Droplet virtual machine.

We will use the latest stable Lucee version (5.3 at the time of writing) with a test MySQL database served by a sample REST interface. In other words, a minimal setup for hosting your own Lucee Website and/or API server.

You can, of course, use any database you want but you will need to adjust the instructions below if you don't use MySQL.

**DISCLAIMER:** *As you will see in the Background section below, I am not an expert! I am just documenting what I did in the hope that someone else can make it all work in less time than it took me. Coming to grips with Docker, Virtual Machines, Linux and Lucee in one fell swoop brings a steep learning curve. If anyone can improve on this repo **please raise an issue and/or a PR**. I am hoping a Lucee expert might help fine tune this content and help to keep it up-to-date as Lucee and/or Docker evolve.*

These instructions are designed to work with OSX, Linux and Windows development environments.

Let me know if you think this tutorial is useful and accurate. If that is the case, it might be worth doing some videos to accompany it. There is a lot of content below but it is step-by-step so is hopefully intelligible.

## Background - the reason for this tutorial
Many years ago I created a minimal prototype webapp. It was written using [ExtJS](https://www.sencha.com/products/extjs/), wrapped in [NW.js](https://nwjs.io/) (similar to [Electron](https://www.electronjs.org/)) and until recently consumed JSON packets from a shared CF10 host. The prototype version of the webapp has been used for many years by a handful of happy organisations. The specifics of the app are not relevant for this documentation.

At the start of 2021 I decided to build a prototype frontend of the more complete version of the original webapp. I started from scratch using the [Quasar](https://quasar.dev/) framework which sits on [Vue](https://vuejs.org/). I am planning to completely rewrite the server side after I play with a number of possible options, which will probably include Lucee in whole or part.

I was hoping to leave the original webapp operational until the replacement was ready to go. However, a few weeks ago my long-standing CF10 ISP announced they were closing their doors. Bummer!

Since I needed to explore new server stack options for the new webapp I decided it was time to migrate from ACF to Lucee and self-host. I was also interested to learn Docker, VMs and the requisite Linux, etc.

I develop on a Windows 10 box and an old Macbook Pro (maxed out at Catalina). This tutorial is written so it will work on OSX, Linux and Windows platforms.

## Introduction
It took me way longer than I think it should have done to get my CF10 site migrated to Lucee and self-hosted on Digital Ocean. Much of that time was taken up with a very steep learning curve due to my lack of knowledge. It is also true that I found a lot of confusing and partial information - mostly because many of the "Lucee docker" articles are more than 5 years old, and a lot has changed since then. Also, there seems to be a preference to use Coldbox which remains confusing for me as a newbie. More on that later.

The migrating part was fairly uneventful. The rest was anything but.

So, this repo is designed to be a starting point for anyone wanting to learn how to deploy Lucee in Docker in 2022 and leveraging VSCode extensions, whether you are migrating a legacy site or just starting from scratch.
### Migration issues
Apart from the documented [ACF to Lucee migration issues](https://docs.lucee.org/guides/updating-lucee/migrate-from-acf.html), I also found these which might, or might not, be relevant to you.
1. The the `exception.rootcause` property doesn't exist in Lucee, you can use `exception.message` and `exception.detail` instead, e.g. in your `try/catch` blocks. Also see [Lucee Exceptions](https://docs.lucee.org/guides/cookbooks/Exeception-Output.html)
2. If you use the `cfspreadsheet` functions you need to install the cfspreadsheet extension in Lucee Admin.
3. SerializeJSON. I needed lowercase keys in my JSON. See this [forum post](https://dev.lucee.org/t/serializejson-with-lowercase-keys-and-override-jsonconverter-java/10619) if that is something you need to do.
4. Debugging: to see the `dump()` output, in your application.cfc set `this.bufferOutput = true;`

### Useful background videos
I found these videos helpful in getting both a big picture overview of the whole Docker and VM hosting thing, as well as some "in the weeds" tips.

1. [Learn Docker in 1 Hour](https://travis.media/learn-docker-in-one-hour-from/)
This is a beginner's guide to Docker with two examples: deploying a React app and a WordPress site to Digital Ocean.

2. [Deploying a Web App with Docker & Github Actions | Part 1](https://www.youtube.com/watch?v=JsOoUrII3EY)
[Deploying a Web App to Digital Ocean with Docker & Nginx | Part 2](https://www.youtube.com/watch?v=hf8wUUrGCgU)
These two videos cover an example of a  CI/CD pipeline: a sample Webapp, GitHub Actions, Docker, SSH, Nginx and Digital Ocean deployment. It is a great overview of what is possible with lots of helpful details.
***Note:** readers who suffer from **epilepsy** or **migranes** might want to take care with the Part 1 video - there was something wrong with the recording process and it flashes a lot! If you can, it is worth perservering.*

3. [Secrets From the Folks Who Make the Official Lucee CFML Docker Images, with Geoff Bowers](https://www.youtube.com/watch?v=mXZbCwaOOG0)
Finally, I found this one very interesting in terms of what can be done at scale, as well as a big picture approach to development and deployment.

### Other Lucee info
1. The [Official Lucee Docs](https://docs.lucee.org/index.html) and [forum](https://dev.lucee.org/), of course.
2. This GitBook [https://cfswarm.inleague.io/](https://cfswarm.inleague.io/) has a lot of useful info even though it is a bit out of date.
3. Another GitBook [https://rorylaitila.gitbooks.io/lucee/content/](https://rorylaitila.gitbooks.io/lucee/content/), not sure how up-to-date it is.

## Virtual Servers
If you are going to deploy a "production" server you obviously need to host it somewhere. In the BC days (Before Containers) we needed to pay a hosting company to manage the CF side of things on actual computers. To update the site we would FTP the cfm and cfc pages.

Now we can self-host on virtual servers. In this model, FTP still has some role, but mostly we will build a container locally with all the site's files then upload the whole container to our virtual server. That allows us to test the site locally then push exacty the same content to the cloud server and not have to think about which files changed.

I chose [Digital Ocean](https://www.digitalocean.com/) which I will explain when we deploy our site. For now, just know we will deploy to a Digital Ocean **Droplet** which is what Digital Ocean calls a virtual computer. In our case that will be an Ubuntu Linux cloud based virtual web server.

## Tutorial pages
1. Set up the local [Development](Development.md) environment and use the supplied demo app and REST API.
2. Set up the remote [Deployment](Deployment.md) environoment on Digital Ocean and deploy the app and REST API.
3. The [develop and deploy](DDCycle.md) cycle as well as some fine-tunes.

## Final comments
I would love feedback and suggestions via the repo Issues so this remains useful and up-to-date with current "best practice".

