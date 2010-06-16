class BeanstreamyGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.directory "config/initializers"
      m.template  "beanstreamy.rb", "config/initializers/beanstreamy.rb"

      m.readme "README"
    end
  end
end
