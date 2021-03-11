#!/usr/bin/env bash

ROS_LAUNCHER_PATH="/usr/local/bin/sbcl"

function setup_clpm_integration() {
  local sources=$HOME/.config/clpm/sources.conf
  echo "Setting up CLPM/ASDF integration using ql-clpi in $sources" > /dev/stderr
  mkdir -p $HOME/.config/clpm
  echo $'("quicklisp"\n  :type :ql-clpi\n  :url "https://quicklisp.common-lisp-project-index.org/")' > $sources
}

function setup_asdf_clpm_client() {
  local asdf_source_registry=$HOME/.config/common-lisp/source-registry.conf.d/20-clpm-client.conf
  echo "Setting up CLPM source registry in $asdf_source_registry" > /dev/stderr
  mkdir -p $HOME/.config/common-lisp/source-registry.conf.d
  clpm client install
  clpm client source-registry.d > $asdf_source_registry
}

function setup_roswell_init_file() {
  local roswell_init_file=$HOME/.roswell/init.lisp
  echo "Setting up lisp init config in $roswell_init_file" > /dev/stderr
  # backup the roswell init file if it exists
  [ -f $roswell_init_file ] && \
    mv $roswell_init_file $roswell_init_file.`date +%s`.bak
  clpm client rc > $roswell_init_file
}

# This creates a bash script to launch sbcl via roswell with a single command
# to work around clpm 0.3 issues with subcommands:
# https://gitlab.common-lisp.net/clpm/clpm/-/issues/19
function create_ros_sbcl_bash() {
  echo "Using sudo to create Roswell SBCL launcher in $ROS_LAUNCHER_PATH" > /dev/stderr
  sudo echo $'#!/bin/sh\n\nexec ros run == "$@"\n' > $ROS_LAUNCHER_PATH && \
    sudo chmod 755 $ROS_LAUNCHER_PATH
}

function setup_clpm_config() {
  local clpm_config_path=$HOME/.config/clpm/clpm.conf
  echo "Setting up CLPM config in $clpm_config_path" > /dev/stderr
  mkdir -p $HOME/.config/clpm
  echo '(version "0.2")' > $clpm_config_path
  echo >> $clpm_config_path
  echo "((:grovel :lisp)" >> $clpm_config_path
  echo " :implementation :sbcl" >> $clpm_config_path
  echo "  :path \"$ROS_LAUNCHER_PATH\")" >> $clpm_config_path
}

function configure_clpm_to_work_with_sbcl_via_roswell() {
  mkdir -p $HOME/.config/clpm
  mkdir -p $HOME/.config/common-lisp/source-registry.conf.d
  setup_clpm_integration
  setup_asdf_clpm_client
  setup_roswell_init_file
  create_ros_sbcl_bash
  setup_clpm_config
  echo "Done" > /dev/stderr
}

function cleanup_clpm_config_and_cache() {
  echo "Removing $HOME/.config/clpm" > /dev/stderr
  rm -rf $HOME/.config/clpm
  echo "Removing $HOME/.config/common-lisp" > /dev/stderr
  rm -rf $HOME/.config/common-lisp
  echo "Removing $HOME/.cache/clpm" > /dev/stderr
  rm -rf $HOME/.cache/clpm
  echo "Removing $HOME/.cache/common-lisp" > /dev/stderr
  rm -rf $HOME/.cache/common-lisp
  echo "Removing $HOME/.local/share/clpm" > /dev/stderr
  rm -rf $HOME/.local/share/clpm
  echo "Removing $HOME/.roswell/init.lisp" > /dev/stderr
  rm -rf $HOME/.roswell/init.lisp
  echo "Removing /usr/local/bin/sbcl" > /dev/stderr
  sudo rm -rf /usr/local/bin/sbcl
  echo "Done" > /dev/stderr
}

if [ "$1" == "cleanup" ]; then
    cleanup_clpm_config_and_cache
else
    configure_clpm_to_work_with_sbcl_via_roswell
fi
