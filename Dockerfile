FROM ubuntu:xenial
LABEL maintainer "Dmitrii Ageev <d.ageev@gmail.com>"

# Set a user account details
ENV UNAME developer
ENV HOME /home/$UNAME

# Set package variables
ENV FILE "xmind-8-beta-linux_amd64.deb"
ENV LINK "https://www.xmind.net/xmind/downloads/$FILE"

# Set locale
ENV LANG en_US.UTF-8

# Set non-interactive interface for apt-get
ENV DEBIAN_FRONTEND noninteractive

# Create a user
RUN groupadd -g 1000 $UNAME
RUN useradd -u 1000 -g 1000 -G audio -m $UNAME

# Update cache and install system tools
RUN apt update
RUN apt install -y curl

# Download and install XMind
RUN curl -L -o $FILE $LINK 
RUN apt install -y ./$FILE
RUN rm -f $FILE

# Switch to the user account
USER $UNAME

# Start Xmind
CMD SWT_GTK3=0 /usr/bin/XMind
