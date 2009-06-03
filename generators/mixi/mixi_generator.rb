class MixiGenerator < Rails::Generator::NamedBase
  def initialize(runtime_args, runtime_options = {})
    super
    @params = runtime_args

    # version を指定した依存関係
    if runtime_options[:version] != nil
      min_version = runtime_options[:version]
      actual_version = Mixi::VERSION::STRING
      
      if min_version > actual_version
        raise "version error in MixiGenerator: except " + min_version + ", actual " + actual_version
      end
    end
  end

  def manifest
    record do |m| 
      prefix = 'vendor/plugins/mixi/generators/mixi/templates/'

      Dir::glob(prefix + '**/').each { |f|
        # directories
        if File::ftype(f) == 'directory'
          m.directory f.sub(prefix, '')
        end
      }
      
      # text files
      Dir::glob(prefix + '**/*.{yml,erb,jpg,txt,mo,po,pot,css,gif,csv,rb,rjs,js}').each { |f|
        filename = f.sub(prefix, '')
        m.file(
          filename, # from('vendor/plugins/foo/generators/foo/templates/' 相対パス)
          filename, # to(RAILS_ROOT 相対パス)
          :collision => :ask
        )
      }
    end
  end
end