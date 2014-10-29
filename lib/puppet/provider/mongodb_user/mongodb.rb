require File.expand_path(File.join(File.dirname(__FILE__), '..', 'mongodb'))
Puppet::Type.type(:mongodb_user).provide(:mongodb, :parent => Puppet::Provider::Mongodb) do

  require 'json'
  require 'digest/md5'
  desc "Manage users for a MongoDB database."
  defaultfor :kernel => 'Linux'
  commands :mongo => 'mongo'

  def block_until_mongodb(tries = 10)
    begin
      run(
        @resource[:privileged],
        @resource[:root_user],
        @resource[:root_password],
        '--quiet',
        '--eval',
        'db.getMongo()'
      )
    rescue => e
      debug('MongoDB server not ready, retrying')
      sleep 2
      if (tries -= 1) > 0
        retry
      else
        raise e
      end
    end
  end

  def create
    command = {
      'user' => @resource[:name],
      'pwd' => @resource[:password],
      'roles' => @resource[:roles]
    }

    run(
      @resource[:privileged],
      @resource[:root_user],
      @resource[:root_password],
      @resource[:database],
      '--quiet',
      '--eval',
      "db.createUser(#{command.to_json})"
    )
  end

  def destroy
    run(
      @resource[:privileged],
      @resource[:root_user],
      @resource[:root_password],
      @resource[:database],
      '--quiet',
      '--eval',
      "db.dropUser('#{@resource[:name]}')"
    )
  end

  def exists?
    block_until_mongodb(@resource[:tries])
    !run(
      @resource[:privileged],
      @resource[:root_user],
      @resource[:root_password],
      @resource[:database],
      '--quiet',
      '--eval',
      "db.getUser('#{@resource[:name]}')"
    ).to_s.strip.eql?('null')
  end

  def password
    genhash = Digest::MD5.hexdigest("#{@resource[:name]}:mongo:#{@resource[:password]}").to_s
    debug('Generated hash => ' + genhash)

    recvhash = run(
      @resource[:privileged],
      @resource[:root_user],
      @resource[:root_password],
      'admin',
      '--quiet',
      '--eval',
      "db.system.users.findOne({user: '#{@resource[:name]}'}).credentials['MONGODB-CR']"
    ).to_s.strip

    debug('Received hash => ' + recvhash)
    debug('Hashs eql? => ' + genhash.eql?(recvhash).to_s)

    # If the received hash is equal to the genereated
    # the password is up to date. So we pass the original
    # injected back to puppet
    genhash.eql?(recvhash) ? @resource[:password] : recvhash
  end

  def password=(value)
    command = {
      'pwd' => value,
    }

    run(
      @resource[:privileged],
      @resource[:root_user],
      @resource[:root_password],
      @resource[:database],
      '--quiet',
      '--eval',
      "db.updateUser('#{@resource[:name]}', #{command.to_json})"
    )
  end

  def roles
    run(
      @resource[:privileged],
      @resource[:root_user],
      @resource[:root_password],
      @resource[:database],
      '--quiet',
      '--eval',
      "db.getUser(\"#{@resource[:name]}\").roles.forEach(function(item) {print(item.role+',')})"
    ).to_s.delete("\n").strip.split(',').sort
  end

  def roles=(value)
    command = {
      'roles' => value,
    }

    run(
      @resource[:privileged],
      @resource[:root_user],
      @resource[:root_password],
      @resource[:database],
      '--quiet',
      '--eval',
      "db.updateUser('#{@resource[:name]}', #{command.to_json})"
    )
  end

end
