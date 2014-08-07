Pod::Spec.new do |s|
  s.name         = 'ACELoadingControl'
  s.version      = '0.0.1'
  s.summary      = 'Better manager of complex download requests.'
  s.description  = <<-DESC
                   Loading state machine that supports dependencies
  DESC
  s.homepage     = 'https://github.com/acerbetti/ACELoadingControl'
  s.license      = 'MIT'
  s.author       = { "Stefano Acerbetti" => "acerbetti@gmail.com" }
  s.source       = { :git => 'https://github.com/acerbetti/ACELoadingControl.git',
                     :tag => "#{s.version}" }

  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'
  s.requires_arc = true

  s.source_files = '*.{h,m}'

end
