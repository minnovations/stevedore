module Stevedore
  class Project
    class << self
      def inside_container?
        File.exists?('/.dockerenv')
      end

      def name
        ENV['PROJECT_NAME'] || File.basename(root_dir).downcase.tr('\ ', '')[0,32]
      end

      def root_dir
        Dir.pwd
      end

      def scm_commit
        ENV['SCM_COMMIT'] || (system('git rev-parse HEAD > /dev/null') ? %x[git rev-parse HEAD].chomp : nil)
      end
    end
  end
end
