# Deployment stage
Getting set up with Digital Ocean and deploying our minimal Lucee application and REST API.

## Contents
1. [Tutorial setup](#tutorial-setup)
2. [Setting up to deploy on Digital Ocean](#setting-up-to-deploy-on-digital-ocean)
   1. [Step 1 Create SSH keys](#step-1-create-ssh-keys)
   2. [Step 2 Create your Digital Ocean Droplet](#step-2-create-your-droplet-on-digital-ocean)
   3. [Step 3 Configure your Droplet](#step-3-configure-your-droplet)
      1. [SSH login and Firewall](#3a-setting-up-ssh-and-a-basic-firewall-so-you-can-log-in-to-your-droplet)
      2. [Get a domain and delegate it](#3b-get-a-domain)
      3. [Install Nginx](#3c-install-nginx-on-your-droplet)
      4. [Enable SSL](#3d-using-certbot-to-enable-ssl)
3. [Create a Docker Hub repository](#create-a-docker-hub-repository)
4.  [Build the droplet version of the Lucee application](#build-the-droplet-version-of-the-lucee-application)
5.  [Push your Lucee app to Docker Hub](#push-your-lucee-app-to-dockerhub)
6.  [Docker Compose on the Droplet](#docker-compose-on-the-droplet)
    1.  [VSCode Remote Window and setup](#vscode-remote-window)
    2.  [Create a folder and copy our files in](#create-a-folder-and-copy-our-files-in)
    3.  [Edit the compose file](#edit-the-compose-file)
    4.  [Compose our Droplet containers](#compose-our-droplet-containers)
7.  [Configure Nginx so we can see our application's pages](#configure-nginx-so-we-can-see-our-applications-pages)
8.  [Setup the remote MySQL database](#setup-the-remote-mysql-database)
9.  [Test the remote app and your REST API](#test-the-app-and-your-rest-api)

## Tutorial setup
In the code below there are generic links using `yourdomain.com.au`. If you change those links to match *your* domain name you will be able to just click the links in the markdown preview.

I suggest:
1. Do a global Find and Replace in this file from `yourdockerhubname` to whatever your Docker Hub account name is.
2. Once you have the domain name you will use below, do a global Find and Replace in this file from `yourdomain.com.au` to whatever your domain is.
3. For Windows WSL users: due to the previously mentioned issue with Markdown Preview links in the WSL workspace, if you are following along using that instance, do the two steps above in that Windows environment, not in the Linux / WSL environment.

## Setting up to deploy on Digital Ocean
There are [a number of cloud hosting options](https://alterwebhost.com/linux-cloud-server/).

I decided to host my Lucee API server on [Digital Ocean](https://www.digitalocean.com/) because there is plenty of documentation, tutorials and 3rd party videos. The pricing is pretty reasonable, I think, especially for getting started. Setting up a Droplet (a virtual Ubuntu server) is  straight forward.

There is a button on the Digital Ocean Signup page that gives you **$100 credit** if you are a new customer.

We will use the Basic cheapest plan that has enough grunt to run our Lucee site.

For this tutorial you will need a [Digital Ocean](https://www.digitalocean.com/) account. You *do* need to supply a credit card but you only pay for what you use and for this tutorial that will amount to a few cents. I understand they dont even bother invoicing for less than 1 $US dollar.

Here is a very short blog post giving an introduction and overview of [Digital Ocean Droplets](https://devsrealm.com/posts/7d385e2dde0e86f3/what-is-digital-ocean-and-what-are-droplets-used-for-simple-guide).

## Step 1: Create SSH keys
Your Droplet is akin to a remote computer running Linux. You need a way to "log into" that computer so you can install software, run your docker CLI commands, manage your persistent user data, etc.

SSH (Secure Shell) is a more secure way to authenticate to your remote server than using just a password. We will need SSH keys for both the Droplet and VSCode sections of this tutorial, so we will create the SSH keys now.

[How to add SSH Keys to New or Existing Droplets](https://docs.digitalocean.com/products/droplets/how-to/add-ssh-keys/).

**Note 1:** For Windows users, you create your SSH keys in your Windows environment, not in the Linux / WSL environment.

**Note 2:** If you *already* have an SSH key for some other purpose
you probably wont want to overwite it. You can use a different filename to save the new key. e.g. `~/.ssh/howto_rsa`

**Note 3:** To copy the key string into Digital Ocean, display it:
> cat ~/.ssh/howto_rsa.pub

then copy and paste the key from the terminal into the Digital Ocean page, then give it a name e.g. `Lucee-how-to`

## Step 2: Create your Droplet on Digital Ocean
I started with the [Docker droplet](https://marketplace.digitalocean.com/apps/docker) which gives a virtual Linux "computer" in the cloud (a.k.a. a virtual server) with Docker already installed. I used the Ubuntu 20.04 LTS version.

1. Sign up  / Login to [Digital Ocean](https://www.digitalocean.com/)
2. Add a project (Lucee-howto)
3. Click the green `Create` button then select  `Droplets / Marketplace` search for `Docker` and select the `Docker` droplet.
4. Choose the Basic plan, CPU option: Regular with SSD, $12 (2GB RAM).
5. Then skip the Block storage, choose your nearest datacentre region, and use the Default VPC network.
6. Upload or select the SSH key you created in `Step 1: Create your SSH keys` above.
7. Additional options: maybe turn Monitoring on so you can use that later. The others are not needed for our purposes.
8. Use the default `1 Droplet`, and give it the hostname of `Lucee-how-to`
9. Skip `Add tags`
10. Select the `Lucee-howto` project
11. Click `Create Droplet`
12. Wait a minute or so for it to finish

For this tutorial you *don't* need to turn on **backups** (they cost more). For your production deployment you will definitely want to do that, or manage the backups yourself, in case something goes wrong with your Droplet.

You also have the option of having Digital Ocean manage your **database** for you (again, at an extra cost) but for this tutorial you wont want to do that.

Finally, Digital Ocean also offers **Volumes** which is not the same as the Docker volumes we will play with in this tutorial. Again, for your production deployment having a separate managed "box" for the user data might make sense, that is up to you.

## Step 3. Configure your Droplet
### 3a. Setting up SSH and a Basic Firewall so you can log in to your Droplet

You can use the terminal in your VSCode window for these steps.

Keep the following notes in mind as you follow these steps:
[Initial server setup](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-20-04)

**Note 1:** SSH login with named key files:
If you are using your named key files, not the default ones, e.g. `howto_rsa`, instead of:
> ssh root@123.456.789.000

use:
> ssh -i ~/.ssh/howto_rsa root@123.456.789.000

obviously using *your* Droplet IP address instead of 123.456.789.000

**Note 2:** The first time you log in, when you see the `Are you sure you want to continue connecting (yes/no/[fingerprint])?` type in `yes` then press Enter.

**Note 3:** When asked for the passphrase:
enter the passphrase you used when creating your SSH keys

**Note 4:** Skip making a new user (steps 2, 3, and 5). For learning it is simpler to use the root account - one less complication.

If all is well at this point you should be in the CLI of the Droplet e.g. `root@docker-how-to#`

To close the SSH terminal session, type `exit` then press Enter.

### 3b. Get a domain
As you have seen, each Digital Ocean Droplet has an IP address so you can access it over the web.

Digital Ocean does not provide domain name hosting. Instead, you host your domain name on a "normal" domain name host and point it to your Droplet's IP address. In this regard it is the same as you are used to doing in the past, where your domain server pointed to your web server's IP address.

For this tutorial, if you already have a domain name you can set up a sub-domain at your domain hosting service and point that to your Droplet's IP address; or you can get a cheap domain and use that. It is up to you.

So, either get a cheap domain or set up a subdomain now, and point it to your droplet's IP address. *As always with DNS changes, it might take a few hours or a day for the DNS servers to update so your domain will resolve to the Droplet's IP address.*

From here on, when I refer to `yourdomain.com.au` substitute your own domain name. And it does NOT include the 'www' part, ie NOT `www.yourdomain.com.au`

*As mentioned above, to simplify and customise this tutorial's md file you can find and replace `yourdomain.com.au` with **your** domain name so the links below reflect your setup.*

### 3c. Install Nginx on your Droplet
So far:
* we have a Droplet running Ubuntu 20.04
* we can SSH into that Droplet
* we have a domain pointing to your Droplet.

We now install Nginx.

#### Why install Nginx on your Droplet?
Our Lucee container serves pages using Tomcat, so why not use Tomcat directly? Why add another layer here?

The answer is that in a Production deployment it is highly likely you will want to take advantage of the functionality and flexibility that Nginx offers. For example:
1. to manage your SSL setup;
2. to manage the public-facing port numbers;
3. to add other containers on specific port numbers that have nothing to do with your Lucee server. e.g. a Blog site or a Support Ticket Management System;
4. to enable load balancing

Keep the following notes in mind as you follow these instructions to [install Nginx](https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-20-04) on your Droplet.

You can use the VSCode terminal for those steps.

#### Notes:
1. The Digital Ocean instructions suggest you use a non-root user. Again, to reduce some complexity for this tutorial we *will* be using the *root* user.
2. "Log in" means use SSH as above
3. At **Step 2 - Adjusting the Firewall**, allow `Nginx Full` so you have both port 80 and 443 (SSL) enabled. i.e.
   > sudo ufw allow 'Nginx Full'
4. At **Step 3 - Checking your Web Server**, in addition to testing Nginx by browsing to your Droplet's IP address (i.e.`http://{your droplet IP here`), you will know when your domain's name servers are resolving to the Droplet's IP address by browsing to `http://yourdomain.com.au`. You should see the same "Welcome to nginx" page.
5. Don't skip **Step 5 - Setting up Server Blocks (Recommended)**  - make sure you ***do*** set up a Server Block as described.
   Notes:
   1. When the instructions mention `your_domain` what you use is just your domain name `yourdomain.com.au`, not `www.yourdomain.com.au`.
   2. You can skip the steps about the non-root user permissions. The directory permissions for the root user will already be correct.
   3. Yes using `nano` is annoying and soon you will use VSCode instead.
   4. At the end of the server block setup you are asked to navigate to `your_domain`. If you get an `ERR_CONNECTION_REFUSED` message here, two reasons could be:
      1. you have entered an incorrect IP address when you set up your domain name (**Get a domain** above), or
      2. the Domain Name Servers have not yet propagated your domain name.

### 3d. Using Certbot to enable SSL
You will no doubt want to use SSL on your production site. So, let's do that now for our tutorial, since we can make use of the free LetsEncrypt cerificates.

Keep the following notes in mind as you follow these instructions:
[Secure your site with SSL](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-20-04)

#### Note:
1. When you are asked about redirecting HTTP traffic to HTTPS, select option 2 to Redirect.
2. You can skip the step about Certbot Auto-Renewal, unless you **do** want to keep the certificate for your domain name and use it elsewhere.

Close your remote SSH terminal now `# exit` then Enter, so you are back at your local VSCode terminal CLI.

### 3e. As an aside...
At this point what we have done could be used for any kind of **Docker deployment**, it is not Lucee-specific. e.g. PHP, Python, Node.js, a Vue app, a WordPress site, etc, or even all of the above at once!

## Create a Docker Hub repository
Just like GitHub, you need to create a repository before you can push your image to it.

1. Log into Docker Hub and visit your [Repositories section](https://hub.docker.com/repositories)
2. Click `Create Repository`
3. Docker Hub allows 1 private repository which you can use now if you wish. Alternatively, use a Public one - we will be throwing this tutorial repository away later anyway.
4. Where it says `Name` add the name `lucee-howto` (all lowercase)
5. Skip the description - we don't really want it discoverable via a search in Docker Hub.
6. Click the `Create` button

## Build the droplet version of the Lucee application
We now have a virtual server (the Droplet) on which we can deploy our Lucee app, and a Docker Hub repository to push our app to in preparation to deploying it.

We need to build the version of the Lucee container we wish to deploy. For our tutorial purposes, the main differences are:
1. in the deployed version we dont want the Lucee Admin pages to be available. In a real production build, your debugging and logging settings might differ too, for example.
2. the name of the composed Lucee docker image needs to include our Docker Hub account name. e.g. `yourdockerhubname/lucee-howto:latest`

Make sure your `src/.env` file has **your** Docker Hub account name in `DOCKERHUB_ACCOUNTNAME` so the correct value for the environment variable is used in the docker-compose.

#### Building the droplet version
1. In Docker Desktop, stop and delete any running `src` development containers.
2. Make sure you are in the `src` folder
   >cd src
3. Build the deployment container:
   >docker-compose -f docker-compose-droplet.yml up --build

Note: I have noticed that sometimes you might need to log into Docker Hub before you compose this file. You might get an error message to that effect. If so:
> docker login -u yourDockerAccountNameHere -p yourPassWordHere

If you now look in Docker Desktop Containers section, expand the `src` item and you should see your Lucee app running with an image name of `yourDockerAccountName/lucee-howto:latest`

You can also test this container. i.e. when you navigate to
1. [http://localhost:8890](http://localhost:8890/) you should see your Lucee application
2. [http://localhost:8890/rest/v1/world/countries](http://localhost:8890/rest/v1/world/countries)
you should see the REST API running as it did in development; and at,
3. [http://localhost:8890/lucee/admin/server.cfm](http://localhost:8890/lucee/admin/server.cfm)
you **should get a 404 error** page instead of the Lucee Admin page, because for this build we disabled the Lucee Admin pages.

So, we assume our build is good to go...
## Push your Lucee app image to DockerHub
In your Docker Desktop app, make sure you are signed in to your Docker Hub account. Your account name should appear in the top right hand corner Account details button.

If you wish, you can destroy the running containers (not the image), but you do not have to.

Go to the Images page in Docker Desktop.
Hover over your `yourdockerhubname/lucee-howto` image, click the 3 dots and click `Push to Hub`

The first time you do this it could take a few minutes. Subsequent pushes for Lucee will be much faster because Docker only pushes the layers that have changed.

**Note 1:** A quirk of the current Docker Desktop is that the message that appears after the push has completed successfully, or failed, only shows for a couple of seconds then disappears. So you need to keep your eye on it to make sure you get a nice green message!

**Note 2:** we DONT push the MySQL image. We will pull that into the Droplet when we run the Docker compose file on the Droplet itself, later.

You can confirm it is all there by visiting your [Docker Repositories](https://hub.docker.com/repositories) page. Click the `lucee-howto` repo for details.

## Docker Compose on the Droplet
We now need to build the containers to deploy our app on our server. To do that we need to log in to the Droplet command line using our SSH key and get the `docker-compose-droplet.yml` file in there and run it.

We *could* SSH in, but then we have to use CLI tools which is ok until you want to do some editing. If you are a Linux keyboard warrior, go for it. For the rest of us, I suggest using the VSCode remote window.

### VSCode Remote Window

#### Create a new remote SSH profile
Assuming you have installed the VSCode extensions suggested at the start of this tutorial, in the lower left hand corner of your current **development** VSCode window is a green remote button.

1. Click that button
2. Select `Connect to Host` from the menu
3. Select `+ Add New SSH Host`
4. If you are using the default ssh keys:
   > ssh root@123.456.789.000 -A
5. If you are using your named key files, not the default ones, e.g. `howto_rsa`, use e.g:
   > ssh -i ~/.ssh/howto_rsa root@123.456.789.000 -A

   as previously discussed, using *your* Droplet IP address instead of 123.456.789.000
6. This will step you through creating a new profile which you can later use to SSH in.

#### Use an existing remote SSH profile
1. Once the profile has been created, click the green remote button again, select `Connect to Host` from the menu, select your named profile.
2. That opens a new VSCode window.
   1. Note: if you get any errors here, use the `Open SSH Configuration file...` option in VSCode and check your IP address is correct.
3. Click the `Open folder` button in the VSCode sidebar.
4. VSCode will default to `/root/` because that is the folder of the "user" you remoted into. In order to finish our server configuration we need to be at the Linux root `/`, i.e. one level up. So in VSCode change `/root/` to `/` then click the `Ok` button.
5. You will need to enter your passphrase again.

#### Add the Docker extension
The Microsoft VSCode Docker extension is very helpful. Install that now in the usual way in your remote VSCode window.

### Create a folder and copy our files in
1. In your **remote** VSCode file explorer scroll to the `/root` folder.
2. Right click that folder, select `New folder` and name it `lucee-howto`
3. In your **local** VSCode file explorer, right click `docker-compose-droplet.yml`, click `Copy`.
4. In your **remote** VSCode file explorer, right click the `lucee-howto` folder and select `Paste`.
5. Repeat steps 2 and 3 to copy the `.env` and the `testDb.sql` into the remote window's `lucee-howto` folder.
6. In the remote `lucee-howto` folder create a folder named `my-docker-volumes` and inside that folder create a folder named `mysql-data`.

*Expertise required here: For security or Linux best practice there might be a reason NOT to use the **/root** folder for this. I would welcome an Issue or PR about this.*
### SFTP alternative
VSCode copy & paste is fine for a few small files. You can also SFTP your files into your Droplet. e.g. your sql dump might be huge, or you might have user images in your docker volumes that need to be present for your app to work.

**You do not need SFTP for this tutorial.**

Option: Follow the steps in this [this Digital Ocean tutorial](https://docs.digitalocean.com/products/droplets/how-to/transfer-files/) to learn how to set up SFTP. It uses FileZilla as the demo FTP client app but you could obviously use your preferred FTP client.

### Edit the compose file
In the `docker-compose-droplet.yml` file in the **remote** Droplet, we do NOT want to *build* the `yourdockerhubname/lucee-howto:latest` container. We did that already and pushed it to Docker Hub. Instead, we want to pull the built one from Docker Hub.

To enable that, open the `docker-compose-droplet.yml` file in the **remote** window and *remove these 3 lines:*
```
build:
  context: .
  dockerfile: Dockerfile-droplet
```
Save the `docker-compose-droplet.yml` file.

The line:
```
image: ${DOCKERHUB_ACCOUNTNAME}/lucee-howto:latest
```
will cause the latest version of that image to be pulled from Docker Hub.


### Compose your Droplet containers
1. On the **remote** VSCode window, open a terminal panel as you normally do in VSCode.
2. Make sure you are in the `lucee-howto folder` e.g:
   > cd /root/lucee-howto

   then
   > docker-compose -f docker-compose-droplet.yml up

This will start the compose. It will pull the `mysql:5.7` image and the `lucee-howto:latest` image from Docker Hub.

The first time it will be a bit slow (a minute or so) but on subsequent composition it will only pull the changed images or layers, so it will be much faster.

At this point there should not be any fatal errors in the terminal.

The final terminal message is usually something like `INFO [main] org.apache.catalina.startup.Catalina.start Server startup in [23762] milliseconds`

Before we can browse to the Lucee server's pages we need to reconfigure Nginx.

## Configure Nginx so we can see our application's pages
If you browse to your site you should still see the page you set up when you installed Nginx and created a `server block`

So, assuming your domain name has propagated, [https://yourdomain.com.au/](https://yourdomain.com.au/) should display your
**Success! The ... server block is working!** message which is being served from
`/var/www/yourdomain.com.au/html/index.html`

If you don't yet get that message it is probably best to wait until you do before continuing so you can test the changes you are about to make.

We now need to reconfigure Nginx to serve the pages from our Lucee app instead.

1. In your **remote** VSCode's file explorer, from the `/` Linux root, navigate to the file
`/etc/nginx/sites-available/yourdomain.com.au` and make a copy for reference in VSCode as say `yourdomain.com.auCOPY`.
2. Open the file `/etc/nginx/sites-available/yourdomain.com.au` in VSCode. This is what is directing incoming traffic for ports 80 and 443 to your default index.html page.
3. In your **local** VSCode's file explorer, open the `Nginx.conf` file. This contains a template set of Nginx server blocks you can use. I have commented it to help you understand what I am doing here.
*Expertise required: This nginx config works, but is it the best way to do it? Expecially regarding the remote MySQL access block.*
4. Select all the content then copy and paste it into the **remote** `/etc/nginx/sites-available/yourdomain.com.au` file. **i.e. replace all the existing remote content with the copied local content.**
5. Change all occurances of `yourdomain.com.au` to your actual domain, then save the file.
6. Open a new VSCode terminal in the **remote** window
7. Restart Nginx on your **remote** window (don't just reload it)
   > sudo systemctl restart nginx

   There should be no errors. If there are, use
   > systemctl status nginx.service

   to see what is wrong. You can also use
   > sudo nginx -t

   to check your new config file for syntax errors. Double check the spelling of your domain name - speaking from experience!

You should now be able to browse to your Lucee site.
[https://yourdomain.com.au/](https://yourdomain.com.au/)

If your Nginx changes are working and your containers are still running (they should be), you should see the **Hello from Lucee Docker How To** message as well as the database error: **Table 'test.countries' doesn't exist**. So far, so good.

## Setup the remote MySQL database
The table countries doesnt exist because we have an empty database. Similar to this step on your development machine, we have a few options to populate that database.

### Using VSCode
You can use the `mysql` CLI, which gives us the opportunity to see how VSCode can help us.
1. We need to copy the `sql` file into the MySQL container. To do that we use a Docker copy command. In your **remote** VSCode, open a new terminal panel.
Use
   >`docker ps`

   to show the running containers. Note the mysql:5.7 CONTAINER ID. e.g. `994e168648bd`
Use
   >`docker cp /root/lucee-howto/testDb.sql 994e168648bd:./testDb.sql`

to copy the file from your host into the container, where `994e168648bd` is replaced with *your* CONTAINER ID.
2. Assuming you installed the [Docker in Visual Studio Code](https://code.visualstudio.com/docs/containers/overview) extension, click the Docker icon in the VSCode side bar.
3. In the containers section, right click the `mysql:5.7` container and select `Attach shell`. You should get a new VSCode terminal panel. You are in a Linux environment there so issuing the `ls` command will list the files and folders. You should see the `testDb.sql` file listed.
4. Start the mysql CLI:
   >`mysql -uroot -pp1`

   (user: root, password: p1) and you should see the `mysql>` prompt.
5. Run these two commands:
   `use test;`
   `source ./testDb.sql;`
6. Kill the terminal in VSCode
7. Refresh your [https://yourdomain.com.au/](https://yourdomain.com.au/) browser page and you should see two CF query dumps.
### Using a MySQL admin app
If you want to connect your favourite MySQL Admin app, you will first need to reconfigure your Nginx `/etc/nginx/sites-available/yourdomain.com.au` file to allow an incoming port that redirects to the MySQL container's port.

*Expertise required: There is probably a more secure way of doing this involving an SSH tunnel directly into the MySQL container. For the purposes of this tutorial we are using a more direct quick and dirty approach. Also the see the Note at the end of this section.*

1. Open the `/etc/nginx/sites-available/yourdomain.com.au` file.
2. Scroll to the end.
3. Uncomment the MySQL server block.
4. Reload Nginx:
   > sudo systemctl reload nginx

5. You should now be able to establish a connection in your MySQL Admin app:
   1. Host: `yourdomain.com.au`
   2. Port: `3307` (or whichever port you defined in your .env file CF_DB_PORT variable)
   3. User: `root`
   4. Password:`p1`
6. Copy the contents of the `testDb.sql` file into your admin app and execute all the SQL

If you refresh your browser at [https://yourdomain.com.au/](https://yourdomain.com.au/) you should see the two CF query dumps.

**NOTE:** while this technique works, it is not ideal, even apart from the potential security issues. Whenever Nginx restarts, either because you are doing that from the command line after changing some config, or if you restart the whole Droplet via your Digital Ocean account, the presence of the MySQL server block in `/etc/nginx/sites-available/yourdomain.com.au` will cause a "port 3307 already used" error.

So, if you DO use this method to connect a MySQL Admin app, once you have finished it is probably best to re-comment the MySQL server block section, save the file and reload Nginx so that server block is not present at the next Nginx start.

## Test the app and your REST API
If you refresh your browser at [https://yourdomain.com.au/](https://yourdomain.com.au/) you should see your working Lucee app.
[http://yourdomain.com.au/rest/v1/world/countries](http://yourdomain.com.au/rest/v1/world/countries)
[http://yourdomain.com.au/rest/v1/world/countries/2](http://yourdomain.com.au/rest/v1/world/countries/2)
[http://yourdomain.com.au/rest/v1/world/cities](http://yourdomain.com.au/rest/v1/world/cities)
[http://yourdomain.com.au/rest/v1/world/cities/4](http://yourdomain.com.au/rest/v1/world/cities/4)
[http://yourdomain.com.au/rest/v1/world/times](http://yourdomain.com.au/rest/v1/world/times)

## Test your persistant data
You can confirm that the data in the `my-docker-volumes` folder is persistant by stopping the containers (docker compose down) and restarting them (docker compose up).

You can also turn the Droplet off altogether as detailed as part of [this page](https://docs.digitalocean.com/products/droplets/how-to/resize/) - akin to powering down a computer - then powering it back up again.

Next: [Development and deployment cycle](DDCycle.md)

