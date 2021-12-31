user_config = {
  'cpus' => 3,
  'memory' => 16384,
  'disksize' => '30GB',
  'ip' => '192.168.50.10',
  'provision_file' => [
    './.files/.bash_aliases:/root/.bash_aliases',
    './.files/.bundle/config:/root/.bundle/config'
  ],
  'fowarding_ports' => %w[3306 1080],
  'environment' => {
    'BUNDLE_RUBYGEMS__PKG__GITHUB__COM' => nil
  }
}

Vagrant.configure('2') do |c|
  c.vm.define 'aki2o-dev' do |config|
    config.vm.box = 'ubuntu/focal64'
    config.vm.hostname = 'aki2o-dev'

    config.vm.network :private_network, ip: user_config['ip']
    user_config['fowarding_ports'].map(&:to_i).each do |port|
      config.vm.network :forwarded_port, guest: port, host: port, protocol: "tcp"
      config.vm.network :forwarded_port, guest: port, host: port, protocol: "udp"
    end

    config.vm.provider :virtualbox do |vb|
      vb.gui = false
      vb.cpus = user_config['cpus']
      vb.memory = user_config['memory']
      vb.customize ['modifyvm', :id, '--natdnsproxy1', 'off']
      vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'off']
    end

    config.disksize.size = user_config['disksize']

    # ファイル同期は mutagen を使う
    config.vm.synced_folder ".", "/vagrant", disabled: true

    config.ssh.username = ENV.fetch('VAGRANT_SSH_USER', 'root')
    config.ssh.forward_agent = true

    Dir.glob("#{ENV['HOME']}/.ssh/*").each do |path|
      next unless FileTest.file?(path)

      file_name   = File.basename(path)
      next if file_name == 'authorized_keys'
      next if file_name == 'known_hosts'

      tmp_file    = "/tmp/#{file_name}"
      destination = "/root/.ssh/#{file_name}"

      config.vm.provision 'file', source: path, destination: tmp_file
      config.vm.provision 'shell', inline: "sudo mv #{tmp_file} #{destination} && sudo chown root:root #{destination}"
    end

    [
      './.files/60-inotify-limit.conf:/etc/sysctl.d/60-inotify-limit.conf',
      './.files/multipath.conf:/etc/multipath.conf',
      './.files/.profile:/root/.profile',
      *user_config['provision_file']
    ].each do |path_mapping|
      host_path, guest_path = path_mapping.split(':')
      source                = host_path.sub(/\A~/, ENV['HOME'])
      destination           = (guest_path || host_path).sub(/\A~/, '/root')
      tmp_file              = "/tmp/#{destination}"

      config.vm.provision 'file', source: source, destination: tmp_file
      config.vm.provision 'shell', inline: "sudo mkdir -p #{File.dirname(destination)} && sudo mv #{tmp_file} #{destination} && sudo chown root:root #{destination}"
    end
    config.vm.provision 'shell', inline: <<~EOS
      sudo sysctl --system
      sudo systemctl restart multipathd.service
    EOS

    config.vm.provision 'shell', inline: <<~EOS
      # Install docker
      curl -fsSL https://get.docker.com -o get-docker.sh
      sh get-docker.sh

      # Install docker compose
      curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
      chmod +x /usr/local/bin/docker-compose

      # Install package
      sudo apt update && sudo apt install -y --no-install-recommends build-essential && sudo rm -rf /var/lib/apt/lists/* /var/cache/apt/*

      # TZ
      sudo timedatectl set-timezone Asia/Tokyo

      # https://github.com/moby/moby/issues/22635
      sudo bash -c "sed -i 's/^#DNS=.*$/DNS=8.8.8.8/' /etc/systemd/resolved.conf"

      # https://qiita.com/shora_kujira16/items/31d09b373809a5a44ae5
      sudo bash -c "sed -i 's/^#DNSStubListener=.*$/DNSStubListener=no/' /etc/systemd/resolved.conf"
      sudo ln -sf ../run/systemd/resolve/resolv.conf /etc/resolv.conf
      sudo systemctl restart systemd-resolved

      # Config to let ssh user be root
      sudo cp /home/vagrant/.ssh/authorized_keys /root/.ssh/

      # Init environment
      sudo echo -n '' > /etc/profile.d/inherit_local_env.sh

      # Create sync root
      sudo mkdir -p /usr/src/app
    EOS

    user_config['environment'].each do |name, value|
      config.vm.provision :shell, inline: "echo export #{name}='#{value || ENV[name]}' >> /etc/profile.d/inherit_local_env.sh"
    end
  end
end
