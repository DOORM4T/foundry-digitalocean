# FOUNDRY DIGITALOCEAN

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

_Automate the deployment of a Foundry VTT server to a DigitalOcean droplet, so you can focus on running your games (and save on costs by only running your droplet when you need it)._

_Disclaimer: This project is not affiliated with Foundry VTT or DigitalOcean._

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

- FoundryVTT (https://foundryvtt.com/)
  You will need to purchase a license for FoundryVTT, where you can generate a presigned URL to download the software.

## Usage

### Deploying the infrastructure

1. Clone this repository to your local machine.
2. Generate a Personal Access Token with read and write access to DigitalOcean your account.
3. Generate a FoundryVTT presigned URL through your FoundryVTT account. Note that this URL expires after 300 seconds

   Run the following script and paste the URL into the prompt:

   ```bash
    # This script will prompt you for your FoundryVTT presigned
    # URL and build a Docker image that will be pushed to your
    # DigitalOcean droplet by the `run.sh` script
    $ ./build-image.sh
   ```

4. Deploy the necessary infrastructure to DigitalOcean:

   ```bash
    # This script will prompt you for the necessary information
    # to deploy your infrastructure, including your DigitalOcean
    # Personal Access Token, an optional domain name (if you have one),
    # and SSH keys.
    $ ./run.sh
   ```

5. Once the infrastructure is deployed, you can access your FoundryVTT server at the IP address / configured domain name of your DigitalOcean droplet. You can also find this IP address via your DigitalOcean dashboard.

6. Enjoy!

### Backing up your data from the DigitalOcean droplet

To save your data back to your local machine, you can zip and copy the `/home/foundry-user/foundry/data` folder from your DigitalOcean droplet using tools like `scp`:

```bash
 $ cd /home/foundry-user/foundry
 $ tar -czvf data.tar.gz data
 $ scp -r foundry-user@<YOUR_DIGITALOCEAN_DROPLET_IP_ADDRESS_OR_DOMAIN_NAME>:/home/foundry-user/foundry/data.tar.gz <YOUR_LOCAL_PATH>
```

### Destroying the infrastructure

```
⚠️ Before destroying your infrastructure, be sure to back up your FoundryVTT data to your local machine or elsewhere. ⚠️
```

To destroy the infrastructure, run the following script:

```bash
 $ ./destroy.sh
```

This will destroy the DigitalOcean droplet and all associated infrastructure, including the DigitalOcean droplet, domain name, and SSL certificates. You will need to re-run the `run.sh` script to re-deploy the infrastructure.

With the way DigitalOcean's billing works, you will only be charged for the time that your droplet is running, so you can save on costs by destroying the infrastructure when you are not using it.
