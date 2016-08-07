module Stevedore
  class Deploy
    class << self
      def create(options={})
        Docker.new.push_container_image unless options[:skip_push] == true
        Aws.new.create_cloud_formation_stack
      end

      def update(options={})
        Docker.new.push_container_image unless options[:skip_push] == true
        Aws.new.update_cloud_formation_stack
      end

      def destroy(options={})
        Aws.new.delete_cloud_formation_stack
      end
    end
  end
end
