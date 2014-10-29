require File.expand_path(File.join(File.dirname(__FILE__), '..', 'mongodb'))
Puppet::Type.type(:mongodb_database).provide(:mongodb, :parent => Puppet::Provider::Mongodb) do

  require 'date'

  desc "Manages MongoDB database."
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
    run(
      @resource[:privileged],
      @resource[:root_user],
      @resource[:root_password],
      @resource[:name],
      '--quiet',
      '--eval',
      "db.provisioning.insert({createdAt: ISODate('#{DateTime.now.strftime('%FT%T%:z')}')})"
    )
  end

  def destroy
    run(
      @resource[:privileged],
      @resource[:root_user],
      @resource[:root_password],
      @resource[:name],
      '--quiet',
      '--eval',
      'db.dropDatabase()'
    )
  end

  def exists?
    block_until_mongodb(@resource[:tries])
    run(
      @resource[:privileged],
      @resource[:root_user],
      @resource[:root_password],
      '--quiet',
      '--eval',
      'db.getMongo().getDBNames()'
    ).chomp.split(",").include?(@resource[:name])
  end

end
