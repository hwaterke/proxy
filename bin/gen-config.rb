require 'yaml'
require 'erb'
require 'fileutils'
require 'logger'

# Used to provide isolated bindings to ERB.
class Namespace
  def initialize(hash)
    hash.each do |key, value|
      singleton_class.send(:define_method, key) { value }
    end
  end

  def get_binding
    binding
  end
end

class Generator
  def initialize
    @config = YAML.load_file('config.yml')
    @logger = Logger.new(STDOUT)
  end

  def create_directory_structure
    @logger.debug "Generating directory structure"
    FileUtils.mkdir_p 'data/letsencrypt/cli'
    FileUtils.mkdir_p 'data/letsencrypt/etc/letsencrypt'
    FileUtils.mkdir_p 'data/letsencrypt/var/lib/letsencrypt'
    FileUtils.mkdir_p 'data/nginx/vhost.d'
    FileUtils.mkdir_p 'data/nginx/dhparam'
    @logger.debug "Removing old configurations"
    Dir.glob("data/nginx/vhost.d/*.conf") { |e| File.delete(e) }
    Dir.glob("data/letsencrypt/cli/*.ini") { |e| File.delete(e) }
  end

  def configure_nginx
    @logger.debug "Generating Nginx configurations"
    template = File.read('data/templates/proxy.erb')
    @config['domains'].each do |domain, settings|
      @logger.debug "Nginx: #{domain}"
      settings = {'proxy' => settings} if settings.is_a? String
      raise "No proxy value for #{domain}" if settings['proxy'].nil?
      ns = Namespace.new(domain: domain, settings: settings)
      File.open("data/nginx/vhost.d/#{domain}.conf", 'w') do |out|
        out.print ERB.new(template).result(ns.get_binding)
      end
    end
  end

  def configure_letsencrypt
    @logger.debug "Generating Let's Encrypt configurations"
    template = File.read('data/templates/letsencrypt.erb')
    @config['domains'].each do |domain, _|
      @logger.debug "Let's Encrypt: #{domain}"
      ns = Namespace.new(domain: domain, email: @config['email'])
      File.open("data/letsencrypt/cli/#{domain}.ini", 'w') do |out|
        out.print ERB.new(template).result(ns.get_binding)
      end
    end
  end

  def generate_dhparam
    unless File.exist?('data/nginx/dhparam/dhparam.pem')
      @logger.debug "Generating Diffie-Hellman group"
      `openssl dhparam -out data/nginx/dhparam/dhparam.pem 2048`
    end
  end
end

g = Generator.new
g.create_directory_structure
g.configure_nginx
g.configure_letsencrypt
g.generate_dhparam
