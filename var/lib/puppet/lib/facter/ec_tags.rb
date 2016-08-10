require 'facter'
require 'open-uri'

#$::aws_key = hiera('aws_id')
#$::aws_secret = hiera('aws_secret')
server_region = "ap-southeast-1XXX"

my_region = "ap-southeast-1"
my_instanceid = open('http://169.254.169.254/latest/meta-data/instance-id/').read
my_aws_key =  'XXXXXXX'
my_aws_secret = 'XXXXXXXX'
#puts my_region
#puts my_instanceid


tags = Facter::Util::Resolution.exec("echo \"{\`ec2-describe-tags -O '#{my_aws_key}' -W '#{my_aws_secret}' --region #{my_region}  --filter \"resource-id=#{my_instanceid}\" | cut -f 4-|awk -F' ' '{print \"\\\\x27\"\$1 \"\\\\x27\" \" => \" \"\\\\x27\" \$2 \$3 \$4 \$5 \$6 \$7 \$8 \$9 \"\\\\x27\"\",\"}'           \`}\"")

eval(tags).each do |key, value|
 fact = "ec2instance_tagz_#{key}"
 Facter.add(fact) { setcode { value } }
end

ino = eval(tags)['Name'].split("-")[-2].to_i
Facter.add("ec2instance_tagz_ino") { setcode {ino} }
