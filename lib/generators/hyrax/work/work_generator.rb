require 'rails/generators'
require 'rails/generators/model_helpers'

class Hyrax::WorkGenerator < Rails::Generators::NamedBase
  # ActiveSupport can interpret models as plural which causes
  # counter-intuitive route paths. Pull in ModelHelpers from
  # Rails which warns users about pluralization when generating
  # new models or scaffolds.
  include Rails::Generators::ModelHelpers

  source_root File.expand_path('../templates', __FILE__)

  argument :attributes, type: :array, default: [], mybanner: 'field:type field:type'

  class_option :archetype, type: :string, default: nil

  # Why all of these antics with defining individual methods?
  # Because I want the output of Hyrax::WorkGenerator to include all the processed files.

  def banner
    if revoking?
      say_status("info", "DESTROYING WORK MODEL: #{class_name}", :blue)
    else
      say_status("info", "GENERATING WORK MODEL: #{class_name}", :blue)
    end
  end

  def create_actor
    template('actor.rb.erb', File.join('app/actors/hyrax/actors', class_path, "#{file_name}_actor.rb"))
  end

  def create_controller
    template('controller.rb.erb', File.join('app/controllers/hyrax', class_path, "#{plural_file_name}_controller.rb"))
  end

  def create_indexer
    template('indexer.rb.erb', File.join('app/indexers', class_path, "#{file_name}_indexer.rb"))
  end

  def create_form
    template('form.rb.erb', File.join('app/forms/hyrax', class_path, "#{file_name}_form.rb"))
  end

  def create_presenter
    template('presenter.rb.erb', File.join('app/presenters/hyrax', class_path, "#{file_name}_presenter.rb"))
  end

  def create_model
    template('model.rb.erb', File.join('app/models/', class_path, "#{file_name}.rb"))
  end

  def create_views
    create_file File.join('app/views/hyrax', class_path, "#{plural_file_name}/_#{file_name}.html.erb") do
      "<%# This is a search result view %>\n" \
      "<%= render 'catalog/document', document: #{file_name}, document_counter: #{file_name}_counter  %>\n"
    end
  end

  # Inserts after the last registered work, or at the top of the config block
  def register_work
    config = 'config/initializers/hyrax.rb'
    lastmatch = nil
    in_root do
      File.open(config).each_line do |line|
        lastmatch = line if line =~ /config.register_curation_concern :(?!#{file_name})/
      end
      content = "  # Injected via `rails g hyrax:work #{class_name}`\n" \
                "  config.register_curation_concern #{registration_path_symbol}\n"
      anchor = lastmatch || "Hyrax.config do |config|\n"
      inject_into_file config, after: anchor do
        content
      end
    end
  end

  LOCALES = %w[en es zh de fr it pt-BR].freeze

  def create_i18n
    LOCALES.each do |locale|
      template("locale.#{locale}.yml.erb", File.join('config/locales/', class_path, "#{file_name}.#{locale}.yml"))
    end
  end

  def create_actor_spec
    return unless rspec_installed?
    template('actor_spec.rb.erb', File.join('spec/actors/hyrax/actors/', class_path, "#{file_name}_actor_spec.rb"))
  end

  def create_controller_spec
    return unless rspec_installed?
    template('controller_spec.rb.erb', File.join('spec/controllers/hyrax/', class_path, "#{plural_file_name}_controller_spec.rb"))
  end

  def create_feature_spec
    return unless rspec_installed?
    template('feature_spec.rb.erb', File.join('spec/features/', class_path, "create_#{file_name}_spec.rb"))
  end

  def create_form_spec
    return unless rspec_installed?
    template('form_spec.rb.erb', File.join('spec/forms/hyrax/', class_path, "#{file_name}_form_spec.rb"))
  end

  def presenter_spec
    return unless rspec_installed?
    template('presenter_spec.rb.erb', File.join('spec/presenters/hyrax/', class_path, "#{file_name}_presenter_spec.rb"))
  end

  def create_model_spec
    return unless rspec_installed?
    template('model_spec.rb.erb', File.join('spec/models/', class_path, "#{file_name}_spec.rb"))
  end

  def archetype
    return unless options['archetype']
    @archetype_name = options['archetype']

    unless revoking?
      if @archetype_name == 'archetype'  # A runtime option without a value will create a key whose value is the same as the key
        if yes?("The --archetype option was used without a value; make new #{class_name} Work Type an archetype?")
          say_status("info", "Modules are being created for #{class_name} that can be included in other work types", :blue)

          # Create archetype modules
          template('controller_behavior.rb.erb', File.join('app/controllers/concerns/essi', class_path, "#{plural_file_name}_controller_behavior.rb"))
          template('model_behavior.rb.erb', File.join('app/models/concerns/essi', class_path, "#{file_name}_behavior.rb"))
          template('metadata.rb.erb', File.join('app/models/concerns/essi', class_path, "#{file_name}_metadata.rb"))
          template('form_behavior.rb.erb', File.join('app/forms/concerns/essi', class_path, "#{file_name}_form_behavior.rb"))
          template('indexer_behavior.rb.erb', File.join('app/indexers/concerns/essi', class_path, "#{file_name}_indexer_behavior.rb"))

          # We still need to mixin the new archetype modules to the new work type by the same name later
          @archetype_name = class_name
        end
      end

      begin
        class_file = "concerns/essi/#{@archetype_name.underscore}_behavior.rb"
        require "#{class_file}"

        # Inject mixins to classes unless a valid archetype is specified.
        # Otherwise the 'require' above will throw LoadError and be rescued below
        say_status("info", "Behaviours of #{@archetype_name} are being added to #{class_name}", :blue)

        # Insert archetype module mixins into new work type classes
        in_root do
          target_file = File.join('app/models/', class_path, "#{file_name}.rb")
          inject_into_file target_file, "  include ESSI::#{@archetype_name}Behavior\n", after: "ActiveFedora::Base\n"
          inject_into_file target_file, metadata_mixin, after: /validates.*\n/

          target_file = File.join('app/controllers/hyrax', class_path, "#{plural_file_name}_controller.rb")
          inject_into_file target_file, "    include ESSI::#{@archetype_name.pluralize}ControllerBehavior\n", after: "WorksControllerBehavior\n"
          gsub_file target_file, "#{class_name}Presenter", "#{@archetype_name}Presenter"

          target_file = File.join('app/indexers', class_path, "#{file_name}_indexer.rb")
          inject_into_file target_file, "  include ESSI::#{@archetype_name}IndexerBehavior\n", after: "IndexesBasicMetadata\n"

          target_file = File.join('app/forms/hyrax', class_path, "#{file_name}_form.rb")
          inject_into_file target_file, "    include ESSI::#{@archetype_name}FormBehavior\n", after: "[:resource_type]\n"

          # Ignore broken scenario in generated feature test for work types.
          # When multiple work types exist the UI control for creating works changes from a simple button
          # to a radio JS control that the feature scenario has trouble with, even after uncommenting
          # the specified lines that address the issue.
          target_file = File.join('spec/features/', class_path, "create_#{file_name}_spec.rb")
          gsub_file target_file, "scenario", "xscenario"

        end

      rescue LoadError
        unless @archetype_name == 'archetype'
          say_status("Error", "Behaviours of #{@archetype_name} archetype are NOT being added; #{class_file} does not exist", :red)
        end
        exit
      end
    end
  end

  def display_readme
    readme 'README' unless revoking?
  end

  private

    def rspec_installed?
      defined?(RSpec) && defined?(RSpec::Rails)
    end

    def revoking?
      behavior == :revoke
    end

    def registration_path_symbol
      return ":#{file_name}" if class_path.blank?
      # this next line creates a symbol with a path like
      # "abc/scholarly_paper" where abc is the namespace and
      #                              scholarly_paper is the concern
      ":\"#{File.join(class_path, file_name)}\""
    end

    def metadata_mixin
      "\n  # This model includes metadata properties specific to the #{@archetype_name} Work Type\n" \
          "  include ESSI::#{@archetype_name}Metadata\n"
    end

    def controller_mixin

    end

    def form_mixin

    end

    def indexer_mixin

    end
end
