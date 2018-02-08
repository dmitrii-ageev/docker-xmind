FROM ubuntu:xenial
MAINTAINER Dmitrii Ageev <d.ageev@gmail.com>

# Set environment
ENV APPLICATION "telegram"
ENV FILE "xmind-8-beta-linux_amd64.deb"
ENV LINK "https://www.xmind.net/xmind/downloads/$FILE"
ENV EXECUTABLE "/usr/bin/XMind"
ENV SWT_GTK3 "0"

# Install software package
RUN apt update
RUN apt install --no-install-recommends -y \
    pulseaudio-utils \
    pavucontrol \
    libcanberra-pulse \
    sudo \
    curl 

RUN curl -kL -O "${LINK}"
RUN apt install -y ./${FILE}

# Remove unwanted stuff
RUN rm -f ${FILE}
RUN apt purge -y --auto-remove curl

# Copy scripts and pulse audio settings
COPY files/wrapper /sbin/wrapper
COPY files/entrypoint.sh /sbin/entrypoint.sh
COPY files/pulse-client.conf /etc/pulse/client.conf

# Proceed to the entry point
ENTRYPOINT ["/sbin/entrypoint.sh"]
