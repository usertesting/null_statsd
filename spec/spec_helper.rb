require "rspec/cover_it"
project_root = File.expand_path("../..", __FILE__)
RSpec::CoverIt.setup(filter: project_root, autoenforce: true)

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "null_statsd"
