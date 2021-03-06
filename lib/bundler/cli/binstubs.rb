require "bundler/cli/common"

module Bundler
  class CLI::Binstubs
    attr_reader :options, :gems
    def initialize(options, gems)
      @options = options
      @gems = gems
    end

    def run
      Bundler.definition.validate_ruby!
      Bundler.settings[:bin] = options["path"] || nil
      installer = Installer.new(Bundler.root, Bundler.definition)

      if gems.empty?
        Bundler.ui.error "`bundle binstubs` needs at least one gem to run."
        exit 1
      end

      gems.each do |gem_name|
        spec = installer.specs.find{|s| s.name == gem_name }
        unless spec
          raise GemNotFound, Bundler::CLI::Common.gem_not_found_message(
            gem_name, Bundler.definition.specs)
        end

        if spec.name == "bundler"
          Bundler.ui.warn "Sorry, Bundler can only be run via Rubygems."
        else
          installer.generate_bundler_executable_stubs(spec, :force => options[:force], :binstubs_cmd => true)
        end
      end
    end

  end
end
