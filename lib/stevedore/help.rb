module Stevedore
  class Help
    class << self
      def help
        <<-eos

Stevedore is a handy helper to make developing and deploying apps with Docker
containers a little easier.

  Usage:
    steve [options] command [arguments]
    steve [-e ENV_FILE] #{Cli::SUPPORTED_COMMANDS.join('|')} [arguments]

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

eos
      end


      def build
        <<-eos

Usage: steve build

eos
      end


      def run
        <<-eos

Usage: steve run bash|bundle install|rails [rails args]|rake [rake args]

eos
      end


      def push
        <<-eos

Usage: steve push

eos
      end


      def deploy
        <<-eos

Usage: steve deploy create|update|destroy

eos
      end
    end
  end
end
