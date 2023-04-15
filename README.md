# FOUNDRY-DIGITALOCEAN

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

_Automate the deployment of your self-hosted FoundryVTT server to a DigitalOcean droplet, so you can focus on running your games -- and save on costs by only running your droplet when you need it._

## Before You Begin

This project is not affiliated with FoundryVTT or DigitalOcean.

Note that this project is a work in progress, though it is currently functional. You may encounter bugs. Please report them if you do! And if you'd like to contribute, feel free to open a pull request.

This project is intended for those who are comfortable with the command line. If you are not comfortable with the command line, you may want to wait until a desktop GUI is available.

You should have a license for FoundryVTT, which you can purchase at https://foundryvtt.com. You will need it to generate a presigned URL that will be used to build your own Docker image that will be deployed to your DigitalOcean droplet.

You will also need a DigitalOcean account with billing enabled. Be sure to keep an eye on your DigitalOcean dashboard & billing details to avoid any unexpected charges.

Finally, this you'll need a domain name you can use for your FoundryVTT server, which is necessary for setting up SSL certificates/HTTPS. Non-domain name support may be added in the future.

## Features

This project contains a set of scripts to...

- Build a Docker image of FoundryVTT using your FoundryVTT presigned URL download
  (Based on https://github.com/felddy/foundryvtt-docker#pre-installed-distribution-builds)
- Deploy a FoundryVTT server to a DigitalOcean droplet with your own domain name and HTTPS.
- Back up your latest FoundryVTT data from the DigitalOcean droplet to your local machine.
- Destroy the infrastructure when you're done using it, so you only pay for the time you use it.

## Prerequisites

On your local machine, you will need the following installed:

- Terraform (https://www.terraform.io/downloads.html)

  Creates the DigitalOcean droplet infrastructure via `droplets.tf` and `provider.tf`.

- Ansible (https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

  Configures the DigitalOcean droplet via `playbook.yml`, creating a `foundry-user` on the droplet, setting up SSL certificates, and running the FoundryVTT Docker image.

- Docker (https://docs.docker.com/get-docker/)

  You will build your own FoundryVTT Docker image using your FoundryVTT presigned URL download. This image will be pushed and run on your DigitalOcean droplet.

You will also need credentials for the following services:

- DigitalOcean (https://cloud.digitalocean.com/account/api/tokens)

  You will need to create a Personal Access Token with read and write access to DigitalOcean your account.

  Additionally, you should create an ssh key named "terraform" in your DigitalOcean account, which will be used to access your DigitalOcean droplet. You can do this via the DigitalOcean dashboard.

- FoundryVTT (https://foundryvtt.com/)

  You will need to purchase a license for FoundryVTT, where you can generate a presigned URL to download the software.

## Usage

### Deploying the infrastructure

1. Clone this repository to your local machine.
2. Generate a Personal Access Token with read and write access to DigitalOcean your account.
3. Create an SSH key named "terraform" in your DigitalOcean account.
4. Generate a FoundryVTT presigned URL through your FoundryVTT account. Note that this URL expires after 300 seconds

   Run the following script and paste the URL into the prompt:

   ```bash
    # This script will prompt you for your FoundryVTT presigned
    # URL and build a Docker image that will be copied to your
    # DigitalOcean droplet by the `deploy.sh` script
    $ ./build-image.sh
   ```

   You won't need to run this build script again unless you want to re-create your Docker image for some reason.

5. Deploy the necessary infrastructure to DigitalOcean:

   ```bash
    # This script will prompt you for the necessary information
    # to deploy your infrastructure, including your DigitalOcean
    # Personal Access Token, an optional domain name (if you have one),
    # and SSH keys.
    $ ./deploy.sh
   ```

6. Once the infrastructure is deployed, you can access your FoundryVTT server at the IP address / configured domain name of your DigitalOcean droplet. You can also find this IP address via your DigitalOcean dashboard.

7. Enjoy!

### Backing up your data from the DigitalOcean droplet

To save your FoundryVTT data back to your local machine, you can use the `backup-from-droplet.sh` script.

```bash
 $ ./backup-from-droplet.sh
```

You can also use any other manual method to get your data (e.g. `scp`, `rsync`, etc). You can find your FoundryVTT data on the droplet at `/home/foundry-user/foundry/data`.

Note that DigitalOcean has Droplet transfer limits, so you may want to be careful about how much data you transfer or else you may be charged per GB over the limit. Keep an eye on your DigitalOcean dashboard & billing details!

### Destroying the infrastructure

```
⚠️ Before destroying your infrastructure, be sure to back up your FoundryVTT data to your local machine or elsewhere. You have been warned! ⚠️
```

To destroy the infrastructure, run the following script:

```bash
 $ ./destroy.sh
```

This will destroy the DigitalOcean droplet and all associated infrastructure, including the DigitalOcean droplet, domain A record, and SSL certificates. You will need to re-run the `deploy.sh` script to re-deploy the infrastructure.

With the way DigitalOcean's billing works, you will only be charged for the time that your droplet is running, so you can save on costs by destroying the infrastructure when you are not using it.

### Additional Notes

#### Faster deployment/destruction with input files

You can create input files to pass to the `deploy.sh` and `destroy.sh` scripts to speed up the process, rather than having to manually enter your information each time.

For example, you can create a `deploy-input.txt` file

...then use it to quickly deploy like this:

```bash
./deploy.sh < deploy-input.txt
```

Your `deploy-input.txt` may look similar to this, where each line corresponds to the input prompts from the `deploy.sh` script:

Note that this will automatically deploy the infrastructure, so be sure the input file is exactly as you want it before running the script.

```
dop_v1_1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
~/.ssh/terraform/id_rsa
~/.ssh/terraform/id_rsa.pub
example.com
www
/path/to/foundry-digitalocean/backups/foundrydata_2023-03-14_15-09-26.zip
yes

```

You can do the same for the `destroy.sh` script. Note that its input prompts differ slightly from the `deploy.sh` script when creating an input file of your own for it.

#### Resizing your droplet

You can resize your droplet via the DigitalOcean dashboard.

Alternatively, you can destroy your existing infrastructure, edit `droplets.tf` to change the `size` parameter to the desired droplet size, then re-run the `deploy.sh` script.

Be wary of the costs associated with different droplet sizes.

#### Firewall rules

You can update the firewall rules for your droplet via the DigitalOcean dashboard. The firewall name is `foundry_droplet_firewall`, and is associated with your droplet by the `FoundryVTT` tag.

Alternatively, you can destroy your existing infrastructure, edit `droplets.tf` to change the `foundry_droplet_firewall` resource to the desired firewall rules, then re-run the `deploy.sh` script.

## What's Next?

- [ ] Support for different FoundryVTT versions
- [ ] Make SSL config optional (particularly for those who don't have a domain name)
- [ ] Desktop GUI
- [ ] Support for other cloud providers?
