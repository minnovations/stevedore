module Stevedore
  class Aws
    def initialize
      ::Aws.config.update(
        region: ENV['AWS_REGION'],
        credentials: ::Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
      )
      @cf = ::Aws::CloudFormation::Client.new
      @ecr = ::Aws::ECR::Client.new
    end


    # Cloud Formation

    def create_cloud_formation_stack
      validate_cloud_formation_template

      resp = @cf.create_stack(
        stack_name: Project.name,
        template_body: cloud_formation_template,
        tags: [
          {
            key: 'Name',
            value: Project.name
          }
        ]
      )

      wait_cloud_formation(:stack_create_complete, stack_name: resp.stack_id)
    end

    def delete_cloud_formation_stack
      @cf.delete_stack(stack_name: Project.name)
      wait_cloud_formation(:stack_delete_complete, stack_name: Project.name)
    end

    def update_cloud_formation_stack
      validate_cloud_formation_template

      resp = @cf.update_stack(
        stack_name: Project.name,
        template_body: cloud_formation_template
      )

      wait_cloud_formation(:stack_update_complete, stack_name: resp.stack_id)
    end

    def validate_cloud_formation_template
      @cf.validate_template(template_body: cloud_formation_template)
    end


    # ECR

    def get_ecr_token
      raw_token = @ecr.get_authorization_token.authorization_data.first.authorization_token
      Base64.decode64(raw_token).split(':').last
    end


    private

    def cloud_formation_template
      ERB.new(File.read("#{Project.root_dir}/#{ENV['AWS_CLOUD_FORMATION_TEMPLATE_PATH'] || 'cloud_formation_template.json'}"), nil, '%<>-').result(binding)
    end

    def wait_cloud_formation(waiter_name, params={})
      print "Waiting for #{waiter_name} "
      @cf.wait_until(waiter_name, params) do |w|
        w.before_wait { print '.' }
      end
      puts ' Done'
    end
  end
end
