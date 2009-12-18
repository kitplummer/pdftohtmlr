require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake/gempackagetask'

$:.unshift(File.dirname(__FILE__) + "/lib")
require 'pdftohtmlr'

PKG_NAME      = 'pdftohtmlr'
PKG_VERSION   = PDFToHTMLR::VERSION
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"

desc 'Default: run unit tests.'
task :default => :test

desc "Clean generated files"
task :clean do
  rm FileList['test/output/*.png']
  rm_rf 'pkg'
  rm_rf 'rdoc'
end

desc 'Test the pdftohtmlr gem.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the pdftohtmlr gem.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'pdftohtmlr'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.textile')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


# Create compressed packages
spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = PKG_NAME
  s.summary = "Convert PDF documents to HTML."
  s.description = %q{Uses command-line pdftohtml tools to convert PDF files to HTML.}
  s.version = PKG_VERSION

  s.author = "Kit Plummer"
  s.email = "kitplummer@gmail.com"
  s.rubyforge_project = PKG_NAME
  s.homepage = "http://github.com/kitplummer/pdftohtmlr"

  s.has_rdoc = true
  s.requirements << 'none'
  s.require_path = 'lib'
  s.autorequire = 'pdftohtml'
  s.add_dependency("nokogiri", ">= 1.3.3")
  s.files = [ "Rakefile", "README.textile", "MIT-LICENSE" ]
  s.files = s.files + Dir.glob( "lib/**/*" ).delete_if { |item| item.include?( "\.svn" ) }
  s.files = s.files + Dir.glob( "test/**/*" ).delete_if { |item| item.include?( "\.svn" ) || item.include?("\.png") }
end
  
Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = false
  p.need_zip = true
end
