lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'timecop/redis/version'

Gem::Specification.new do |spec|
  spec.name          = 'timecop-redis'
  spec.version       = Timecop::Redis::Version.to_s
  spec.authors       = ['Yuji Nakayama']
  spec.email         = ['nkymyj@gmail.com']

  spec.summary       = 'Timecop extension for Redis'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/yujinakayama/timecop-redis'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'redis', '~> 4.0'
  spec.add_runtime_dependency 'timecop', '~> 0.9'

  spec.add_development_dependency 'bundler', '~> 2.3.26'
end
