require 'facter'
require 'open-uri'

#$::aws_key = hiera('aws_id')
#$::aws_secret = hiera('aws_secret')
server_region = "XXXXXX"

my_region = "XXXXX"
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

#mymac=Facter::Util::Resolution.exec("facter macaddress_eth0")
mymac = Facter.value(:macaddress_eth0)
myvpcid = Facter::Util::Resolution.exec("curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/#{mymac}/vpc-id/")
#print mymac
#print myvpcid
case myvpcid
    when 'vpc-XXXX'
            vpcname = 'Prod'
    when 'vpc-XXXX'
            vpcname = 'MgMt'
    when 'vpc-XXXXX'
            vpcname = 'Stage'
    when 'vpc-XXXXX'
            vpcname = 'ProdV'
    else
            vpcname = 'Not available'
end
#print vpcname
Facter.add('ec2instance_tagz_vpcname') { setcode { vpcname } }

ino = eval(tags)['Name'].split('-')[-2].to_i
Facter.add('ec2instance_tagz_ino') { setcode { ino } }
