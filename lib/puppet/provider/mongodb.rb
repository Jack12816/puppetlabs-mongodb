class Puppet::Provider::Mongodb < Puppet::Provider

  # Without initvars commands won't work.
  initvars
  commands :mongo => 'mongo'

  def run(privileged, user, password, *args)

    if privileged
      args.unshift('-u', user)
      args.unshift('-p', password)
      args.unshift('--authenticationDatabase', 'admin')
    end

    tries = 2

    begin
      mongo(args)
    rescue => e
      if !privileged
        if (tries -= 1) > 0
          debug('Maybe auth failed, retry as root')
          args.unshift('-u', user)
          args.unshift('-p', password)
          args.unshift('--authenticationDatabase', 'admin')
          retry
        else
          raise e
        end
      else
        raise e
      end
    end
  end

end
