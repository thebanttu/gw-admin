## Introduction

Over the years I have used this hodgepodge of scripts to various degrees of
success to "install" and manage the kannel messaging gateway as stated on the
tin.

The install part of it was always hit and miss. I have therefore succumbed to
the pressure to adopt configuration management to smooth over the bumps that I
was running into trying to reliably install a working and configured gateway.

I went with saltstack and that is what this branch is, a salt state to install
and configure the gateway to a working minimum.

## Clone this repo to a sensible directory
I suggest ~/cm/gw but that's a matter of preference (or taste).

## Checkout the salt-gw-admin branch
This goes without saying.

## Install salt
`curl -o bootstrap-salt.sh -L https://bootstrap.saltproject.io` \
`sudo sh bootstrap-salt.sh git master`

## Make the salt minion execute local states
`sed -i '/^#\s*file_client:/s/.*/file_client: local/' /etc/salt/minion`

## Make salt aware of the kannel salt state and pillar
`here=$(pwd)` \
`mkdir -p /srv/{salt,pillar}` \
`ln -svf ${here}/kannel /srv/salt/kannel` \
`ln -svf ${here}/pillar /srv/pillar/kannel` \
`unset -v here`

## Stop the salt-minion
`systemctl stop salt-minion`

Please note that systemd has been pre-supposed because it is pretty much
everywhere on linux and that is usually the target system for running the
gateway.

## Apply the salt state
`salt-call --local state.apply kannel`
