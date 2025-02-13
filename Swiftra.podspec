# SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
# SPDX-License-Identifier: Apache-2.0

Pod::Spec.new do |spec|
  spec.name         = "Swiftra"
  spec.version      = "0.6.0"
  spec.summary      = "A tiny Sinatra-like web framework for Swift."
  spec.homepage     = "https://github.com/mtgto/Swiftra"
  spec.license      = { :type => "Apache-2.0", :file => "LICENSE.txt" }
  spec.author             = { "mtgto" => "hogerappa@gmail.com" }
  spec.ios.deployment_target = "13.0"
  spec.osx.deployment_target = "10.14"
  spec.source       = { :git => "https://github.com/mtgto/Swiftra.git", :tag => "#{spec.version}" }
  spec.source_files  = "Sources/Swiftra/*.swift"
  spec.swift_version = '5.0'
  spec.dependency "SwiftNIOHTTP1", "~> 2.40.0"
end
