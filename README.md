Cookbook Development
====================

This repository contains a number of helpers for chef cookbook development.
This predominantly includes:

- Vagrantfile which provides a local Docker instance to be used for
  converging cookbooks
- rake tasks for use during development
- gem dependencies to use in all cookbooks
- foodcritic rules

This is an opinionated testing setup from Rally Software, it's public
for others to use but largely reflects our own development workflow and
preferences. 

## Updating to version 1.0.0

If you are using pre 1.x versions of this updating will break some
things as the 1.x version used ChefSpec 4.2

You need to take care of any deprecation notices and things that broke
because they have been removed.

Here are some common fixes for deprecated breaks

## Using in a Cookbook

To use this repository and it's capabilities in a cookbook you need to
add it to your Gemfile like this:

```
gem 'cookbook-development', :git =>
'https://github.com/RallySoftware-cookbooks/cookbook-development'
```

Run `bundle update && bundle install` to install the latest version

## VagrantFile

The VagrantFile included in this repository will download and start a
very small VM running the
[boot2docker](https://github.com/steeve/boot2docker) distro which is
tuned to be an in-memory docker VM. The box itself is very small (~24
meg) and runs completely in memory.

Since many of our cookbooks use docker for test-kitchen converges, and
since using Docker is generally a lot faster, this VM is provided to
allow you to use Docker for local development.

If you want to use this VM you simply have to run `vagrant up` inside
this directory. You will see a large # of port forwards being setup,
this is because Vagrant forwards all the possible dynamic SSH ports that
docker may use. It also forwards port 4243, the default docker API port,
for interacting with the kitchen-docker plugin.

### Cookbook Docker setup

#### test-kitchen setup

If you have a cookbook which is already configured for docker it
probably has a `.kitchen.local.yml` file. You will need to modify the
`socket:` parameter in that file to look something like this:

```
---
driver_plugin: docker
driver_config:
  use_sudo: true
  socket: tcp://localhost:4243
  provision_command:
    - 'curl -L https://www.opscode.com/chef/install.sh | bash'
    - 'yum -y install make gcc which bash tar cronie'

platforms:
- name: centos-6.4
  run_list:
  - recipe[tree]
```

If your cookbook doesn't have a `.kitchen.local.yml` in it, the above
example will probably work provided you modify the run_list to match the
name of the cookbook you are testing

#### Gemfile modification

Currently the kitchen-docker version we use is a fork, pending a
pull-request being merged. As such we can't include it directly in
cookbook-development and it must be added to each cookbook individually.
Edit your Gemfile and add the following:

```
gem 'kitchen-docker', :github => 'adnichols/kitchen-docker', :ref =>
'docker-ruby-api'
```

After modifying this run `bundle update` and `bundle install` to get the
kitchen-docker gem.

#### Running test-kitchen

Once the above setup is complete, any runs of test-kitchen should use
docker. The initial run may take a little longer because it has to run
the steps listed in `provision_command:` (which you can add to, if you
have additional dependencies) but any subsequent runs will have the
modifications made by those steps in the docker image cache and should
be applies instantly.

## Rake Tasks

### test

This task runs through the full suite of tests avaiable and is the
appropriate way to test a cookbook before pushing your changes to github
& allowing CI to perform testing

Runs the following tasks:

- knife_test
- foodcritic
- unit
- integration

### unit

This task allows you to run everything except integration tests for fast
feedback on your changes during development

Runs the following tasks:

- knife_test
- foodcritic
- unit

### integration

This task runs only the test-kitchen convergence and integration test
suites. It's a little faster than 'rake test', but not much.

Runs the following tasks:

- kitchen:all (run all test-kitchen suites)

### release

DEPRECATED: This task should not be used unless you understand why you
are using it - all releases are done through CI now

This task used to be how we released cookbook changes, but is not used
now that CI performs all releases. As such, this task will throw a
warning and in the future will become unavailable.

Runs the following tasks:

- test
- bump
- upload

### ci

WARNING: This task is intended to be run only from CI & is dangerous to
run outside a CI environment where the state of your local git
repository is not pristine.

This task is what Jenkins runs to test & release a cookbook.

Runs the following tasks

- test
- bump
- upload
