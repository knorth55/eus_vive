#!/usr/bin/env bash

# shellcheck source=/dev/null
if [ -e "$HOME/ros/baxter_ws/" ]; then
  source "$HOME/ros/baxter_ws/devel/setup.bash"
fi
if [ -e "$HOME/ros/vive_ws/" ]; then
  source "$HOME/ros/vive_ws/devel/setup.bash"
fi
exec "$@"
