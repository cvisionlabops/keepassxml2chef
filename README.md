keepassxml2chef
===============

Script to create/update data bags via chef-vault from exported keepassx plaintext xml file on chef server/solo data bags

Create an empty keepassx database. Tested on Keepassx 0.4.3 (ubuntu 12.04)

Create a group (data bag) in root. For example `ldap_users_of_our_domain`

Create data bag item as standart keepassx record's with one level of nesting!

Keepass name is data bag item name.
`srvadm@ldapserver.example.com`

Username field is username in a data bag item.
`srvadm`

Password field is plaintext password or other sensitive information in a data bag item.
`strongplaintextpassword`

Url field is chef server user name's separated by commas (Chef clients or users to be vault admins, can be comma list).
`admin,alibaba,admin2,sysadmin`
Default `admin`, can be empty.

Comment field is Chef Server SOLR Search Of Nodes.
`name:name:*.example.local`
Cannot be empty!


Save keepass db. And export as `KeepassX XML file (*.xml)`

It is understood that the knife is already configured to access the chef server

Configure chef vault in knife.rb! 

Clone repo and run script:

`$ cd`
`$ git clone https://github.com/cvisionlabops/keepassxml2chef`
`$ cd keepassxml2chef`

Run creating/updating script:

`$ keepassxml2chef path_to_exported_keepass_plaintext_xml_file`

