Pod::Spec.new do |s|
  s.name             = 'CancellablePromiseKit'
  s.version          = '0.3.0'
  s.swift_version    = '4.0'
  s.summary          = 'Extends the amazing PromiseKit to cover cancellable tasks'

  s.description      = <<-DESC
                       CancellablePromiseKit is an extension for PromiseKit. A Promise is an abstraction of an asynchonous 
                       operation that can succeed or fail. A `CancellablePromise`, provided by this library, extends this 
                       concept to represent tasks that can be cancelled/aborted.
                       DESC

  s.homepage         = 'https://github.com/johannesd/CancellablePromiseKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Johannes Dörr' => 'mail@johannesdoerr.de' }
  s.source           = { :git => 'https://github.com/johannesd/CancellablePromiseKit.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/johdoerr'

  s.ios.deployment_target = '8.0'

  s.source_files = 'CancellablePromiseKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'CancellablePromiseKit' => ['CancellablePromiseKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.dependency 'PromiseKit', '~> 6'
end
