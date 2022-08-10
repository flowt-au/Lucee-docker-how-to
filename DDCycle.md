# Development, deployment and fine tuning
If the real world you will be developing your application by editing your CFML files.

In a real environment you might want to implement a CI/CD pipleline (which I have not done).

For this tutorial I go with a manual development and deployment process so it is more easily understood:
1. On your **development** machine, start up your containers.
   >docker-compose -f docker-compose-local.yml up --build
2. Edit your Lucee app files in VSCode and test them.
3. Stop your local containers.
4. Compose the droplet container and run your final tests just to make sure everything works and the Admin pages are missing, etc.
   >docker-compose -f docker-compose-droplet.yml up --build
5. Push your new Lucee image to Docker Hub.
6. Use your **remote** VSCode workspace and open a terminal panel.
7. Stop your running containers:
   > cd root
   > cd lucee-howto
   > docker-compose -f docker-compose-droplet.yml down
8. Pull your latest Lucee image:
   > docker pull yourdockerhubname/lucee-howto:latest
9. Start your containers again:
   > docker-compose -f docker-compose-droplet.yml up
10. Test in your browser: [https://yourdomain.com.au/](https://yourdomain.com.au/)

## Digital Ocean fine tuning
You can [track the performance](https://docs.digitalocean.com/products/droplets/how-to/graphs/) of your Droplet and watch its resource use.

Droplets can be [resized](https://docs.digitalocean.com/products/droplets/how-to/resize/) to give more or less Disk allocation, CPU and RAM capacity, etc.

## Destroy your Droplet to avoid paying for it
Don't forget to destroy the droplet you created as part of this tutorial so you aren't paying for it!

Powering a Droplet down does NOT stop the meter running - you must [destroy it](https://docs.digitalocean.com/products/droplets/how-to/destroy/) to avoid being charged for it. And, of course, once you do that everything is gone, permanently.

## Backups
You can enable [backups in Digital Ocean](https://docs.digitalocean.com/products/images/backups/) so you *can* recover everything after destroying and recreating a Droplet.

## Smaller Lucee containers
This [blog post by Mark Drew](https://markdrew.io/azul-zulu-lucee-docker) explores alternative Lucee images that are much smaller.
