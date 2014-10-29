Puppet::Type.newtype(:mongodb_database) do

  @doc = "Manage MongoDB databases."

  ensurable

  newparam(:name, :namevar=>true) do
    desc "The name of the database."
    newvalues(/^\w+$/)
  end

  newparam(:tries) do
    desc "The maximum amount of two second tries to wait MongoDB startup."
    defaultto 10
    newvalues(/^\d+$/)
    munge do |value|
      Integer(value)
    end
  end

  newparam(:privileged) do
    desc "If the service is protected via auth we need to work on the user as root."
    defaultto false
  end

  newparam(:root_user) do
    desc "The username of the root user."
    defaultto false
    newvalues(/^\w+$/)
  end

  newparam(:root_password) do
    desc "The password of the root user."
    defaultto false
  end

  autorequire(:package) do
    'mongodb_client'
  end

  autorequire(:service) do
    'mongodb'
  end

end
