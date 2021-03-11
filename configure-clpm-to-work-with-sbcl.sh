#!/usr/bin/env bash

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
  clpm client source-registry.d > $asdf_source_registry
}

function setup_sbcl_init_file() {
  local sbcl_init_file=$HOME/.sbclrc
  echo "Setting up lisp init config in $sbcl_init_file" > /dev/stderr
  # backup the init file if it exists
  [ -f $sbcl_init_file ] && \
    mv $sbcl_init_file $sbcl_init_file.`date +%s`.bak
  clpm client rc > $sbcl_init_file
}

function configure_clpm_to_work_with_sbcl() {
  mkdir -p $HOME/.config/clpm
  mkdir -p $HOME/.config/common-lisp/source-registry.conf.d
  setup_clpm_integration
  setup_asdf_clpm_client
  setup_sbcl_init_file
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
  echo "Done" > /dev/stderr
}

if [ "$1" == "cleanup" ]; then
    cleanup_clpm_config_and_cache
else
    configure_clpm_to_work_with_sbcl
fi
