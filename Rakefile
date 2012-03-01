#!/usr/bin/env rake
require "bundler/gem_tasks"

module Rake
  def self.remove_task(task_name)
    Rake.application.instance_variable_get('@tasks').delete(task_name.to_s)
  end
end

Rake.remove_task :release
