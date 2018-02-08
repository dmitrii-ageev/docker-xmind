#!/bin/bash
set -e

USER_UID=${USER_UID:-1000}
USER_GID=${USER_GID:-1000}
APP_USER=$(echo $APPLICATION|head -c 8)

install_application() {
  echo "Installing ${APPLICATION}..."
  install -m 0755 /sbin/wrapper /target/${APPLICATION}
}

uninstall_application() {
  echo "Uninstalling ${APPLICATION}..."
  rm -rf /target/${APPLICATION}
}

create_user() {
  # create group with USER_GID
  if ! getent group ${APP_USER} >/dev/null; then
    groupadd -f -g ${USER_GID} ${APP_USER} >/dev/null 2>&1
  fi

  # create user with USER_UID
  if ! getent passwd ${APP_USER} >/dev/null; then
    useradd --uid ${USER_UID} --gid ${USER_GID} --groups audio,video -m ${APP_USER} >/dev/null 2>&1
  fi
  chown ${APP_USER}:${APP_USER} -R /home/${APP_USER}
}

grant_access_to_video_devices() {
  for device in /dev/video*
  do
    if [[ -c $device ]]; then
      VIDEO_GID=$(stat -c %g $device)
      VIDEO_GROUP=$(stat -c %G $device)
      if [[ ${VIDEO_GROUP} == "UNKNOWN" ]]; then
        VIDEO_GROUP=${APPLICATION}video
        groupadd -g ${VIDEO_GID} ${VIDEO_GROUP} 2>&1 >/dev/null
      fi
      gpasswd -a ${APP_USER} ${VIDEO_GROUP}
      break
    fi
  done
}

launch_application() {
  cd /home/${APP_USER}
  export PULSE_SERVER=/run/pulse/native
  export PULSE_LATENCY_MSEC=30
  export QT_GRAPHICSSYSTEM=native
  exec sudo -HEu ${APP_USER} ${EXECUTABLE:-$APPLICATION}
}

case "$1" in
  install)
    install_application
    ;;
  uninstall)
    uninstall_application
    ;;
  reinstall)
    uninstall_application
    install_application
    ;;
  *)
    create_user
    grant_access_to_video_devices
    launch_application
    ;;
esac
