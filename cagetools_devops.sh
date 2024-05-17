#!/bin/bash

## APP SETTINGS
## COLORS
CWD=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
RESETCOLOR='\e[0m' # No Color
LB='\e[1;33;44m'   # Light yellow text with blue background
LBD='\e[0;97;44m'  # Same as LB but without bold formatting
PURPLE='\e[0;95;40m'

YELLOW='\033[0;33m'
YB='\e[0;43;1;31m '
RED="\e[1;41m;31m"
GREEN="32"
YELLOWBG="43"
ENDCOLOR="\e[0m"
BOLDGREEN="\e[1;${GREEN}m"
ITALICRED="\e[3;${RED}m"
BARDOWN="\u29ea"

# ICONS
STAR='★'
APPTITLE="CageTools DevOps"
APPDESC="This script provides a simplified process to get started installing commonly used frameworks for DevOps and development"

EMPTYSECTION="${RED} !!!!! This Section has not been created yet, check back later !!!!! "

## FUNCTIONS

### APP GLOBALS

setup_helpers () {
    # Terraform
    touch ~/.bashrc
    terraform -install-autocomplete
}

display_app_intro () {
    # Define ANSI escape codes
    BOLD='\033[1m'         # Bold text
    NOBOLD='\033[0m'         # Bold text
    RESET='\033[0m'        # Reset text formatting
    CENTER=$(tput cols)    # Get terminal width for center alignment

    # Calculate padding to center-align the title
    TITLE_PADDING=$(( ($CENTER - ${#APPTITLE}) / 2 ))

    # Display the title in uppercase, larger font size, and centered
    echo -e "${LB}"
    echo -e "${BOLD}"                           # Apply bold formatting
    printf "%*s" $TITLE_PADDING                 # Print padding for center alignment
    echo "${APPTITLE^^}"                        # Convert title to uppercase and print

    echo -e "${LBD}"  
    # Display the description and platform selection prompt
    echo
    echo -e "${APPDESC}"
    echo
    note ":::: Select ::::"
    
    echo -e "${RESET}"                          # Reset text formatting
}

show_menu_empty () {
    echo -e "${EMPTYSECTION}"
    echo -e "Returning to main menu in 3s"
    
    # Countdown timer
    for ((i=5; i>=1; i--)); do
        stars=$(printf '★%.0s' $(seq 1 $i))
        echo -e "$stars"
        sleep 0.5
    done
    app_main
}

return_to_mainmenu () {
echo "<<< Returning to Main Menu >>>" && app_main
}

exit_app () {
echo "<<< Closing App >>>" && exit
}

# Define ANSI escape codes
BG_BLUE='\033[44m'        # Blue background
YELLOW='\033[1;33m'       # Yellow text
RESET='\033[0m'           # Reset text formatting

# Function to display centered message with specified colors
section_header() {
    local message="$1"
    local message_length=${#message}
    local terminal_width=$(tput cols)

    # Calculate padding to center-align the message
    local padding=$(( ($terminal_width - $message_length) / 2 ))

    # Display the message with specified colors and center alignment
    echo -e "${BG_BLUE}${YELLOW}"
    printf "%*s\n" $padding "$message"
    echo -e "${RESET}"
}

# Function to display centered message with specified colors
action() {
    local message="$1"

    # Display the message with specified colors and center alignment
    echo -e "${PURPLE}"
    echo $message
    echo -e "${RESET}"
}

# Function to display centered message with specified colors
note() {
    local message="$1"

    # Display the message with specified colors and center alignment
    echo -e "${LBD}"
    echo $message
    echo -e "${RESET}"
}

section () {
    local message="$1"

    # Display the message with specified colors and center alignment
    echo -e "${LB}"
    echo $message
    echo -e "${RESET}"
}

### TERRAFORM
terraform_update_dependencies () {
    action "Updating dependicies"
    note "Ensure that your system is up to date and you have installed the gnupg, software-properties-common, and curl packages installed. You will use these packages to verify HashiCorp's GPG signature and install HashiCorp's Debian package repository."
    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
    action "Finished updating dependicies"
}

terraform_install_gpgkey () {
            # note "Install the HashiCorp GPG key."
            action "Installing GPG key"
            #note "Install the HashiCorp GPG key"
            wget -O- https://apt.releases.hashicorp.com/gpg | \
            gpg --dearmor | \
            sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
            
            action "Verifying the key's fingerprint."
            gpg --no-default-keyring \
            --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
            --fingerprint
        }

terraform_install_repository () {
            action "Installing repository"
            note "Adding the official HashiCorp repository to your system. The lsb_release -cs command finds the distribution release codename for your current system, such as buster, groovy, or sid."
            
            echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
            https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
            sudo tee /etc/apt/sources.list.d/hashicorp.list

            note "Downloading the package information from HashiCorp"
            sudo apt update

            note "Installing Terraform from the new repository."
            sudo apt-get install terraform

            note "Now that you have added the HashiCorp repository, you can install ${YELLOW}Vault, Consul, Nomad and Packer${YELLOW}${LB} with the same command : ${YELLOW}"
            action sudo apt-get install Vault 
            action sudo apt-get install Consul
            action sudo apt-get install Nomad
            action sudo apt-get install Packer

            action "Repository installation finished"
}

terraform_verify_install () {
            action "Verifying install"
            note "Verify that the installation worked by opening a new terminal session and listing Terraform's available subcommands."
            terraform -help plan
            action "Terraform Verification finished"
}


# Function to create folders
create_folders() {
    local parent_dir="$1"
    shift
    local folders=("$@")
    
    # Change directory to parent directory if provided
    if [ -n "$parent_dir" ]; then
        mkdir -p "$parent_dir"
        cd "$parent_dir" || exit 1
    fi
    
    # Loop through the array and create directories
    for folder in "${folders[@]}"; do
        mkdir "$folder"
        #cd "$folder" || exit 1
    done
    cd ..
}




### SB Book PAK
data_make_file () {

read -p "App Name?" appname
mkdir $appname
cd $appname

# Define the array of folder names
folder_assets=("js" "css" "html")
folder_core=("log" "ssl" "traces" "spikes")

# Create folders
create_folders "src" "${folder_assets[@]}"
create_folders "core" "${folder_core[@]}"


# Write core assets

# read -p "External Port #?" port

port="8000"
# Define the content of main.tf
coreconfig=$(cat <<EOF

StoreName: ${appname}
Port: ${port}
Tags

EOF
)

nav=$(cat <<EOF

    <div className="nav-container">
      <a><img src={logo} className="nav-logo" alt="logo" /></a>
      <nav className="navi-nav">
        <ul>
          <li><a href="#marshley">Order</a></li>
          <li><a href="#foryou">Menu</a></li>
          <li><a href="#testimonials">Nutrition</a></li>
          <li><a href="#faq">FAQ</a></li>
          <li><a href="#ready">Servers</a></li>
          <li><a href="#register">Register</a></li>
        </ul>
      </nav>
      <button className="login-btn">Login</button>
    </div>

EOF
    )


corecss=$(cat <<EOF

h1,h2,h3,h4 {
    color: white;
    justify-text: center;
}

h1 {
    font-size: 48px;
}

h2 {
    font-size: 36px;
}

h3 {
    font-size: 24px;
}

h4 {
    font-size: 20px;
}

body{
    background-color: teal;
}

body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  width: 100%;

}

.nav-container {
  position: -webkit-sticky;
  position: sticky;
  top: 0;
  background-color: #faff00;
  background-image: linear-gradient(319deg, #faff00 0%, #ff1000 37%, #ff6a00 100%);
  padding: 10px 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  z-index: 1000;
  margin: 0px;
  
    overflow-x: hidden;
}

.nav-logo {
  width: 50px; /* Adjust size as needed */
  height: auto;
  padding-right: 20px;
}

.navi-nav ul {
  list-style-type: none;
  margin: 0;
  padding: 0;
  display: flex;
}

.navi-nav li {
    
    margin-right: 20px;
  
}

.navi-nav a {
  color: white;
  text-decoration: none;
  font-size: 1em;
  transition: color 0.3s ease;
}

.navi-nav a:hover {
  color: #ff6a00; /* Change to your desired hover color */
}

.login-btn {
  background-color: transparent;
  border: 2px solid white;
  color: white;
  padding: 8px 20px;
  border-radius: 20px;
  font-size: 1em;
  cursor: pointer;
  transition: background-color 0.3s ease, color 0.3s ease;
}

.login-btn:hover {
  background-color: white;
  color: #ff6a00; /* Change to your desired hover color */
}

@scope (.item-tag) {
  :scope {
    background-color: #faff00;
    background-image: linear-gradient(319deg, #faff00 0%, #ff1000 37%, #ff6a00 100%);
    color: white;
    padding: 10px;
  }
  .hearty { background-color: red; }
  .gluten-free { background-color: brown; }
  .comfy { background-color: blue; }
  .diet { background-color: green; }
}



EOF
)

js=$(cat <<EOF



EOF
)

html=$(cat <<EOF

 <link rel="stylesheet" href="core.css"> 


 <!DOCTYPE html>
<html>
<head>
  <title>${appname}</title>
  <link rel="icon" type="image/x-icon" href="favicon.ico">
</head>


<body>
${nav}
<h1> ${appname} </h1>
<h2> Ready for Greatness? </h2>

<div class="container-item">
    <div class="item-card">
        <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRsoR3Us3A4iJJ2sovMLg11TLx7qNJ9bFnoQOsc6Qfpag&s"> </img>
        <p>Begin with a little magic eac day</p>
        <div class="item-att">
            <h3>Promote</h3>
            <h3>Situate</h3>
        </div>
    </div>
</div>

    <div class="item-card">
        <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRsoR3Us3A4iJJ2sovMLg11TLx7qNJ9bFnoQOsc6Qfpag&s"> </img>
        <p>Begin with a little magic eac day</p>
        <div class="item-att">
            <h3>Promote</h3>
            <h3>Situate</h3>
        </div>
    </div>
        <div class="item-card">
        <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRsoR3Us3A4iJJ2sovMLg11TLx7qNJ9bFnoQOsc6Qfpag&s"> </img>
        <p>Begin with a little magic eac day</p>
        <div class="item-att">
            <h3>Promote</h3>
            <h3>Situate</h3>
        </div>
    </div>
        <div class="item-card">
        <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRsoR3Us3A4iJJ2sovMLg11TLx7qNJ9bFnoQOsc6Qfpag&s"> </img>
        <p>Begin with a little magic eac day</p>
        <div class="item-att">
            <h3>Promote</h3>
            <h3>Situate</h3>
        </div>
    </div>

</body>
</html> 


EOF
)

# Write the content to files
echo "$coreconfig" > core.config
echo "$corecss" > core.css
echo "$corejs" > core.js
echo "$html" > index.html


note "${appname} created successfully."

# note "Location ${CWD}"
open ./index.html
cd ..


read -p "Create another app (y/n)?" choice
case "$choice" in 
  y ) 
        data_make_file
            ;;
  n ) 
        note "Returning to Main menu ${CWD}" && app_main
            ;;
  * ) echo "invalid" && app_main;;
esac

}





terraform_resource_ec2 () {

read -p "Resource Name?" name
mkdir $name
cd $name

# ver: 3.74.0
# ver: 4.16
# ami-830c94e3  --- us-west-2

action "Creating AWS EC2 main.tf"
# Define the content of main.tf
main_tf_content=$(cat <<EOF

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-west-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"

  tags = {
    Name = "${name}"
  }
}
EOF
)

# Write the content to main.tf
echo "$main_tf_content" > main.tf

echo "main.tf created successfully."
}

terraform_resource_ec2_multi () {

read -p "Resource Name?" name
mkdir $name
cd $name
read -p "How many instances?" amount

# key pair aquarlis-ssh
# ver: 3.74.0
# ver: 4.16
# ami-830c94e3  --- us-west-2
# ami-07caf09b362be10b8  --- us-east-1

action "Creating AWS EC2 main.tf"
# Define the content of main.tf
main_tf_content=$(cat <<EOF

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "app_server" {
  count         = ${amount} 
  ami           = "ami-07caf09b362be10b8"
  instance_type = "t2.micro"

  tags = {
    Name = "${name}" 
  }
}

EOF
)
action "Creating ${amount} EC2 instances..."
# Write the content to main.tf
echo "$main_tf_content" > main.tf

action "main.tf was created and configured to create ${amount} instances."
}


### Creates the main.tf config file
terraform_resource_nginx () {


read -p "Resource Name?" name
mkdir $name
cd $name
read -p "External Port #?" port

action "Creating NGINX server main.tf"
# Define the content of main.tf
main_tf_content=$(cat <<EOF

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

resource "docker_image" "nginx" {
  name         = "nginx"
  keep_locally = false
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "${name}"

  ports {
    internal = 80
    external = ${port} 
  }
}
EOF
)

# Write the content to main.tf
echo "$main_tf_content" > main.tf

echo "main.tf created successfully."
}

terraform_resource_selection () {
    section "Choose a resource"
    local menu=("AWS EC2" "Local NGINX server" "Main Menu" "Exit")
    populate_menu "${menu[@]}"

    # Process selection
    case $choice in
        1) terraform_resource_ec2_multi ;;
        2) terraform_resource_nginx ;;
        3) return_to_mainmenu ;;
        4) exit_app ;;
        *) echo "Invalid option. Please select a number between 1 and ${#menu[@]}" ;;
    esac

}

### Creates a directory + docker container and initializes it
terraform_initialize () {
    note "Terraform Initialize: Creating a directory + docker container then initializing it"
 
    terraform_resource_selection
    action "Initializing directory"
    sudo terraform init
    action "Formating and validating the configuration"
    sudo terraform fmt
    sudo terraform validate
    action "Version check"
    sudo terraform init -upgrade
    action "Creating infrastructure"
    terraform apply
    docker ps

}

### Installs Terraform and all dependencies
terraform_install_full () {
    note "Install Terraform Full"

    terraform_update_dependencies

    terraform_install_gpgkey
    
    terraform_install_repository
    
    terraform_verify_install 
    

}


##DOCKER

docker_add_gpgkey () {
            note "Install Docker"

            note "Add Docker's official GPG key"
            sudo apt-get update
            sudo apt-get install ca-certificates curl
            sudo install -m 0755 -d /etc/apt/keyrings
            sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
            sudo chmod a+r /etc/apt/keyrings/docker.asc
}

docker_add_repository () {
            note "Add the repository to Apt sources "
            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
              $(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" | \
              sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt-get update

}

docker_install_packages () {
            note "Install the Docker packages."
            note "Install latest"

            sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

            note "Before you install Docker Engine for the first time on a new host machine, you need to set up the Docker repository. Afterward, you can install and update Docker from the repository."
        
}

docker_verify_install () {

            sudo docker run hello-world
        
}


# Build menu for Docker options

populate_menu () {
    local menu=("$@")
    #local menutitle
    # Prompt for selection
    # echo "Select an option:"
    
    # Display menu options
    for ((i=0; i<${#menu[@]}; i++)); do
        echo "$((i+1)). ${menu[$i]}"
    done
    read choice
}

show_menu_docker () {
    section "Docker Options"
    local menu=("Update Docker dependencies" "Install Docker GPG key" "Install Docker repository" "Verify Docker installation" "Main Menu" "Exit")
    populate_menu "${menu[@]}"

    # Process selection
    case $choice in
        1) docker_add_gpgkey ;;
        2) docker_add_repository ;;
        3) docker_install_packages ;;
        4) docker_verify_install ;;
        5) return_to_mainmenu ;;
        6) exit_app ;;
        *) echo "Invalid option. Please select a number between 1 and ${#menu[@]}" ;;
    esac
}

show_menu_terraform () {
    section "Terraform Options"
    local menu=("Create & Initialize Container" "Terraform Full Install" "More Options")
    local options=("Update Terraform dependencies" "Install Terraform GPG key" "Install Terraform repository" "Verify Terraform installation" "Create main.tf File" "Main Menu" "Exit")
    populate_menu "${menu[@]}"

    case $choice in
        1) 
            terraform_initialize
            ;;
        
        2) 
            terraform_install_full
            ;;

        3) 
            populate_menu "${options[@]}"
            ### read -p "Select an option: " moreoptions
            # Process selection
            case $choice in
                1) terraform_update_dependencies 
                ;;
                2) terraform_install_gpgkey 
                ;;
                3) terraform_install_repository 
                ;;
                4) terraform_verify_install 
                ;;
                5) terraform_resource_nginx 
                ;;
                6) return_to_mainmenu 
                ;;
                7) exit_app ;;
                *) echo "Invalid option. Please select a number between 1 and ${#options[@]}" ;;
            esac
            ;;
        *)
            echo "Invalid option. Please select a number between 1 and 3."
            show_menu_terraform
            ;;
    esac
}


show_menu_aws () {
    section "AWS Options"
    local menu=("S3" "Route53" "Main Menu" "Exit")
    local s3=("Create Bucket" "Purge Bucket" "Main Menu" "Back")
    populate_menu "${menu[@]}"

    # Process selection
    case $choice in
        1) note "s3"
            populate_menu "${s3[@]}"

            case $choice in
                1) ;;
                2) ;;
                3) ;;
                4) break ;;
            esac
        ;;
        2) echo "Route53";;
        3) return_to_mainmenu ;;
        4) exit_app ;;
        *) echo "Invalid option. Please select a number between 1 and ${#menu[@]}" ;;
    esac
}

show_menu_appbuilder () {
    section "Terraform Options"
    local menu=("React" "NextJS" "VueJS" "Install Common Modules" "Exit")
    local react=("Install" "Remove")
    local next=("Install" "Remove")
    local vue=("Install" "Remove")

    populate_menu "${menu[@]}"

    # Process selection
    case $choice in
        1)
            section_header "React App Options"
            populate_menu "${react[@]}"
            echo "Are you in the directory where you want to install your React app?"
                read -p "Continue (y/n)?" choice
                case "$choice" in 
                  y ) 
                        read -p "App Name?" appname
                            mkdir $appname
                            npx create-react-app $appname
                            note "Success! React app $appname has been installed in ${CWD}/$appname"
                            cd $appname
                            
                            #Run app verify
                            read -p "Run App? | y/n" choice
                            case "$choice" in y) npm start ;; n) show_menu_appbuilder ;;
                            esac
                            ;;
                  n ) 
                        note "Return when you're in the folder where you want to create the app folder EX: /YOUR_LOCATION/APP_TO_CREATE --- Current directory${CWD}"
                        app_main
                            ;;
                  * ) echo "invalid";;
                esac
            ;;
        2) echo "NextJS"

            case $choice in
                1) ;;
                2) ;;
                3) ;;
                4) break ;;
            esac
        ;;
        3) npm create vue@latest && app_main;;
        4) return_to_mainmenu ;;
        5) exit_app ;;
        *) echo "Invalid option. Please select a number between 1 and ${#menu[@]}" && app_main;;
    esac

}



#################
# RUN PROGRAM BODY
#################

app_main () {

display_app_intro


# Print menu options
platforms=("Terraform" "Docker" "Jenkins" "AWS CLI" "App Builder" "Automation Formulas" "DEV" "Exit")
select choice in "${platforms[@]}"; do
    # Display intro message based on selected choice
    
    section_header "$choice" 

    # Perform actions based on selected choice
    case $choice in
        "Terraform")
            show_menu_terraform
            ;;
        "Docker")
            show_menu_docker
            ;;
        "Jenkins")
            show_menu_empty
            ;;
        "AWS CLI")
            show_menu_aws
            ;;

        "App Builder")
            show_menu_appbuilder
            ;;

        "Automation Formulas")
            show_menu_empty
            ;;

        "DEV")
            data_make_file
            ;;

        "Exit")
            
            exit

            ;;
        *)
            echo "Invalid selection. Please choose a valid option."
            ;;
    esac
    break
done

}

setup_helpers
app_main