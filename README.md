# Graylog Puppet Module

[![Build Status](https://github.com/Graylog2/puppet-graylog/actions/workflows/validate.yml/badge.svg)](https://github.com/Graylog2/puppet-graylog/actions?query=workflow%3Avalidate)
[![Puppet Forge](https://img.shields.io/puppetforge/v/graylog/graylog?color=green)](https://forge.puppet.com/modules/graylog/graylog)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/graylog/graylog)](https://forge.puppet.com/modules/graylog/graylog)


#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with graylog](#setup)
    * [What graylog affects](#what-graylog-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with graylog](#beginning-with-graylog)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module can be used to install and configure a Graylog system. (https://www.graylog.org/)

### Native Types

Native types to configure dashboards, inputs, streams and others are provided
by the community maintained [puppet-graylog_api](https://github.com/magicmemories/puppet-graylog_api)
module.

## Setup

### What graylog affects

The graylog module manages the following things:

* APT/YUM repository
* Graylog packages
* Graylog configuration files
* Graylog service

### Setup Requirements

The module only manages Graylog itself. You need other modules to install
the required dependencies like MongoDB and OpenSearch.

You could use the following modules to install dependencies:

* [puppet/mongodb](https://forge.puppet.com/puppet/mongodb)
* [puppet/opensearch](https://forge.puppet.com/modules/puppet/opensearch)

### Beginning with graylog

The following modules are required to use the graylog module:

* [puppetlabs/apt](https://forge.puppet.com/puppetlabs/apt)
* [puppetlabs/stdlib](https://forge.puppet.com/puppetlabs/stdlib)

Those dependencies are automatically installed if you are using the Puppet
module tool or something like [librarian-puppet](https://github.com/voxpupuli/librarian-puppet).

#### Puppet Module Tool

Use the following command to install the graylog module via the Puppet module
tool.

```
puppet module install graylog/graylog
```

#### librarian-puppet

Add the following snippet to your `Puppetfile`.

```
mod 'graylog/graylog', 'x.x.x'
```

Make sure to use the latest version of the graylog module!

## Usage

As mentioned above, the graylog module only manages the Graylog system. Other
requirements like MongoDB and OpenSearch need to be managed via
other modules.

The following config creates a setup with MongoDB, OpenSearch and Graylog
on a single node.

```puppet
class { 'mongodb::globals':
  manage_package_repo => true,
}->
class { 'mongodb::server':
  bind_ip => ['127.0.0.1'],
}

class { 'opensearch':
  version => '2.9.0',
}

class { 'graylog::repository':
  version => '6.1'
}->
class { 'graylog::server':
  package_version => '6.1.5-2',
  config          => {
    'password_secret' => '...',    # Fill in your password secret
    'root_password_sha2' => '...', # Fill in your root password hash
  }
}
```

### A more complex example

```puppet
class { '::graylog::repository':
  version => '6.1'
}->
class { '::graylog::server':
  config  => {
    is_leader                                          => true,
    node_id_file                                       => '/etc/graylog/server/node-id',
    password_secret                                    => 'password_secret',
    root_username                                      => 'admin',
    root_password_sha2                                 => 'root_password_sha2',
    root_timezone                                      => 'Europe/Berlin',
    allow_leading_wildcard_searches                    => true,
    allow_highlighting                                 => true,
    http_bind_address                                  => '0.0.0.0:9000',
    http_external_uri                                  => 'https://graylog01.domain.local:9000/',
    http_enable_tls                                    => true,
    http_tls_cert_file                                 => '/etc/ssl/graylog/graylog_cert_chain.crt',
    http_tls_key_file                                  => '/etc/ssl/graylog/graylog_key_pkcs8.pem',
    http_tls_key_password                              => 'sslkey-password',
    rotation_strategy                                  => 'time',
    retention_strategy                                 => 'delete',
    elasticsearch_max_time_per_index                   => '1d',
    elasticsearch_max_number_of_indices                => '30',
    elasticsearch_shards                               => '4',
    elasticsearch_replicas                             => '1',
    elasticsearch_index_prefix                         => 'graylog',
    elasticsearch_hosts                                => 'http://opensearch01.domain.local:9200,http://opensearch02.domain.local:9200',
    mongodb_uri                                        => 'mongodb://mongouser:mongopass@mongodb01.domain.local:27017,mongodb02.domain.local:27017,mongodb03.domain.local:27017/graylog',
  },
}
```

## Reference

### Classes

#### Public Classes

* `graylog::repository`: Manages the official Graylog package repository
* `graylog::server`: Installs, configures and manages the Graylog server service

#### Private Classes

* `graylog::params`: Default settings for different platforms
* `graylog::repository::apt`: Manages APT repositories
* `graylog::repository::yum`: Manages YUM repositories

#### Class: graylog::repository

##### `version`

This setting is used to set the repository version that should be used to install
the Graylog package. The Graylog package repositories are separated by major
version.

It defaults to `$graylog::params::major_version`.

Example: `version => '6.1'`

##### `url`

This setting is used to set the package repository url.

**Note:** The module automatically detects the url for your platform so this
setting should not be changed.

##### `proxy`

This setting is used to facilitate package installation with proxy.

##### `release`

This setting is used to set the package repository release.

**Note:** The Graylog package repositories only use `stable` as a release so
this setting should not be changed.

#### Class: graylog::server

The `graylog::server` class configures the Graylog server service.

##### `package_name`

This setting is used to choose the Graylog package name. It defaults to
`graylog-server` to install Graylog Open. You can use `graylog-enterprise`
to install the Graylog Enterprise package.

Example: `package_name => 'graylog-server'`

##### `package_version`

This setting is used to choose the Graylog package version. It defaults to
`installed` which means it installs the latest version that is available at
install time. You can also use `latest` so it will always update to the latest
stable version if a new one is available.

Example: `package_version => '6.1.5-2'`

##### `config`

This setting is used to specify the Graylog server configuration. The server
configuration consists of key value pairs. Every available config option can
be used here.

See the [example graylog.conf](https://github.com/Graylog2/graylog2-server/blob/master/misc/graylog.conf)
to see a list of available options.

Required settings:

* `password_secret`
* `root_password_sha2`

Please find some default settings in `$graylog::params::default_config`.

Example:

```
config => {
  'password_secret'    => '...',
  'root_password_sha2' => '...',
  'is_leader'          => true,
  'output_batch_size'  => 2500,
}
```

##### `user`

This setting is used to specify the owner for files and directories.

**Note:** This defaults to `graylog` because the official Graylog package uses
that account to run the server. Only change it if you know what you are doing.

##### `group`

This setting is used to specify the group for files and directories.

**Note:** This defaults to `graylog` because the official Graylog package uses
that account to run the server. Only change it if you know what you are doing.

##### `ensure`

This setting is used to configure if the Graylog service should be running or
not. It defaults to `running`.

Available options: `running`, 'stopped'

##### `enable`

This setting is used to configure if the Graylog service should be enabled.
It defaults to `true`.

##### `java_initial_heap_size`

Sets the initial Java heap size (-Xms) for Graylog. Defaults to `1g`.

##### `java_max_heap_size`

Sets the maximum Java heap size (-Xmx) for Graylog. Defaults to `1g`.

##### `java_opts`

Additional java options for Graylog. Defaults to ``.

##### `restart_on_package_upgrade`

This setting restarts the `graylog-server` service if the os package is upgraded.
It defaults to `false`.

## Limitations

Supported Graylog versions:

* 5.x

Supported platforms:

* Ubuntu/Debian
* RedHat/CentOS

## Development
You can test this module by using the associated PDK commands.

```bash
pdk validate # Ensure code style conforms to recommendations
pdk test unit --parallel # Run unit tests (in parallel)

#
# Acceptance (litmus) tests, requires docker
#
pdk bundle exec rake 'litmus:provision_list[default]'
pdk bundle exec rake 'litmus:install_agent'
pdk bundle exec rake 'litmus:install_module'
pdk bundle exec rake 'litmus:acceptance:parallel'
pdk bundle exec rake 'litmus:tear_down'
```

Please see the [CONTRIBUTING.md](CONTRIBUTING.md) and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
files for further details.

### Release New Version

1. Update and commit CHANGELOG
1. Bump version via `bundle exec rake -f Rakefile.release module:bump:minor` (or major/patch)
1. Commit `metadata.json`
1. Test build with `bundle exec rake -f Rakefile.release module:build`
1. Tag release with `bundle exec rake -f Rakefile.release module:tag`
1. Push release to PuppetForge with `bundle exec -f Rakefile.release rake module:push`
1. Push commits and tags to GitHub with `git push --follow-tags`
