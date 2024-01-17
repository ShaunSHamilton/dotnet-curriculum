FROM ubuntu:20.04

ARG USERNAME=camper
ARG REPO_NAME=dotnet-curriculum

RUN mkdir /workspace

ARG HOMEDIR=/workspace/$REPO_NAME

RUN mkdir /workspace/${REPO_NAME}

ENV TZ="America/New_York"

RUN apt-get update && apt-get install -y sudo

# Unminimize Ubuntu to restore man pages
RUN yes | unminimize

# Set up timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set up user, disable pw, and add to sudo group
RUN adduser --disabled-password \
  --gecos '' ${USERNAME}

RUN adduser ${USERNAME} sudo

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> \
  /etc/sudoers

# Install packages for projects
RUN sudo apt-get install -y curl git bash-completion man-db firefox wget nano vim

# Install Node LTS
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
RUN sudo apt-get install -y nodejs

WORKDIR ${HOMEDIR}
RUN sudo wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
RUN chmod +x ./dotnet-install.sh
RUN ./dotnet-install.sh --channel 8.0

# RUN ln -s /usr/local/share/dotnet/dotnet /usr/local/bin/dotnet

ENV DOTNET_ROOT=/usr/local/bin/dotnet
ENV PATH=$PATH:/usr/local/bin/dotnet:/usr/local/share/dotnet/tools

# /usr/lib/node_modules is owned by root, so this creates a folder ${USERNAME} 
# can use for npm install --global
WORKDIR ${HOMEDIR}
RUN mkdir ~/.npm-global
RUN npm config set prefix '~/.npm-global'

# Configure course-specific environment
COPY . .
WORKDIR ${HOMEDIR}

RUN cd ${HOMEDIR} && npm install