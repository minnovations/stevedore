module Stevedore
  class Docker
    def initialize(options={})
      @container_image_name = Project.name
      @container_image_name_pushed = "#{ENV['AWS_ECR_REGISTRY']}/#{Project.name}:#{Project.scm_commit}"
      @container_name = Project.name + '-' + Array.new(8) { [*'0'..'9'].sample }.join
      @container_app_dir = '/srv/app'
      @docker_host_ip = (Project.inside_container? ? nil : %x[ipconfig getifaddr $(route get default | grep interface: | xargs | cut -d ' ' -f 2)].chomp)
      @docker_run_common_opts = "--name #{@container_name} -e DOCKER_HOST_IP=#{@docker_host_ip} -i -t -v #{Project.root_dir}:#{@container_app_dir}"
    end


    # Container image

    def build_container_image
      # To-do:
      # Scan Dockerfile for ARGs before including them as build args

      tmp_dir = Dir.mktmpdir
      system("git archive HEAD | tar -C #{tmp_dir} -x")
      system("cd #{tmp_dir} && docker build -t #{@container_image_name} --build-arg CONTAINER_IMAGE_BUILD_TIME=#{Time.now.utc.to_i} --build-arg CONTAINER_IMAGE_SCM_COMMIT=#{Project.scm_commit} .")
      remove_dangling_container_images
    ensure
      FileUtils.rm_rf(tmp_dir) unless tmp_dir.nil?
    end

    def push_container_image
      build_container_image
      system("docker tag #{@container_image_name} #{@container_image_name_pushed}")
      system("docker login -u AWS -p #{Aws.new.get_ecr_token} #{ENV['AWS_ECR_REGISTRY']}")
      system("docker push #{@container_image_name_pushed}")
      system("docker logout #{ENV['AWS_ECR_REGISTRY']}")
      system("docker rmi #{@container_image_name_pushed}")
    end

    def remove_dangling_container_images
      system('IMAGES=$(docker images -f dangling=true -q) ; if [ "${IMAGES}" != "" ] ; then echo ${IMAGES} | xargs docker rmi > /dev/null ; fi')
    end

    def update_container_image
      system("docker commit #{@container_name} #{@container_image_name}")
      remove_dangling_container_images
    end


    # Container

    def remove_container
      system("(docker ps -a | grep -q #{@container_name}) && docker rm -f #{@container_name} > /dev/null")
    end

    def run_container(docker_run_opts, command)
      system("docker run #{@docker_run_common_opts} #{docker_run_opts} #{@container_image_name} #{command}")
    end
  end
end
