FROM ubuntu:14.04
LABEL maintainer "Dmitrii Ageev <d.ageev@gmail.com>"

# Set package variables
ENV FILE xmind-8-beta-linux_amd64.deb
ENV LINK "https://www.xmind.net/xmind/downloads/$FILE"

# Set a user account details
ENV UNAME developer
ENV HOME /home/$UNAME

# Set locale
ENV LANG en_US.UTF-8

# Set non-interactive interface for apt
ENV DEBIAN_FRONTEND noninteractive

# Create a user
RUN groupadd -g 1000 $UNAME
RUN useradd -u 1000 -g 1000 -G audio -m $UNAME

# Update cache and install system tools
RUN apt update
RUN apt install -y wget

# Download and install XMind
RUN wget $LINK -O $HOME/$FILE
RUN apt install -y $HOME/$FILE
RUN rm -f $HOME/$FILE

# Switch to the user account
USER $UNAME

# Start Xmind
CMD /usr/bin/XMind
