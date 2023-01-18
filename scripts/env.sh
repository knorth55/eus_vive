#!/usr/bin/env bash

# shellcheck source=/dev/null
if [ -e "$HOME/ros/baxter_ws/" ]; then
  source "$HOME/ros/baxter_ws/devel/setup.bash"
fi
if [ -e "$HOME/ros/teleop_ws/" ]; then
  source "$HOME/ros/teleop_ws/devel/setup.bash"
fi
exec "$@"
