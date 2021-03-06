version = 6

pkgs = value_for_platform(["centos","redhat","fedora","scientific","amazon"] => {
                            "default" => ["java-1.#{version}.0-openjdk","java-1.#{version}.0-openjdk-devel"]
                          },
                          ["arch","freebsd"] => {
                            "default" => ["openjdk#{version}"]
                          },
                          "default" => ["openjdk-#{version}-jdk"])

# once we test the waters and write the announcement, this will be moved to the
# openjdk7 recipe. MK.
execute "update-java-alternatives" do
  base        = "java-1.6.0-openjdk"
  alternative = case [node[:platform], node[:platform_version]]
                when ["ubuntu", "11.10"] then
                  base
                when ["ubuntu", "12.04"] then
                  "#{base}-i386"
                else
                  base
                end

  command "update-java-alternatives -s #{alternative}"
  returns [0,2]
  action :nothing
  only_if { platform?("ubuntu", "debian") }
end

pkgs.each do |pkg|
  package pkg do
    action :install
    notifies :run, resources(:execute => "update-java-alternatives")
  end
end
