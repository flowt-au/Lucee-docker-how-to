# Development stage
Getting set up with VSCode, Docker, and developing our minimal Lucee application and REST API.

For OSX, Linux and Windows development environments.

## Contents
1. [Docker and Docker Hub](#docker-and-docker-hub)
   1. [Windows WSL](#for-windows-users)
   2. [Docker Desktop](#docker-desktop)
2. [Lucee in Docker intro](#lucee-in-docker)
   1. [Not using Coldbox](#coldbox)
   2. [VSCode extensions](#set-up-some-vscode-extensions)
3. [Lucee + MySQL in Docker](#lucee--mysql-in-docker)
   1. [Persisting data - docker volumes](#persisting-user-data---a-note-about-docker-volumes)
   2. [Dockerfiles](#dockerfiles)
   3. [Docker compose files](#docker-compose-files)
      1. [Lucee Settings](#lucee-settings)
      2. [.env file](#env-file)
      3. [Port settings](#port-settings)
      4. [Lucee admin password](#passwordtxt)
      5. [Your CFML / CFC files](#your-cfml--cfc-files)
4. [Build and compose our containers](#build-and-compose-our-containers)
5. [Local development](#local-development)
   1. [The default Lucee application](#the-default-lucee-application)
   2. [The Lucee Admin pages](#lucee-admin-pages)
   3. [Add the test database](#add-the-test-database)
   4. [The "world" Lucee REST API server](#our-world-lucee-rest-api-server)


## Setting up VSCode for Docker
VSCode has some helpful extensions for working with Docker.

#### For Windows users:
**This is important so your development performance is not impaired.**

*OSX and Linux users can skip this section.*

As you have learned, a Docker container most often contains a mini Linux system.

Now, without going into too much detail, running the Docker Desktop app on Windows, and its associated Docker CLI, works fine as far as it goes **except some things can be really slow**. This relates to Docker volumes (discussed later) and has to do with the different file systems inside the Linux container and on your Windows host computer. The performance impact depends upon what you are doing but any database activity will be much slower. Some of my complex queries simply timed out! Not good.

To get around that possible performance hit on Windows 10 and 11 hosts, we use **WSL** - Windows Subsystem for Linux. It should really be called Linux Subsystem for Windows because basically it is a kind of Linux virtual machine running on your Windows computer. In Windows 10 you get just the Linux CLI, on Windows 11 you can also run a Linux GUI. Switching to WSL made a dramatic difference to my app's performance while developing.

Once you have WSL and the VSCode extensions described below you will be developing Linux containers via the Windows Docker Desktop and using your Windows version of VSCode to do that. You get the best of both worlds - using your normal Windows tools but creating containers within a Linux environment. This also means you can have the same operating system for your local container *development* and your remote container *deployment*. You can be more confident that if the containers work locally they will work remotely, since they are the same containers running on the same host OS.

[VSCode WSL overview and installation instructions.](https://code.visualstudio.com/docs/remote/wsl)

### Set up some VSCode extensions

For OSX, Linux and Windows.

You are, of course, free to use whichever code editor you wish. However, VSCode has some very handy extensions for managing Docker, remote sites, and for Windows users, WSL. This tutorial assumes you are using VSCode.

For Windows users: [Microsoft VSCode WSL Tutorial](https://code.visualstudio.com/docs/remote/wsl-tutorial).

***Note:** For WSL users, the word "remote" also applies to your local Windows WSL Ubuntu virtual machine because from VSCode's perspective to access it on your Windows machine you "remote in" to the Linux machine.*

For Windows, OSX and Linux users, install all the relevant extensions in one go using the [VSCode Remote Extension Pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack). For OSX and Linux it just skips the WSL bits.

You will also find the [Docker in Visual Studio Code](https://code.visualstudio.com/docs/containers/overview) extension invaluable. Apart from the other things it does, it allows you to navigate *into* the container's files via VSCode and start a terminal inside the container, even for the Droplet (remote) containers. Very useful.

### Using VSCode
You are probably already reading this file via a VSCode window, in which case you have probably cloned the repo to be able to be doing that.

#### For OSX and Linux users
Assuming you *have* cloned the repo, you are ready to skip down to the [next section](#docker-and-docker-hub). If you have not yet cloned the repo and opened it in VSCode, do that now.

#### For Windows users
A few more Windows-only things...

Assuming you *have* cloned the repo, and if you just set up WSL for the first time, you are most likely in Windows VSCode looking at this repo in the *Windows* file system. What we want to do now is open a new VSCode workspace in the Linux (WSL) environment and clone the repo there. We do that so you can develop inside the Linux environment.

**Note:** if you are new to Linux remember that Linux commands and filenames are **case sensitive**.

1. Assuming you installed the Ubuntu distro for WSL, open Ubuntu from the Windows Start Menu. You should then be logged into the Linux shell in your user folder.
2. Create a folder in there named (say) `projects`
   >`mkdir projects`
   >`cd projects`
3. Clone this repo there:
   >`git clone https://github.com/flowt-au/Lucee-docker-howto.git`
4. Enter that folder
   >`cd Lucee-docker-howto`
5. Start VSCode in that folder
   >`code .`
6. Reply Yes or No about the supplied Workspace, your choice. But if you say No, save the window as a Workspace to make it easier to open in the future.

Note: You are still running VSCode in Windows, but it is "remoting" into the Linux sub system.

Some notes:
1. Once this repo has a VSCode workspace you can re-open this workspace via your normal Windows version of VSCode and it will re-establish the "remote session" - it will open just like any other VSCode workspace.
2. If you open a Terminal in that workspace, you are inside your Linux environment, so Linux CLI commands like `ls` (and all your docker commands) can be used there.
3. A quirk of this setup is the links in the Markdown Preview don't seem to work in the WSL instance. So, if you were following along via Markdown Preview in the non-WSL VSCode window, it is probably best to keep using that instance for reading, and use this Linux instance for the development steps.
You can tell which is which because in the WSL instance the green Remote button in the lower left corner of VSCode will say something like `WSL:Ubuntu-20.04` (depending on which Linux distro you chose when you installed WSL).

##### Tip: Copying and Pasting from Windows into the Linux bash command line.
Copying from the Windows clipboard into the Linux bash shell using Ctrl+V wont work. You just get `^V`. So, to Paste, right click the Ubuntu bash shell window title bar, then select `Edit / Paste`. In addition, from that same menu you can also select `Properties` and enable the `Use Ctrl+Shift+C/V as Copy/Paste` box. Then you can Paste into the bash command line using `Ctrl+Shift+V`.

Having said that, if you open a Terminal in your WSL VSCode instance you can use `Ctrl+V` as you normally would.

## Docker and Docker Hub
*For OSX, Linux and Windows... at this point you should have a VSCode workspace open for this repo before continuing.*

I won't explain what Docker is here. See the video links in the [Readme](README.md).

**Note:** if you are new to Linux remember that Linux commands and filenames are **case sensitive**.

In this tutorial we will run Lucee in one container and MySQL in another. They will communicate with each other on a local network so you can have a MySQL datasource defined in your Lucee instance that interacts with the MySQL instance in the other container.

### Docker Hub

You will need a [Docker Hub](https://hub.docker.com/) account. Docker Hub is similar to GitHub in that it is a cloud based location for your Docker images, as opposed to a cloud based location for your source code files.

Instead of pushing your Lucee application image directly to your virtual machine (e.g. your Droplet), you push it to your Docker Hub account, then pull it into your virtual machine (Droplet) via the `docker-compose` command run on the Droplet. More on that in the [Deployment](Deployment.md) page.

If you don't have a [Docker Hub](https://hub.docker.com/) account, get one now.

### Docker Desktop
Now you are ready to install the Docker Desktop app.

**Reminder for Windows users:** It is recommended to install WSL as detailed above *before* you install the Docker Desktop, so it can detect WSL and allow you to set it up at installation time.

[Install Docker Desktop for your OS](https://docs.docker.com/desktop/)

Once the installation is complete, run the *Getting Started* tutorial that will appear inside Docker Hub to get familiar with the interface and where everything is.

## Lucee in Docker
The idea for this tutorial is to run Lucee in a Docker container and enable it to communicate with a MySQL container as a DataSource. All the Lucee code to achieve that is in this repo's `src` folder. The supplied xml files in `LuceeSettings` have the DataSource configured.

The video [Getting Started with Lucee in Docker](https://www.youtube.com/watch?v=uDRPTH1xq_8) is a really helpful starting point and is worth watching. However, it only covers a Lucee container, nothing about docker compose, or a database container and datasources.

### Coldbox
In many forum and blog posts about running Lucee in Docker people recommend using Coldbox. While that all looks interesting, as a complete newbie adding another layer of complexity to abstact away some of the detail was counter productive to my learning about the technology. Even after getting my project working I am still not clear what the advantage of Coldbox for Lucee is, apart from an enhanced method of re-deploying a site (I think).
*I would love a PR from someone to insert in here that explains the purpose of Coldbox as it relates to Lucee.*

## Lucee + MySQL in Docker
FYI: We will be basing our custom Lucee image and container on an [official Lucee image](https://hub.docker.com/r/lucee/lucee) found on Docker Hub.

### Persisting your User Data - a note about docker volumes
You will have seen that in order to persist any user data (e.g. the MySQL database files, your Lucee Admin Settings, or user-uploaded images, etc), you need to use a Docker "volume" which maps a folder on the host to a folder inside the container. When you stop a container you lose all the data inside it, so a volume allows you to persist the data because it is saved on the host's file system. I mention it now FYI and it becomes relevant a bit later.

### Dockerfiles

Most tutorials on Docker focus on using the default `Dockerfile` - a file that Docker uses to define how to build your Docker images and containers.

However, having just one Docker file is a bit limiting because as you will see your development build and deployment build will be a bit different.

So, in this tutorial we have two Dockerfiles: `Dockerfile-local` and `Dockerfile-droplet`. The reason is that for local development on Lucee you want to have the Lucee Admin Pages avaialable for the Server and Web contexts, but for the Droplet / deployment build, for security reasons, you probably do not want to allow that.

*Note 1: I am using "-droplet" in the name to make clear it is the container we will deploy in our Digital Ocean Droplet.*

*Note 2: If you are confused, like I was, about why there are two admin interfaces for Lucee (Server and Web), this video by Mark Drew explains the difference: [What are Lucee contexts?](https://www.youtube.com/watch?v=nkG0v5IqhCg). Understanding this helps understand some of the config in our docker files.*

The two Docker files have explanatory comments and examples. Open them up side-by-side to compare the differences.

### Docker Compose files
Now, as you will have seen in the Docker tutorials we *can* build just the Lucee image individually. In reality, you will probably have related images that Lucee needs to talk to (eg MySQL / MariaDB) in which case you need to "compose" them so they can talk to each other. You will have seen examples of `docker-compose` in the other videos.

***Reminder 1:** When you build, you are taking the `image` file (the blueprint, e.g. `lucee/lucee:latest` or `mysql:latest`) and creating a `container` file from that blueprint (the "executable" with your custom configuration).*

***Reminder 2:** Docker compose does NOT create a new single "file" containing those containers (eg Lucee + MySQL). What it does is build a separate container for each image mentioned then builds a local network so those containers can communicate with each other. If you don't specify a network in your compose file Docker will build a default network, which is often all you will need. To keep this beginners tutorial simple, we use the default network. See: [Docker networking](https://docs.docker.com/network/) if you are interested in more detail.*

Again, we have two versions of the compose files to cater for our differing development and production needs: `docker-compose-local.yml` and `docker-compose-droplet.yml`. Open them up and compare them.

#### Lucee Settings
When you use the Lucee Admin pages to (say) add a DataSource, or set a Mapping, those changes are saved **inside the container** in either `/opt/lucee/server/lucee-server/context/lucee-server.xml` or `/opt/lucee/web/lucee-web.xml.cfm` according to the context page you used. That is fine until you delete the container, in which case your settings will be lost.

As mentioned above, we need to persist our Lucee Admin settings to the host so they are not lost when the container is removed. We need a way to get those settings back into the Lucee container when it is rebuilt.

There are two ways to achieve that and the files have examples of both:
1. you can COPY them in when the container is built in either the `Dockerfile` or the `Docker compose.yml` file; or
2. you can map a folder on your host machine to a folder inside the container (called a `volume`) in the compose.yml file.

**Development mode:** The easiest way to develop, change and validate the Lucee Admin settings is via the Lucee Admin pages. For example, when you want to define a DataSource, set your regional settings, or change your debug settings. By "mapping" the folders containing the Lucee setting xml files inside the container to a folder on your development machine, your settings are persisted as you go and will survive the container restarts. *(Definition: by "mapping" I don't mean the internal Lucee Folder Mappings, I mean the Docker compose volume mappings)*.

The volume mapping in `docker-compose-local.yml` will get the settings back into Lucee if there is anything in these files:
`LuceeSettings/lucee-server.xml` and `LuceeSettings/lucee-web.xml.cfm`

For this tutorial the xml files in `/src/LuceeSettings` have pre-defined some Lucee Admin Settings which we will discuss below. As you use the Admin pages to make your own settings those files will be updated and hence persist your admin changes on your development machine.

***Note 1:** If, after you have built a Lucee app, you want to use the admin settings for another project, you can apply those settings by copying those two files to your new project and "volume map" them as we do here.*

***Note 2:** If later you want to start Lucee with a default installation, simple empty those two files (but dont delete them) and rebuild (not just restart) the container. The xml files on your development host machine will then be populated with the default Lucee Admin settings.*

**Deployment mode:** As I have mentioned, for security reasons in this mode you do NOT want to have the Lucee Admin pages available via the browser. But you still need to apply your custom settings to the default Lucee image file when you build the container that you will deploy. You need your DataSources, regional settings, etc, to be defined. Generally, you can also define these in your `application.cfc` file, but sometimes using the Lucee Admin xml settings files is more convenient.

You *can* use a volume mount then FTP the settings to your remote host volume. The "advantage" of doing that is you can "manually" change the settings xml files without rebuilding the deployed Lucee container, you only need to restart it. However, normally you would not use a volume mount and instead just COPY the files in, as we do in the `docker-compose-droplet.yml` file.

So, the pattern is to use the Lucee Admin pages to make your settings changes while in development mode, which persists them to the `LuceeSettings` folder; copy the `LuceeSettings` folder to the remote virtual server; then copy the files from that folder into the deployed container via the remote docker compose.

### .env file
You will notice we have the database password, database name and port numbers mentioned by token in the compose files. The values are in the `.env` file that docker compose will look for by default. You can set other environment variables in here. This file should normally NOT be pushed to GitHub for obvious security reasons, but for this tutorial we are doing that so you have it when you clone the repo.

Also FYI, for even better security when you get to having "swarms" of containers, you can use [Docker Secrets](https://docs.docker.com/engine/swarm/secrets/) which is beyond the scope of this getting started tutorial.

### Port settings
Defining your port numbers is a very important part of the build process. There are a lot of things to consider here, many of which I am not qualified to comment on.

One thing you will probably read is that it is a good idea not to use the default port numbers in order to make it a bit harder for a bad actor to find them. eg port 3306 is the default MySQL port and if you use that it is easy to guess. Of course, they still need to get past your MySQL user and password or SSH but that is another story. And, with Nginx we can stop the traffic coming in from outside on that port anyway.

So, to make the distinction clear in this tutorial, we define MySQL to be available on port 3307 (i.e. mapping 3307 outside the container (on the host) to 3306 inside the container). For Lucee we map 8890 outside the container (on the host) to the standard 8888 Tomcat internal port. The port numbers you choose in the `.env` file are up to you.

Another factor is what else might be using the ports you choose. In development for some other project you might already have MySQL running on localhost:3306 so you will need to pick another port so Lucee talks to your containerised MySQL not your existing local MySQL installation. Or, your Vue app server might be running on localhost:8080 by default so you wouldn't use 8080 for your Lucee server.

Port numbers are also crucial for Nginx and I will discuss that later in this tutorial.

### password.txt
Recent versions of Lucee Admin expect a file containing the Lucee Admin password for the first opening of the admin pages. We define the password here to be simply `p1`.
*Remember: we don't allow Admin in the Droplet deployment so this is only relevant for our local development.
And, normally you would .gitignore this file so it isn't in your GitHub repo but for our purposes we ARE pushing it to GitHub so you have it here. You need to manage this "secret" in your real app appropriately.*

To achieve the goal of getting the `password.txt` file into the correct folder in Lucee for development, I am using a volume mount in the `docker-compose-local.yml` file. You could also COPY it in via the `Dockerfile-local` file.

Note: When Lucee first starts up, the `password.txt` file is detected, encrypted, stored inside the Lucee Settings, then deleted. Since it is now part of your custom Lucee settings, whenever you volume-mount your Lucee settings xml files as described above, that password is part of the settings. You can change the password via the Lucee Admin pages if you want to.

So: for the *deployment* build *we neither copy nor mount the password.txt file*, since we dont have the Admin pages in the deployed version.

### Your CFML / CFC files
Of course, you need your CFML / CFC files too!

**For development** we use a volume mount, rather than copying them into the container, so you can edit the files on your host and they will be reflected in your container without needing to rebuild or restart the container.
**For deployment** (when we get there later) we COPY the files into the container so they are part of what we push to Docker Hub, which is then pulled into and "composed" on our Droplet.

## Build and compose our containers
Ok, finally, we can build our images, compose them into containers, and browse to the app's local url to use them.

**Note:**
In *development* you always need to have your Docker Desktop app running in order for the Docker daemon / CLI commands to be available, unless you manage that yourself.

In the *droplet*, the Docker daemon / CLI commands have been installed "standalone" inside the Linux virtual server and run at startup.

### Local development

The CFML pages are in the `src/www` folder. This is a very simple app to test with.

Before I describe what is going on in the app, let's build it.

Make sure in your terminal you are in the folder `src`. Then:

>`docker-compose -f docker-compose-local.yml up --build`

Once it has finished, you should see a message in the console: `[Note] mysqld: ready for connections.`

**Detached mode**
You can also compose so the containers run in "detached mode" which means they run in the background so you get less messages and retain the use of the terminal. Add the `-d` switch:
>`docker-compose -f docker-compose-local.yml up --build -d`

While experimenting and learning I prefer not to do that so I can see all the console outputs, especially when things go wrong. I simply open another terminal in VSCode to issue further commands as needed.

#### The default Lucee application

You can now navigate to: [http://localhost:8890](http://localhost:8890/) which is the `src/www/index.cfm` file.

Notes:
1. We are on `port 8890` because that is what we set in the `.env` file for the docker compose: `HOST_PORT=8890`
2. Windows VSCode WSL:
   1. Markdown Preview links such as the one above do not seem to work.
   2. The "localhost" is the one on your Windows host, not the one inside your Linux container, so put that url into a Windows browser.


You should see the **Hello from Lucee Docker How To** message, as well as a database error: `Table 'test.countries' doesn't exist` which is correct! We will fix that shortly.

You will notice the locale and timezone is set to Sydney, Australia. This is set in the `src/www/application.cfc` file. If you edit that now, then refresh your browser page, you will see that the change made in your host's copy of the application.cfc file is reflected in the container's copy. There is no need to restart the container. This is how you will do most of your CFML development.

Note: if you change code in your `onApplicationStart()` function, you **will** have to restart the application to pick up the change. I think the most convenient way to do that is to restart the container via the restart icon button in the Docker Desktop container view UI.

#### Lucee Admin pages
To open the Lucee Admin pages: [http://localhost:8890/lucee/admin/server.cfm](http://localhost:8890/lucee/admin/server.cfm)

You will be asked for the password which we set to `p1` via the `password.txt` file.

You are in the orange Server context. You can also click the `Web` tab to see the blue Web context.

**The test_dsn datasource**
At this point we have an empty database called `test`. It was created due to the `MYSQL_DATABASE: ${MYSQL_DATABASE}` in the docker compose, where the `${MYSQL_DATABASE}` variable in the `.env` file was set: `MYSQL_DATABASE=test`.

MySQL is running in its own container and its data is in the volume in `src/mydocker-volumes/mysql-data`. If you look in there via the VSCode explorer you will see the `test` db "stub" folder, but no tables yet.

The DataSource has been pre-defined in the Lucee Admin Server context. The definition is in the `src/LuceeSettings` xml files that came with this repo.

There are a couple of things to note with Docker related to DataSources. From the left nav bar, select `Services / Datasource`. You will see the `test_dsn` item. Click the Edit icon at the end of the row.

Pay attention to these two settings:
1. Host/Server: is `db` NOT 'localhost' because in the docker compose we named the MySQL container "db" and that is now its Host name on the docker network.
2. Port: remains at `3306`, NOT 3307 as you might have thought due to our `.env` setting, because this datasource port setting refers to the MySQL port exposed by the container. Therefore the datasource connection Host:Port will use `db:3306`.

**Optional:** You can also define this datasource in your `application.cfc` file. Scroll to the end of the page and the relevant CFML code can be copied and pasted.

#### Add the test database
I have provided the database via the `src/testDb.sql` file rather than via a populated MySQL volume so I can explain a bit more about the various ways of interacting with the containers.

We need to get that sql dump into the MySQL container. We have at least three ways of doing that:
1. If you use a desktop GUI (e.g. SQLyog, TablePlus, dBeaver, MySQL Workbench, etc) you can connect to the MySQL container instance via `localhost:3307` (not `db:3306` as for the datasource - that is just for the docker network). Then you can copy the `testDb.sql` file in and execute the SQL.
2. You can use the `mysql` CLI, which gives us the opportunity to see how VSCode can help us.
   1. We need to copy the `sql` file into the MySQL container. To do that we use a Docker copy command. Open a new VSCode terminal panel.
   Use
      >`docker ps`

      to show the running containers. Note the mysql:5.7 CONTAINER ID. e.g. `994e168648bd`

      Use
      >`docker cp ./src/testDb.sql 994e168648bd:./testDb.sql`

      to copy the file from your host into the container, where `994e168648bd` is replaced with *your* CONTAINER ID.
   2. Assuming you installed the [Docker in Visual Studio Code](https://code.visualstudio.com/docs/containers/overview) extension, click the Docker icon in the VSCode side bar.
   3. In the containers section, right click the `mysql:5.7` container and select `Attach shell`. You should get a new VSCode terminal panel. You are in a Linux environment there so issuing the `ls` command will list the files and folders. You should see the `testDb.sql` file listed.
   4. Start the `mysql` CLI: `mysql -uroot -pp1` (user: root, password: p1) and you should see the `mysql>` prompt
   5. `mysql> use test;`
   6. `mysql> source ./testDb.sql;`
   7. Kill the terminal in VSCode
   8. Refresh your [http://localhost:8890](http://localhost:8890/) page and you should see two CF query dumps.
3. You can also use the Docker Desktop CLI.
   1. Follow step 2.1 above if you haven't already done that.
   2. In Docker Deskop go to Containers and expand the top level `src` item.
   3. You will see the two containers. Each has a CLI icon.
   4. Click the icon for the **mysql** container and follow the steps above from point 2.4.

#### Experiment a bit
Experiment with changing your `application.cfc`, `index.cfm` and Lucee Admin settings. Refresh your browser, or restart / rebuild your containers as required and see the effects.

#### Our "world" Lucee REST API server
If you are not familiar with the way Lucee does REST APIs, this video is a good place to start: [Lucee REST Part 1](https://www.youtube.com/watch?v=R_VnRawOhhc). *BTW: I couldn't find Part 2.*

The `src` folder in this repo has the working code for our test API server for you.

I should also mention the terrific [TAFFY](https://taffy.io/) which is an alternative way to do REST in Lucee.

**NOTE:** In the REST video, and in the [Lucee Documentation](https://docs.lucee.org/guides/Various/rest-services.html), the path mappings are as per your *host* machine. However, in our situation, the path mappings are *as per the Linux file system **inside** the container*.

The mappings come pre-defined via the `LuceeSettings` xml files I provided. In the Lucee sidebar click `Archives & Resources / Rest`. In the `Mappings` section you will see the `/v1` mapping. Two things:
1. The physical path is `/var/www/endpoints` because that is where it is *inside* the container. i.e. Lucee's file system inside this Linux container. To confirm that, use the VSCode docker icon in the VSCode sidebar and explore into the Files of the Lucee container to that path. You will see the `country.cfc` file in there.
2. On my machine the Virtual host always appears in red, which usually indicates an error. However, the mapping is correct and it works. I am not sure if that is a bug in Lucee Admin or I am not understanding something.

FYI: This is not a Lucee REST tutorial. I have done just enough to show the Docker related bits. You can test the GET http method by clicking these links which will return the JSON representation of the MySQL database tables.
[http://localhost:8890/rest/v1/world/countries](http://localhost:8890/rest/v1/world/countries)
[http://localhost:8890/rest/v1/world/countries/2](http://localhost:8890/rest/v1/world/countries/2)
[http://localhost:8890/rest/v1/world/cities](http://localhost:8890/rest/v1/world/cities)
[http://localhost:8890/rest/v1/world/cities/4](http://localhost:8890/rest/v1/world/cities/4)
[http://localhost:8890/rest/v1/world/times](http://localhost:8890/rest/v1/world/times)

## Deployment
You are now ready to [deploy](Deployment.md) this Lucee App and API to Digital Ocean.