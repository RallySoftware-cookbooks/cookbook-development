require 'cookbook/development/ext/string'
require 'cookbook/development/rake/version_tasks'
require 'cookbook/development/rake/test_tasks'
require 'cookbook/development/rake/release_tasks'

CookbookDevelopment::TestTasks.new
CookbookDevelopment::VersionTasks.new
CookbookDevelopment::ReleaseTasks.new
