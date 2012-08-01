
require 'pony'

begin
  address = ARGV[0]
  msgcount = ARGV.count - 1
  msgbody = ""

  for i in 1..msgcount
    msgbody << " #{ARGV[i]}"
  end

  Pony.mail(:to => address, :via => :smtp, :via_options => {
    :address              => 'smtp.gmail.com',
    :port                 => '587',
    :enable_starttls_auto => true,
    :user_name            => 'mspire.simulator',
    :password             => 'chromatography',
    :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
    :domain               => "localhost.localdomain" # the HELO domain provided by the client to the server
    }, 
    :subject => 'Mspire-Simulator', :body => msgbody
  )
rescue
  puts "Email function failed. Check email address and internet connection."
end
