# Stevedore

Stevedore is a handy workflow helper to make developing and deploying apps with Docker containers a little easier.


## Installation

Stevedore is written as a Ruby CLI app and installed as a Ruby gem. You will need to have Ruby (v2.0.0 or higher) running on your Linux or Mac OS system as a prerequisite.

```
gem install specific_install
gem specific_install https://github.com/minnovations/stevedore.git
```

Upon installation of the gem, you will be able to access Stevedore through the "steve" command on the command line.


## Usage

Type "steve help" for a list of sub-commands and options.

```
$ steve help

Stevedore is a handy helper to make developing and deploying apps with Docker
containers a little easier.

  Usage:
    steve [options] command [arguments]
    steve [-e ENV_FILE] build|run|push|deploy|help [arguments]

  Examples:
    steve build
    steve run rails s
    steve -e .env deploy update

  Further help:
    steve help (this help message)
    steve help build
    steve help run
    steve help push
    steve help deploy

Copyright 2016, M Innovations

```
