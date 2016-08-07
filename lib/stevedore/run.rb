module Stevedore
  class Run
    class << self
      def bash(args, options={})
        default(%w[bash])
      end

      def bundle(args, options={})
        if args.first == 'install'
          docker = Docker.new
          docker.run_container(nil, 'bundle install')
          docker.update_container_image
          docker.remove_container
        else
          puts Help.run
        end
      end

      def rails(args, options={})
        if %w[server s].include?(args.first)
          docker = Docker.new
          begin
            docker.run_container('-p 3000:3000', "rails server -b 0.0.0.0 #{args[1..-1].join(' ')}")
          rescue Interrupt
          ensure
            FileUtils.rm_f("#{Project.root_dir}/tmp/pids/server.pid")
          end
          docker.remove_container
        else
          default(%w[rails] + args)
        end
      end

      def rake(args, options={})
        default(%w[rake] + args)
      end

      private
      def default(args, options={})
        docker = Docker.new
        docker.run_container(nil, args.join(' '))
        docker.remove_container
      end
    end
  end
end
