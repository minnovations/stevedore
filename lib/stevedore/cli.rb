module Stevedore
  class Cli
    STATUS_SUCCESS = 0
    STATUS_FAIL = 1
    SUPPORTED_COMMANDS = %w[build run push deploy help]
    SUPPORTED_RUN_COMMANDS = %w[bash bundle rails rake]
    SUPPORTED_DEPLOY_COMMANDS = %w[create update destroy]

    def initialize
      @argv = ARGV.dup
      @options = {}
      @command = nil
      @command_args = nil
    end


    # Parse command line arguments to extract the options, the Stevedore
    # command and the arguments for the Stevedore command

    def start
      parse_args

      if @command.nil?
        # No supported command specified
        puts Help.help
        exit STATUS_FAIL
      else
        load_env_file unless @command == 'help'
        self.send('process_' + @command)
        exit STATUS_SUCCESS
      end
    end

    def parse_args
      command_index = @argv.find_index { |arg| SUPPORTED_COMMANDS.include?(arg) }
      return if command_index.nil?

      # Extract options
      if command_index > 0
        options_args = @argv[0..(command_index - 1)]
        OptionParser.new do |opts|
          opts.on('-eENV_FILE') do |env_file|
            @options[:env_file] = env_file
          end

          opts.on('--skip-push') do |skip_push|
            @options[:skip_push] = skip_push
          end
        end.parse!(options_args)
      end

      @command = @argv[command_index]
      @command_args = @argv[(command_index + 1)..-1]
    end

    def load_env_file
      env_file = @options[:env_file] || '.env.deployment'

      if File.exists?(env_file)
        Dotenv.load(env_file)
      else
        puts 'No env file loaded'
      end
    end


    # Process the Stevedore command

    def process_build
      Docker.new.build_container_image
    end

    def process_run
      run_command = @command_args.first
      run_command_args = @command_args[1..-1]

      if SUPPORTED_RUN_COMMANDS.include?(run_command)
        Run.send(run_command, run_command_args)
      else
        puts Help.run
        exit STATUS_FAIL
      end
    end

    def process_push
      Docker.new.push_container_image
    end

    def process_deploy
      deploy_command = @command_args.first

      deploy_opts = {}
      deploy_opts.merge!(skip_push: true) if @options[:skip_push] == true

      if SUPPORTED_DEPLOY_COMMANDS.include?(deploy_command)
        Deploy.send(deploy_command, deploy_opts)
      else
        puts Help.deploy
        exit STATUS_FAIL
      end
    end

    def process_help
      help_topic = @command_args.first

      if SUPPORTED_COMMANDS.include?(help_topic)
        puts Help.send(help_topic)
      else
        puts Help.help
      end
    end
  end
end
