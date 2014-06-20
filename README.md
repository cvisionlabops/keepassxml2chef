keepassxml2chef
===============

Script to create/update data bags via chef-vault from exported keepassx plaintext xml file on chef server/solo data bags

Store username & passwords in keepassx db. Update chef server databags with this sciprt by pass to script exported plaintext xml.

## Know ISSUE's

TODO: Add support for save in keepass record pasword field values with quotes.

## Prepare passwords keepassx db

Create an empty keepassx database. Tested on Keepassx 0.4.3 (ubuntu 12.04 and 14.04)

Supports only one level of nesting.

```
Group(data bag)	-> Record 1 (data bag item)

		-> Record 2 (data bag item)
```

Create a group (data bag) in root. For example `ldap_users_of_our_domain`

Create data bag item as standart keepassx record's

Attention! Record name is not a data bag item name.

For example title of record `srvadm@ldapserver.example.com` in group `ldap_users_of_our_domain` is not a data bag item name!

Script uses *USERNAME* field in a record `srvadm@ldapserver.example.com` as a data bag item. This field is required and must be unique in databag's list!

`srvadm`

*PASSWORD* field is plaintext password or other sensitive information in a data bag item:

`strongplaintextpassword`


*URL* field is chef server user name's separated by commas (Chef clients or users to be vault admins, can be comma list):

`admin,alibaba,admin2,sysadmin`

Default `admin`, can be empty.


*COMMENT* field is Chef Server SOLR Search Of Nodes:

`name:name:*.example.local`

Cannot be empty!


Save keepass db. And export as `KeepassX XML file (*.xml)`

## Usage

Clone repo and run script:

`$ cd`

`$ git clone https://github.com/cvisionlabops/keepassxml2chef`

`$ cd keepassxml2chef`

Source rvm ruby if you use Ruby Version Manager instead of system ruby (recommended)

`$ source ~/.rvm/scripts/rvm`

Install nokogiri, chef-vault, chef

`$ bundle`

Configure knife to access the chef server.

Configure chef vault in knife.rb! 

Run creating/updating script:

`$ keepassxml2chef path_to_exported_keepass_plaintext_xml_file`


## Usage in recipe:

You can use these bags in recipes as follows:

```ruby
  chef_gem "chef-vault"
  require 'chef-vault'
  item = ChefVault::Item.load("ldap_users_of_our_domain", "srvadm")
  user = item["id"]
  pass = item["password"]
# Next use user and pass variables where necessary
```



## Thanks


To Kevin Moser ( https://github.com/Nordstrom/chef-vault )
