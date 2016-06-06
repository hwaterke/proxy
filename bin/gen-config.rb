require 'yaml'
require 'erb'
require 'fileutils'

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
  end

  def create_directory_structure
    FileUtils.mkdir_p 'data/letsencrypt/cli'
    FileUtils.mkdir_p 'data/letsencrypt/etc/letsencrypt'
    FileUtils.mkdir_p 'data/letsencrypt/var/lib/letsencrypt'
    FileUtils.mkdir_p 'data/nginx/vhost.d'
    FileUtils.mkdir_p 'data/nginx/dhparam'
    Dir.glob("data/nginx/vhost.d/*.conf") { |e| File.delete(e) }
    Dir.glob("data/letsencrypt/cli/*.ini") { |e| File.delete(e) }
  end

  def configure_nginx
    template = File.read('data/templates/proxy.erb')
    @config['domains'].each do |domain, proxy_addr|
      ns = Namespace.new(domain: domain, proxy_addr: proxy_addr)
      File.open("data/nginx/vhost.d/#{domain}.conf", 'w') do |out|
        out.print ERB.new(template).result(ns.get_binding)
      end
    end
  end

  def configure_letsencrypt
    template = File.read('data/templates/letsencrypt.erb')

    @config['domains'].each do |domain, _|
      ns = Namespace.new(domain: domain, email: @config['email'])
      File.open("data/letsencrypt/cli/#{domain}.ini", 'w') do |out|
        out.print ERB.new(template).result(ns.get_binding)
      end
    end
  end

  def generate_dhparam
    unless File.exist?('data/nginx/dhparam/dhparam.pem')
      puts "Generating Diffie-Hellman group. Please wait..."
      `openssl dhparam -out data/nginx/dhparam/dhparam.pem 2048`
    end
  end
end

g = Generator.new
g.create_directory_structure
g.configure_nginx
g.configure_letsencrypt
g.generate_dhparam
