require 'spec_helper'

# Test plan for unique indexes and uniqueness validators
#
#    Index        |  First Metasploit::Credential::Core  |           |           |           |  Second Metasploit::Credential::Core  |             |             |             |  Collision  |
#    -------------|--------------------------------------|-----------|-----------|-----------|---------------------------------------|-------------|-------------|-------------|-------------|
#                 |  Workspace                           |  Realm    |  Public   |  Private  |  Workspace                            |  Realm      |  Public     |  Private    |             |
#    private      |  non-nil                             |  nil      |  nil      |  non-nil  |  same                                 |  nil        |  nil        |  same       |  TRUE       |
#    private      |  non-nil                             |  nil      |  nil      |  non-nil  |  same                                 |  nil        |  nil        |  different  |  FALSE      |
#    private      |  non-nil                             |  nil      |  nil      |  non-nil  |  different                            |  nil        |  nil        |  same       |  FALSE      |
#    private      |  non-nil                             |  nil      |  nil      |  non-nil  |  different                            |  nil        |  nil        |  different  |  FALSE      |
#    public       |  non-nil                             |  nil      |  non-nil  |  nil      |  same                                 |  nil        |  same       |  nil        |  TRUE       |
#    public       |  non-nil                             |  nil      |  non-nil  |  nil      |  same                                 |  nil        |  different  |  nil        |  FALSE      |
#    public       |  non-nil                             |  nil      |  non-nil  |  nil      |  different                            |  nil        |  same       |  nil        |  FALSE      |
#    public       |  non-nil                             |  nil      |  non-nil  |  nil      |  different                            |  nil        |  different  |  nil        |  FALSE      |
#    realmless    |  non-nil                             |  nil      |  non-nil  |  non-nil  |  same                                 |  nil        |  same       |  same       |  TRUE       |
#    realmless    |  non-nil                             |  nil      |  non-nil  |  non-nil  |  same                                 |  nil        |  same       |  different  |  FALSE      |
#    realmless    |  non-nil                             |  nil      |  non-nil  |  non-nil  |  same                                 |  nil        |  different  |  same       |  FALSE      |
#    realmless    |  non-nil                             |  nil      |  non-nil  |  non-nil  |  same                                 |  nil        |  different  |  different  |  FALSE      |
#    realmless    |  non-nil                             |  nil      |  non-nil  |  non-nil  |  different                            |  nil        |  same       |  same       |  FALSE      |
#    realmless    |  non-nil                             |  nil      |  non-nil  |  non-nil  |  different                            |  nil        |  same       |  different  |  FALSE      |
#    realmless    |  non-nil                             |  nil      |  non-nil  |  non-nil  |  different                            |  nil        |  different  |  same       |  FALSE      |
#    realmless    |  non-nil                             |  nil      |  non-nil  |  non-nil  |  different                            |  nil        |  different  |  different  |  FALSE      |
#    publicless   |  non-nil                             |  non-nil  |  nil      |  non-nil  |  same                                 |  same       |  nil        |  same       |  TRUE       |
#    publicless   |  non-nil                             |  non-nil  |  nil      |  non-nil  |  same                                 |  same       |  nil        |  different  |  FALSE      |
#    publicless   |  non-nil                             |  non-nil  |  nil      |  non-nil  |  same                                 |  different  |  nil        |  same       |  FALSE      |
#    publicless   |  non-nil                             |  non-nil  |  nil      |  non-nil  |  same                                 |  different  |  nil        |  different  |  FALSE      |
#    publicless   |  non-nil                             |  non-nil  |  nil      |  non-nil  |  different                            |  same       |  nil        |  same       |  FALSE      |
#    publicless   |  non-nil                             |  non-nil  |  nil      |  non-nil  |  different                            |  same       |  nil        |  different  |  FALSE      |
#    publicless   |  non-nil                             |  non-nil  |  nil      |  non-nil  |  different                            |  different  |  nil        |  same       |  FALSE      |
#    publicless   |  non-nil                             |  non-nil  |  nil      |  non-nil  |  different                            |  different  |  nil        |  different  |  FALSE      |
#    privateless  |  non-nil                             |  non-nil  |  non-nil  |  nil      |  same                                 |  same       |  same       |  nil        |  TRUE       |
#    privateless  |  non-nil                             |  non-nil  |  non-nil  |  nil      |  same                                 |  same       |  different  |  nil        |  FALSE      |
#    privateless  |  non-nil                             |  non-nil  |  non-nil  |  nil      |  same                                 |  different  |  same       |  nil        |  FALSE      |
#    privateless  |  non-nil                             |  non-nil  |  non-nil  |  nil      |  same                                 |  different  |  different  |  nil        |  FALSE      |
#    privateless  |  non-nil                             |  non-nil  |  non-nil  |  nil      |  different                            |  same       |  same       |  nil        |  FALSE      |
#    privateless  |  non-nil                             |  non-nil  |  non-nil  |  nil      |  different                            |  same       |  different  |  nil        |  FALSE      |
#    privateless  |  non-nil                             |  non-nil  |  non-nil  |  nil      |  different                            |  different  |  same       |  nil        |  FALSE      |
#    privateless  |  non-nil                             |  non-nil  |  non-nil  |  nil      |  different                            |  different  |  different  |  nil        |  FALSE      |
#    complete     |  non-nil                             |  non-nil  |  non-nil  |  non-nil  |  same                                 |  same       |  same       |  same       |  TRUE       |
#    complete     |  non-nil                             |  non-nil  |  non-nil  |  non-nil  |  same                                 |  same       |  same       |  different  |  FALSE      |
#    complete     |  non-nil                             |  non-nil  |  non-nil  |  non-nil  |  same                                 |  same       |  different  |  same       |  FALSE      |
#    complete     |  non-nil                             |  non-nil  |  non-nil  |  non-nil  |  same                                 |  same       |  different  |  different  |  FALSE      |
#    complete     |  non-nil                             |  non-nil  |  non-nil  |  non-nil  |  same                                 |  different  |  same       |  same       |  FALSE      |
#    complete     |  non-nil                             |  non-nil  |  non-nil  |  non-nil  |  same                                 |  different  |  same       |  different  |  FALSE      |
#    complete     |  non-nil                             |  non-nil  |  non-nil  |  non-nil  |  same                                 |  different  |  different  |  same       |  FALSE      |
#    complete     |  non-nil                             |  non-nil  |  non-nil  |  non-nil  |  same                                 |  different  |  different  |  different  |  FALSE      |
#    complete     |  non-nil                             |  non-nil  |  non-nil  |  non-nil  |  different                            |  same       |  same       |  same       |  FALSE      |
#    complete     |  non-nil                             |  non-nil  |  non-nil  |  non-nil  |  different                            |  same       |  same       |  different  |  FALSE      |
#    complete     |  non-nil                             |  non-nil  |  non-nil  |  non-nil  |  different                            |  same       |  different  |  same       |  FALSE      |
#    complete     |  non-nil                             |  non-nil  |  non-nil  |  non-nil  |  different                            |  same       |  different  |  different  |  FALSE      |
#    complete     |  non-nil                             |  non-nil  |  non-nil  |  non-nil  |  different                            |  different  |  same       |  same       |  FALSE      |
#    complete     |  non-nil                             |  non-nil  |  non-nil  |  non-nil  |  different                            |  different  |  same       |  different  |  FALSE      |
#    complete     |  non-nil                             |  non-nil  |  non-nil  |  non-nil  |  different                            |  different  |  different  |  same       |  FALSE      |
#    complete     |  non-nil                             |  non-nil  |  non-nil  |  non-nil  |  different                            |  different  |  different  |  different  |  FALSE      |
#
describe Metasploit::Credential::Core do
  include_context 'Mdm::Workspace'

  subject(:core) do
    described_class.new
  end

  #
  # Context Methods
  #

  # Returns correlation with the given `name` from options.
  #
  # @param options [Hash{Symbol => :different, :same}]
  # @param name [Symbol] name of correlation option in `options`.
  # @return [:different, :same]
  # @raise [ArgumentError] if `options[name]` is not `:different` or `:same`
  # @raise [KeyError] if `options` does not contain key `name`
  def self.correlation!(options, name)
    correlation = options.fetch(name)

    unless [:different, :same].include? correlation
      raise ArgumentError, "#{name} must be :different or :same"
    end

    correlation
  end

  # Declares a `context` with correlation on `name` and body of `block`
  #
  # @param options [Hash{Symbol => :different, :same}]
  # @param name [Symbol] name of correlation option in `options`.
  # @yield Block that functions as body of `context`
  # @return [void]
  # @raise (see correlation!)
  def self.context_with_correlation(options, name, &block)
    correlation = correlation!(options, name)

    context "with #{correlation} #{name}" do
      if correlation == :same
        let("second_#{name}") {
          send("first_#{name}")
        }
      end

      instance_eval(&block)
    end
  end

  #
  # Shared Contexts
  #

  shared_context 'two metasploit_credential_cores' do
    #
    # lets
    #

    let(:first_private) {
      FactoryGirl.create(:metasploit_credential_private)
    }

    let(:first_public) {
      FactoryGirl.create(:metasploit_credential_public)
    }

    let(:first_realm) {
      FactoryGirl.create(:metasploit_credential_realm)
    }

    let(:first_workspace) {
      FactoryGirl.create(:mdm_workspace)
    }

    let(:origin) {
      # use an origin where the workspace does not need to correlate
      FactoryGirl.create(:metasploit_credential_origin_manual)
    }

    let(:second_metasploit_credential_core) {
      FactoryGirl.build(
          :metasploit_credential_core,
          origin: origin,
          private: second_private,
          public: second_public,
          realm: second_realm,
          workspace: second_workspace
      )
    }

    let(:second_private) {
      FactoryGirl.create(:metasploit_credential_private)
    }

    let(:second_public) {
      FactoryGirl.create(:metasploit_credential_public)
    }

    let(:second_realm) {
      FactoryGirl.create(:metasploit_credential_realm)
    }

    let(:second_workspace) {
      FactoryGirl.create(:mdm_workspace)
    }

    #
    # let!s
    #

    let!(:first_metasploit_credential_core) {
      FactoryGirl.create(
          :metasploit_credential_core,
          origin: origin,
          private: first_private,
          public: first_public,
          realm: first_realm,
          workspace: first_workspace
      )
    }
  end

  #
  # Examples
  #

  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { should have_and_belong_to_many(:tasks).class_name('Mdm::Task') }
    it { should have_many(:logins).class_name('Metasploit::Credential::Login').dependent(:destroy) }
    it { should belong_to(:origin) }
    it { should belong_to(:private).class_name('Metasploit::Credential::Private') }
    it { should belong_to(:public).class_name('Metasploit::Credential::Public') }
    it { should belong_to(:realm).class_name('Metasploit::Credential::Realm') }
    it { should belong_to(:workspace).class_name('Mdm::Workspace') }
  end

  context 'database' do
    context 'columns' do
      context 'foreign keys' do
        context 'polymorphic origin' do
          it { should have_db_column(:origin_id).of_type(:integer).with_options(null: false) }
          it { should have_db_column(:origin_type).of_type(:string).with_options(null: false) }
        end

        it { should have_db_column(:private_id).of_type(:integer).with_options(null: true) }
        it { should have_db_column(:public_id).of_type(:integer).with_options(null: true) }
        it { should have_db_column(:realm_id).of_type(:integer).with_options(null: true) }
        it { should have_db_column(:workspace_id).of_type(:integer).with_options(null: false) }
      end

      it_should_behave_like 'timestamp database columns'
    end

    context 'indices' do
      context 'foreign keys' do
        #
        # Shared Examples
        #

        shared_examples_for 'potential collision' do |options={}|
          options.assert_valid_keys(:collision, :index)

          if options.fetch(:collision)
            it 'raises ActiveRecord::RecordNotUnique' do
              expect {
                second_metasploit_credential_core.save(validate: false)
              }.to raise_error(ActiveRecord::RecordNotUnique) { |error|
                expect(error.message).to include(
                                             "duplicate key value violates unique constraint \"#{options.fetch(:index)}\""
                                         )
              }
            end
          else
            it 'does not raise ActiveRecord::RecordNotUnique' do
              expect {
                second_metasploit_credential_core.save(validate: false)
              }.not_to raise_error
            end
          end
        end

        shared_examples_for 'unique_private_metasploit_credential_cores' do |options={}|
          include_context 'two metasploit_credential_cores'

          options.assert_valid_keys(:collision, :private, :workspace)

          #
          # lets
          #

          let(:first_public) {
            nil
          }

          let(:first_realm) {
            nil
          }

          let(:second_public) {
            nil
          }

          let(:second_realm) {
            nil
          }

          context_with_correlation(options, :workspace) do
            context_with_correlation(options, :private) do
              it_should_behave_like 'potential collision',
                                    collision: options.fetch(:collision),
                                    index: 'unique_private_metasploit_credential_cores'
            end
          end
        end

        shared_examples_for 'unique_public_metasploit_credential_cores' do |options={}|
          include_context 'two metasploit_credential_cores'

          options.assert_valid_keys(:collision, :public, :workspace)

          #
          # lets
          #

          let(:first_private) {
            nil
          }

          let(:first_realm) {
            nil
          }

          let(:second_private) {
            nil
          }

          let(:second_realm) {
            nil
          }

          context_with_correlation(options, :workspace) do
            context_with_correlation(options, :public) do
              it_should_behave_like 'potential collision',
                                    collision: options.fetch(:collision),
                                    index: 'unique_public_metasploit_credential_cores'
            end
          end
        end

        shared_examples_for 'unique_realmless_metasploit_credential_cores' do |options={}|
          include_context 'two metasploit_credential_cores'

          options.assert_valid_keys(:collision, :private, :public, :workspace)

          let(:first_realm) {
            nil
          }

          let(:second_realm) {
            nil
          }

          context_with_correlation(options, :workspace) do
            context_with_correlation(options, :public) do
              context_with_correlation(options, :private) do
                it_should_behave_like 'potential collision',
                                      collision: options.fetch(:collision),
                                      index: 'unique_realmless_metasploit_credential_cores'
              end
            end
          end
        end

        shared_examples_for 'unique_publicless_metasploit_credential_cores' do |options={}|
          include_context 'two metasploit_credential_cores'

          options.assert_valid_keys(:collision, :private, :realm, :workspace)

          let(:first_public) {
            nil
          }

          let(:second_public) {
            nil
          }

          context_with_correlation(options, :workspace) do
            context_with_correlation(options, :realm) do
              context_with_correlation(options, :private) do
                it_should_behave_like 'potential collision',
                                      collision: options.fetch(:collision),
                                      index: 'unique_publicless_metasploit_credential_cores'
              end
            end
          end
        end

        shared_examples_for 'unique_privateless_metasploit_credential_cores' do |options={}|
          include_context 'two metasploit_credential_cores'

          options.assert_valid_keys(:collision, :public, :realm, :workspace)

          let(:first_private) {
            nil
          }

          let(:second_private) {
            nil
          }

          context_with_correlation(options, :workspace) do
            context_with_correlation(options, :realm) do
              context_with_correlation(options, :public) do
                it_should_behave_like 'potential collision',
                                      collision: options.fetch(:collision),
                                      index: 'unique_privateless_metasploit_credential_cores'
              end
            end
          end
        end

        shared_examples 'unique_complete_metasploit_credential_cores' do |options={}|
          include_context 'two metasploit_credential_cores'

          options.assert_valid_keys(:collision, :private, :public, :realm, :workspace)

          context_with_correlation(options, :workspace) do
            context_with_correlation(options, :realm) do
              context_with_correlation(options, :public) do
                context_with_correlation(options, :private) do
                  it_should_behave_like 'potential collision',
                                        collision: options.fetch(:collision),
                                        index: 'unique_complete_metasploit_credential_cores'
                end
              end
            end
          end
        end

        #
        # Examples
        #

        it { should have_db_index([:origin_type, :origin_id]) }
        it { should have_db_index(:private_id) }
        it { should have_db_index(:public_id) }
        it { should have_db_index(:realm_id) }
        it { should have_db_index(:workspace_id) }

        it_should_behave_like 'unique_private_metasploit_credential_cores',
                              workspace: :same,
                              private: :same,
                              collision: true
        it_should_behave_like 'unique_private_metasploit_credential_cores',
                              workspace: :same,
                              private: :different,
                              collision: false
        it_should_behave_like 'unique_private_metasploit_credential_cores',
                              workspace: :different,
                              private: :same,
                              collision: false
        it_should_behave_like 'unique_private_metasploit_credential_cores',
                              workspace: :different,
                              private: :different,
                              collision: false

        it_should_behave_like 'unique_public_metasploit_credential_cores',
                              workspace: :same,
                              public: :same,
                              collision: true
        it_should_behave_like 'unique_public_metasploit_credential_cores',
                              workspace: :same,
                              public: :different,
                              collision: false
        it_should_behave_like 'unique_public_metasploit_credential_cores',
                              workspace: :different,
                              public: :same,
                              collision: false
        it_should_behave_like 'unique_public_metasploit_credential_cores',
                              workspace: :different,
                              public: :different,
                              collision: false

        it_should_behave_like 'unique_realmless_metasploit_credential_cores',
                              workspace: :same,
                              public: :same,
                              private: :same,
                              collision: true
        it_should_behave_like 'unique_realmless_metasploit_credential_cores',
                              workspace: :same,
                              public: :same,
                              private: :different,
                              collision: false
        it_should_behave_like 'unique_realmless_metasploit_credential_cores',
                              workspace: :same,
                              public: :different,
                              private: :same,
                              collision: false
        it_should_behave_like 'unique_realmless_metasploit_credential_cores',
                              workspace: :same,
                              public: :different,
                              private: :different,
                              collision: false
        it_should_behave_like 'unique_realmless_metasploit_credential_cores',
                              workspace: :different,
                              public: :same,
                              private: :same,
                              collision: false
        it_should_behave_like 'unique_realmless_metasploit_credential_cores',
                              workspace: :different,
                              public: :same,
                              private: :different,
                              collision: false
        it_should_behave_like 'unique_realmless_metasploit_credential_cores',
                              workspace: :different,
                              public: :different,
                              private: :same,
                              collision: false
        it_should_behave_like 'unique_realmless_metasploit_credential_cores',
                              workspace: :different,
                              public: :different,
                              private: :different,
                              collision: false

        it_should_behave_like 'unique_publicless_metasploit_credential_cores',
                              workspace: :same,
                              realm: :same,
                              private: :same,
                              collision: true
        it_should_behave_like 'unique_publicless_metasploit_credential_cores',
                              workspace: :same,
                              realm: :same,
                              private: :different,
                              collision: false
        it_should_behave_like 'unique_publicless_metasploit_credential_cores',
                              workspace: :same,
                              realm: :different,
                              private: :same,
                              collision: false
        it_should_behave_like 'unique_publicless_metasploit_credential_cores',
                              workspace: :same,
                              realm: :different,
                              private: :different,
                              collision: false
        it_should_behave_like 'unique_publicless_metasploit_credential_cores',
                              workspace: :different,
                              realm: :same,
                              private: :same,
                              collision: false
        it_should_behave_like 'unique_publicless_metasploit_credential_cores',
                              workspace: :different,
                              realm: :same,
                              private: :different,
                              collision: false
        it_should_behave_like 'unique_publicless_metasploit_credential_cores',
                              workspace: :different,
                              realm: :different,
                              private: :same,
                              collision: false
        it_should_behave_like 'unique_publicless_metasploit_credential_cores',
                              workspace: :different,
                              realm: :different,
                              private: :different,
                              collision: false

        it_should_behave_like 'unique_privateless_metasploit_credential_cores',
                              workspace: :same,
                              realm: :same,
                              public: :same,
                              collision: true
        it_should_behave_like 'unique_privateless_metasploit_credential_cores',
                              workspace: :same,
                              realm: :same,
                              public: :different,
                              collision: false
        it_should_behave_like 'unique_privateless_metasploit_credential_cores',
                              workspace: :same,
                              realm: :different,
                              public: :same,
                              collision: false
        it_should_behave_like 'unique_privateless_metasploit_credential_cores',
                              workspace: :same,
                              realm: :different,
                              public: :different,
                              collision: false
        it_should_behave_like 'unique_privateless_metasploit_credential_cores',
                              workspace: :different,
                              realm: :same,
                              public: :same,
                              collision: false
        it_should_behave_like 'unique_privateless_metasploit_credential_cores',
                              workspace: :different,
                              realm: :same,
                              public: :different,
                              collision: false
        it_should_behave_like 'unique_privateless_metasploit_credential_cores',
                              workspace: :different,
                              realm: :different,
                              public: :same,
                              collision: false
        it_should_behave_like 'unique_privateless_metasploit_credential_cores',
                              workspace: :different,
                              realm: :different,
                              public: :different,
                              collision: false

        it_should_behave_like 'unique_complete_metasploit_credential_cores',
                              workspace: :same,
                              realm: :same,
                              public: :same,
                              private: :same,
                              collision: true
        it_should_behave_like 'unique_complete_metasploit_credential_cores',
                              workspace: :same,
                              realm: :same,
                              public: :same,
                              private: :different,
                              collision: false
        it_should_behave_like 'unique_complete_metasploit_credential_cores',
                              workspace: :same,
                              realm: :same,
                              public: :different,
                              private: :same,
                              collision: false
        it_should_behave_like 'unique_complete_metasploit_credential_cores',
                              workspace: :same,
                              realm: :same,
                              public: :different,
                              private: :different,
                              collision: false
        it_should_behave_like 'unique_complete_metasploit_credential_cores',
                              workspace: :same,
                              realm: :different,
                              public: :same,
                              private: :same,
                              collision: false
        it_should_behave_like 'unique_complete_metasploit_credential_cores',
                              workspace: :same,
                              realm: :different,
                              public: :same,
                              private: :different,
                              collision: false
        it_should_behave_like 'unique_complete_metasploit_credential_cores',
                              workspace: :same,
                              realm: :different,
                              public: :different,
                              private: :same,
                              collision: false
        it_should_behave_like 'unique_complete_metasploit_credential_cores',
                              workspace: :same,
                              realm: :different,
                              public: :different,
                              private: :different,
                              collision: false
        it_should_behave_like 'unique_complete_metasploit_credential_cores',
                              workspace: :different,
                              realm: :same,
                              public: :same,
                              private: :same,
                              collision: false
        it_should_behave_like 'unique_complete_metasploit_credential_cores',
                              workspace: :different,
                              realm: :same,
                              public: :same,
                              private: :different,
                              collision: false
        it_should_behave_like 'unique_complete_metasploit_credential_cores',
                              workspace: :different,
                              realm: :same,
                              public: :different,
                              private: :same,
                              collision: false
        it_should_behave_like 'unique_complete_metasploit_credential_cores',
                              workspace: :different,
                              realm: :same,
                              public: :different,
                              private: :different,
                              collision: false
        it_should_behave_like 'unique_complete_metasploit_credential_cores',
                              workspace: :different,
                              realm: :different,
                              public: :same,
                              private: :same,
                              collision: false
        it_should_behave_like 'unique_complete_metasploit_credential_cores',
                              workspace: :different,
                              realm: :different,
                              public: :same,
                              private: :different,
                              collision: false
        it_should_behave_like 'unique_complete_metasploit_credential_cores',
                              workspace: :different,
                              realm: :different,
                              public: :different,
                              private: :same,
                              collision: false
        it_should_behave_like 'unique_complete_metasploit_credential_cores',
                              workspace: :different,
                              realm: :different,
                              public: :different,
                              private: :different,
                              collision: false
      end
    end
  end

  context 'scopes' do

    context '.workspace_id' do
      let(:query) { described_class.workspace_id(workspace_id) }

      subject(:metasploit_credential_core) do
        FactoryGirl.create(:metasploit_credential_core)
      end

      context 'when given a valid workspace id' do
        let(:workspace_id) { metasploit_credential_core.workspace_id }

        it 'returns the correct Core' do
          expect(query).to eq [metasploit_credential_core]
        end
      end

      context 'when given an invalid workspace id' do
        let(:workspace_id) { -1 }

        it 'returns an empty collection' do
          expect(query).to be_empty
        end
      end
    end

    context '.login_host_id' do
      let(:query) { described_class.login_host_id(host_id) }
      let(:login) { FactoryGirl.create(:metasploit_credential_login) }
      subject(:metasploit_credential_core) { login.core }

      context 'when given a valid host id' do
        let(:host_id) { metasploit_credential_core.logins.first.service.host.id }

        it 'returns the correct Core' do
          expect(query).to eq [metasploit_credential_core]
        end
      end

      context 'when given an invalid host id' do
        let(:host_id) { -1 }

        it 'returns an empty collection' do
          expect(query).to be_empty
        end
      end
    end

    context '.origin_service_host_id' do
      let(:query) { described_class.origin_service_host_id(host_id) }
      let(:workspace) { FactoryGirl.create(:mdm_workspace) }

      subject(:metasploit_credential_core) do
        FactoryGirl.create(:metasploit_credential_core_service)
      end

      context 'when given a valid host id' do
        let(:host_id) { metasploit_credential_core.origin.service.host.id }

        it 'returns the correct Core' do
          expect(query).to eq [metasploit_credential_core]
        end
      end

      context 'when given an invalid host id' do
        let(:host_id) { -1 }

        it 'returns an empty collection' do
          expect(query).to be_empty
        end
      end
    end

    context '.origin_session_host_id' do
      let(:query) { described_class.origin_session_host_id(host_id) }

      subject(:metasploit_credential_core) do
        FactoryGirl.create(:metasploit_credential_core_session)
      end

      context 'when given a valid host id' do
        let(:host_id) { metasploit_credential_core.origin.session.host.id }

        it 'returns the correct Core' do
          expect(query).to eq [metasploit_credential_core]
        end
      end

      context 'when given an invalid host id' do
        let(:host_id) { -1 }

        it 'returns an empty collection' do
          expect(query).to be_empty
        end
      end
    end

    context '.originating_host_id' do
      let(:query) { described_class.originating_host_id(host_id) }

      # Create a couple Cores that are related to the host via session
      let(:metasploit_credential_core_sessions) do
        FactoryGirl.create_list(:metasploit_credential_core_session, 2)
      end

      # Create a couple Cores that are related to the host via service
      let(:metasploit_credential_core_services) do
        FactoryGirl.create_list(:metasploit_credential_core_service, 2)
      end

      # Create an unrelated Core
      let(:unrelated_metasploit_credential_core) do
        FactoryGirl.create(:metasploit_credential_core_service)
      end

      before do
        # make sure they are all related to the same host
        # ideally this would be done in the factory, but one look at the factories and i am punting.
        init_host_id = metasploit_credential_core_services.first.origin.service.host.id

        metasploit_credential_core_services.each do |core|
          core.origin.service.host_id = init_host_id
          core.origin.service.save
        end

        metasploit_credential_core_sessions.each do |core|
          core.origin.session.host_id = init_host_id
          core.origin.session.save
        end

        # Make sure the unrelated core is actually created
        unrelated_metasploit_credential_core
      end

      context 'when given a valid host id' do
        let(:host_id) { metasploit_credential_core_sessions.first.origin.session.host.id }

        it 'returns an ActiveRecord::Relation' do
          expect(query).to be_an ActiveRecord::Relation
        end

        it 'returns the correct Cores' do
          expect(query).to match_array metasploit_credential_core_sessions + metasploit_credential_core_services
        end
      end

      context 'when given an invalid host id' do
        let(:host_id) { -1 }

        it 'returns an ActiveRecord::Relation' do
          expect(query).to be_an ActiveRecord::Relation
        end

        it 'returns an empty collection' do
          expect(query).to be_empty
        end
      end
    end

  end

  context 'search' do
    let(:base_class) {
      described_class
    }

    context 'associations' do
      it_should_behave_like 'search_association', :logins
      it_should_behave_like 'search_association', :private
      it_should_behave_like 'search_association', :public
      it_should_behave_like 'search_association', :realm
    end
  end

  context 'factories' do
    context 'metasploit_credential_core' do
      subject(:metasploit_credential_core) do
        FactoryGirl.build(:metasploit_credential_core)
      end

      let(:origin) do
        metasploit_credential_core.origin
      end

      it { should be_valid }

      context 'with origin_factory' do
        subject(:metasploit_credential_core) do
          FactoryGirl.build(
              :metasploit_credential_core,
              origin_factory: origin_factory
          )
        end

        context ':metasploit_credential_origin_import' do
          let(:origin_factory) do
            :metasploit_credential_origin_import
          end

          it { should be_valid }
        end

        context ':metasploit_credential_origin_manual' do
          let(:origin_factory) do
            :metasploit_credential_origin_manual
          end

          it { should be_valid }

          context '#origin' do
            subject(:origin) do
              metasploit_credential_core.origin
            end

            it { should be_a Metasploit::Credential::Origin::Manual }
          end

          context '#workspace' do
            subject(:workspace) do
              metasploit_credential_core.workspace
            end

            it { should_not be_nil }
          end
        end

        context ':metasploit_credential_origin_service' do
          let(:origin_factory) do
            :metasploit_credential_origin_service
          end

          it { should be_valid }

          context '#workspace' do
            subject(:workspace) do
              metasploit_credential_core.workspace
            end

            it 'is origin.service.host.workspace' do
              expect(workspace).not_to be_nil
              expect(workspace).to eq(origin.service.host.workspace)
            end
          end
        end

        context ':metasploit_credential_origin_session' do
          let(:origin_factory) do
            :metasploit_credential_origin_session
          end

          it { should be_valid }

          context '#workspace' do
            subject(:workspace) do
              metasploit_credential_core.workspace
            end

            it 'is origin.session.host.workspace' do
              expect(workspace).not_to be_nil
              expect(workspace).to eq(origin.session.host.workspace)
            end
          end
        end
      end
    end

    context 'metasploit_credential_core_import' do
      subject(:metasploit_credential_core_import) do
        FactoryGirl.build(:metasploit_credential_core_import)
      end

      it { should be_valid }
    end

    context 'metasploit_credential_core_manual' do
      subject(:metasploit_credential_core_manual) do
        FactoryGirl.build(:metasploit_credential_core_manual)
      end

      it { should be_valid }

      context '#workspace' do
        subject(:workspace) do
          metasploit_credential_core_manual.workspace
        end

        it { should_not be_nil }
      end
    end

    context 'metasploit_credential_core_service' do
      subject(:metasploit_credential_core_service) do
        FactoryGirl.build(:metasploit_credential_core_service)
      end

      it { should be_valid }

      context '#workspace' do
        subject(:workspace) do
          metasploit_credential_core_service.workspace
        end

        let(:origin) do
          metasploit_credential_core_service.origin
        end

        it 'is origin.service.host.workspace' do
          expect(workspace).not_to be_nil
          expect(workspace).to eq(origin.service.host.workspace)
        end
      end
    end

    context 'metasploit_credential_core_session' do
      subject(:metasploit_credential_core_session) do
        FactoryGirl.build(:metasploit_credential_core_session)
      end

      it { should be_valid }

      context '#workspace' do
        subject(:workspace) do
          metasploit_credential_core_session.workspace
        end

        let(:origin) do
          metasploit_credential_core_session.origin
        end

        it 'is origin.session.host.workspace' do
          expect(workspace).not_to be_nil
          expect(workspace).to eq(origin.session.host.workspace)
        end
      end
    end
  end

  context 'validations' do
    it { should validate_presence_of :origin }
    it { should validate_presence_of :workspace }

    context 'of uniqueness' do
      #
      # Shared Examples
      #

      shared_examples_for 'potential collision' do |options={}|
        options.assert_valid_keys(:attribute, :collision, :message)

        subject {
          second_metasploit_credential_core
        }

        #
        # Callbacks
        #

        if options.fetch(:collision)
          it 'add validation error' do
            second_metasploit_credential_core.valid?


            expect(
                second_metasploit_credential_core.errors[options.fetch(:attribute)]
            ).to include options.fetch(:message)
          end
        else
          it { should be_valid }
        end
      end

      shared_examples_for 'on (workspace_id, realm_id, public_id, private_id) without realm_id without public_id' do |options={}|
        include_context 'two metasploit_credential_cores'

        options.assert_valid_keys(:collision, :private, :workspace)

        #
        # lets
        #

        let(:first_public) {
          nil
        }

        let(:first_realm) {
          nil
        }

        let(:second_public) {
          nil
        }

        let(:second_realm) {
          nil
        }

        context_with_correlation(options, :workspace) do
          context_with_correlation(options, :private) do
            it_should_behave_like 'potential collision',
                                  attribute: :private_id,
                                  collision: options.fetch(:collision),
                                  message: 'is already taken for credential cores with only a private credential'
          end
        end
      end

      shared_examples_for 'on (workspace_id, realm_id, private_id, public_id) without realm_id without private_id' do |options={}|
        include_context 'two metasploit_credential_cores'

        options.assert_valid_keys(:collision, :public, :workspace)

        #
        # lets
        #

        let(:first_private) {
          nil
        }

        let(:first_realm) {
          nil
        }

        let(:second_private) {
          nil
        }

        let(:second_realm) {
          nil
        }

        context_with_correlation(options, :workspace) do
          context_with_correlation(options, :public) do
            it_should_behave_like 'potential collision',
                                  attribute: :public_id,
                                  collision: options.fetch(:collision),
                                  message: 'is already taken for credential cores with only a public credential'
          end
        end
      end

      shared_examples_for 'on (workspace_id, realm_id, public_id, private_id) without realm_id' do |options={}|
        include_context 'two metasploit_credential_cores'

        options.assert_valid_keys(:collision, :private, :public, :workspace)

        let(:first_realm) {
          nil
        }

        let(:second_realm) {
          nil
        }

        context_with_correlation(options, :workspace) do
          context_with_correlation(options, :public) do
            context_with_correlation(options, :private) do
              it_should_behave_like 'potential collision',
                                    attribute: :private_id,
                                    collision: options.fetch(:collision),
                                    message: 'is already taken for credential cores without a credential realm'
            end
          end
        end
      end

      shared_examples_for 'on (workspace_id, realm_id, public_, private_id) without public_id' do |options={}|
        include_context 'two metasploit_credential_cores'

        options.assert_valid_keys(:collision, :private, :realm, :workspace)

        let(:first_public) {
          nil
        }

        let(:second_public) {
          nil
        }

        context_with_correlation(options, :workspace) do
          context_with_correlation(options, :realm) do
            context_with_correlation(options, :private) do
              it_should_behave_like 'potential collision',
                                    attribute: :private_id,
                                    collision: options.fetch(:collision),
                                    message: 'is already taken for credential cores without a public credential'
            end
          end
        end
      end

      shared_examples_for 'on (workspace_id, realm_id, public_id, private_id) without private_id' do |options={}|
        include_context 'two metasploit_credential_cores'

        options.assert_valid_keys(:collision, :public, :realm, :workspace)

        let(:first_private) {
          nil
        }

        let(:second_private) {
          nil
        }

        context_with_correlation(options, :workspace) do
          context_with_correlation(options, :realm) do
            context_with_correlation(options, :public) do
              it_should_behave_like 'potential collision',
                                    attribute: :public_id,
                                    collision: options.fetch(:collision),
                                    message: 'is already taken for credential cores without a private credential'
            end
          end
        end
      end

      shared_examples 'on (workspace_id, realm_id, public_id, private_id)' do |options={}|
        include_context 'two metasploit_credential_cores'

        options.assert_valid_keys(:collision, :private, :public, :realm, :workspace)

        context_with_correlation(options, :workspace) do
          context_with_correlation(options, :realm) do
            context_with_correlation(options, :public) do
              context_with_correlation(options, :private) do
                it_should_behave_like 'potential collision',
                                      attribute: :private_id,
                                      collision: options.fetch(:collision),
                                      message: 'is already taken for complete credential cores'
              end
            end
          end
        end
      end

      #
      # Examples
      #

      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id) without realm_id without public_id',
                            workspace: :same,
                            private: :same,
                            collision: true
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id) without realm_id without public_id',
                            workspace: :same,
                            private: :different,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id) without realm_id without public_id',
                            workspace: :different,
                            private: :same,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id) without realm_id without public_id',
                            workspace: :different,
                            private: :different,
                            collision: false

      it_should_behave_like 'on (workspace_id, realm_id, private_id, public_id) without realm_id without private_id',
                            workspace: :same,
                            public: :same,
                            collision: true
      it_should_behave_like 'on (workspace_id, realm_id, private_id, public_id) without realm_id without private_id',
                            workspace: :same,
                            public: :different,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, private_id, public_id) without realm_id without private_id',
                            workspace: :different,
                            public: :same,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, private_id, public_id) without realm_id without private_id',
                            workspace: :different,
                            public: :different,
                            collision: false

      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id) without realm_id',
                            workspace: :same,
                            public: :same,
                            private: :same,
                            collision: true
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id) without realm_id',
                            workspace: :same,
                            public: :same,
                            private: :different,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id) without realm_id',
                            workspace: :same,
                            public: :different,
                            private: :same,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id) without realm_id',
                            workspace: :same,
                            public: :different,
                            private: :different,
                            collision: false
       it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id) without realm_id',
                            workspace: :different,
                            public: :same,
                            private: :same,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id) without realm_id',
                            workspace: :different,
                            public: :same,
                            private: :different,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id) without realm_id',
                            workspace: :different,
                            public: :different,
                            private: :same,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id) without realm_id',
                            workspace: :different,
                            public: :different,
                            private: :different,
                            collision: false

      it_should_behave_like 'on (workspace_id, realm_id, public_, private_id) without public_id',
                            workspace: :same,
                            realm: :same,
                            private: :same,
                            collision: true
      it_should_behave_like 'on (workspace_id, realm_id, public_, private_id) without public_id',
                            workspace: :same,
                            realm: :same,
                            private: :different,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_, private_id) without public_id',
                            workspace: :same,
                            realm: :different,
                            private: :same,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_, private_id) without public_id',
                            workspace: :same,
                            realm: :different,
                            private: :different,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_, private_id) without public_id',
                            workspace: :different,
                            realm: :same,
                            private: :same,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_, private_id) without public_id',
                            workspace: :different,
                            realm: :same,
                            private: :different,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_, private_id) without public_id',
                            workspace: :different,
                            realm: :different,
                            private: :same,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_, private_id) without public_id',
                            workspace: :different,
                            realm: :different,
                            private: :different,
                            collision: false

      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id) without private_id',
                            workspace: :same,
                            realm: :same,
                            public: :same,
                            collision: true
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id) without private_id',
                            workspace: :same,
                            realm: :same,
                            public: :different,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id) without private_id',
                            workspace: :same,
                            realm: :different,
                            public: :same,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id) without private_id',
                            workspace: :same,
                            realm: :different,
                            public: :different,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id) without private_id',
                            workspace: :different,
                            realm: :same,
                            public: :same,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id) without private_id',
                            workspace: :different,
                            realm: :same,
                            public: :different,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id) without private_id',
                            workspace: :different,
                            realm: :different,
                            public: :same,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id) without private_id',
                            workspace: :different,
                            realm: :different,
                            public: :different,
                            collision: false

      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id)',
                            workspace: :same,
                            realm: :same,
                            private: :same,
                            public: :same,
                            collision: true
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id)',
                            workspace: :same,
                            realm: :same,
                            private: :same,
                            public: :different,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id)',
                            workspace: :same,
                            realm: :same,
                            private: :different,
                            public: :same,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id)',
                            workspace: :same,
                            realm: :same,
                            private: :different,
                            public: :different,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id)',
                            workspace: :same,
                            realm: :different,
                            private: :same,
                            public: :same,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id)',
                            workspace: :same,
                            realm: :different,
                            private: :same,
                            public: :different,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id)',
                            workspace: :same,
                            realm: :different,
                            private: :different,
                            public: :same,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id)',
                            workspace: :same,
                            realm: :different,
                            private: :different,
                            public: :different,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id)',
                            workspace: :different,
                            realm: :same,
                            private: :same,
                            public: :same,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id)',
                            workspace: :different,
                            realm: :same,
                            private: :same,
                            public: :different,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id)',
                            workspace: :different,
                            realm: :same,
                            private: :different,
                            public: :same,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id)',
                            workspace: :different,
                            realm: :same,
                            private: :different,
                            public: :different,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id)',
                            workspace: :different,
                            realm: :different,
                            private: :same,
                            public: :same,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id)',
                            workspace: :different,
                            realm: :different,
                            private: :same,
                            public: :different,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id)',
                            workspace: :different,
                            realm: :different,
                            private: :different,
                            public: :same,
                            collision: false
      it_should_behave_like 'on (workspace_id, realm_id, public_id, private_id)',
                            workspace: :different,
                            realm: :different,
                            private: :different,
                            public: :different,
                            collision: false

      #
      # Cross-uniqueness validation tests
      #

      context 'across validations' do
        include_context 'two metasploit_credential_cores'

        subject {
          second_metasploit_credential_core
        }

        let(:second_private) {
          first_private
        }

        let(:second_public) {
          first_public
        }

        let(:second_realm) {
          first_realm
        }

        let(:second_workspace) {
          first_workspace
        }

        context 'with workspace with realm with public with private' do
          context 'with same workspace without realm without public with same private' do
            let(:second_public) {
              nil
            }

            let(:second_realm) {
              nil
            }

            it { should be_valid }
          end

          context 'with same workspace without realm with same public without private' do
            let(:second_private) {
              nil
            }

            let(:second_realm) {
              nil
            }

            it { should be_valid }
          end

          context 'with same workspace with same realm without public with same private' do
            let(:second_public) {
              nil
            }

            it { should be_valid }
          end

          context 'with same workspace with same realm with same public without private' do
            let(:second_private) {
              nil
            }

            let(:second_realm) {
              nil
            }

            it { should be_valid }
          end
        end

        context 'with workspace without realm without public with private' do
          let(:first_public) {
            nil
          }

          let(:first_realm) {
            nil
          }

          context 'with same workspace without realm with public without private' do
            let(:second_public) {
              FactoryGirl.create(:metasploit_credential_public)
            }

            let(:second_private) {
              nil
            }

            it { should be_valid }
          end

          context 'with same workspace without realm with public with same private' do
            let(:second_public) {
              FactoryGirl.create(:metasploit_credential_public)
            }

            it { should be_valid }
          end

          context 'with same workspace with realm without public with same private' do
            let(:second_realm) {
              FactoryGirl.create(:metasploit_credential_realm)
            }

            it { should be_valid }
          end
        end

        context 'with workspace without realm with public without private' do
          let(:first_private) {
            nil
          }

          let(:first_realm) {
            nil
          }

          context 'with workspace without realm with same public with private' do
            let(:second_private) {
              FactoryGirl.create(:metasploit_credential_private)
            }

            it { should be_valid }
          end

          context 'with workspace with realm without public with private' do
            let(:second_private) {
              FactoryGirl.create(:metasploit_credential_private)
            }

            let(:second_realm) {
              FactoryGirl.create(:metasploit_credential_realm)
            }

            it { should be_valid}
          end
        end

        context 'with workspace without realm with public with private' do
          let(:first_realm) {
            nil
          }

          context 'with same workspace with realm without public with same private' do
            let(:second_public) {
              nil
            }

            let(:second_realm) {
              FactoryGirl.create(:metasploit_credential_realm)
            }

            it { should be_valid }
          end
        end

        context 'with workspace with realm without public with private' do
          let(:first_public) {
            nil
          }

          context 'with same workspace with same realm with public without private' do
            let(:second_private) {
              nil
            }

            let(:second_public) {
              FactoryGirl.create(:metasploit_credential_public)
            }

            it { should be_valid }
          end
        end
      end
    end

    context '#consistent_workspaces' do
      subject(:workspace_errors) do
        core.errors[:workspace]
      end

      #
      # lets
      #

      let(:core) do
        FactoryGirl.build(
            :metasploit_credential_core,
            origin: origin,
            workspace: workspace
        )
      end

      let(:workspace) do
        FactoryGirl.create(:mdm_workspace)
      end

      #
      # Callbacks
      #

      before(:each) do
        core.valid?
      end

      context '#origin' do
        context 'with Metasploit::Credential::Origin::Manual' do
          let(:error) do
            I18n.translate!('activerecord.errors.models.metasploit/credential/core.attributes.workspace.origin_user_workspaces')
          end

          let(:origin) do
            FactoryGirl.build(
                :metasploit_credential_origin_manual,
                user: user
            )
          end

          context 'with Metasploit::Credential::Origin::Manual#user' do
            let(:user) do
              FactoryGirl.build(
                  :mdm_user,
                  admin: admin
              )
            end

            context 'with Mdm::User#admin' do
              let(:admin) do
                true
              end

              it { should_not include error }
            end

            context 'without Mdm::User#admin' do
              let(:admin) do
                false
              end

              context 'with #workspace in Mdm::User#workspaces' do
                let(:user) do
                  super().tap { |user|
                    user.workspaces << workspace
                  }
                end

                context 'with persisted' do
                  let(:user) do
                    super().tap { |user|
                      user.save!
                    }
                  end

                  it { should_not include error }
                end

                context 'without persisted' do
                  it { should_not include error }
                end
              end

              context 'without #workspace in Mdm::User#workspaces' do
                it { should include error }
              end
            end
          end

          context 'without Metasploit::Credential::Origin::Manual#user' do
            let(:user) do
              nil
            end

            it { should include error }
          end
        end

        context 'with Metasploit::Credential::Origin::Service' do
          let(:error) do
            I18n.translate!('activerecord.errors.models.metasploit/credential/core.attributes.workspace.origin_service_host_workspace')
          end

          let(:origin) do
            FactoryGirl.build(
                :metasploit_credential_origin_service,
                service: service
            )
          end

          context 'with Metasploit::Credential::Origin::Service#service' do
            let(:service) do
              FactoryGirl.build(
                  :mdm_service,
                  host: host
              )
            end

            context 'with Mdm::Service#host' do
              let(:host) do
                FactoryGirl.build(
                    :mdm_host,
                    workspace: host_workspace
                )
              end

              context 'same as #workspace' do
                let(:host_workspace) do
                  workspace
                end

                it { should_not include error }
              end

              context 'different than #workspace' do
                let(:host_workspace) do
                  FactoryGirl.create(:mdm_workspace)
                end

                it { should include error }
              end
            end

            context 'without Mdm::Service#host' do
              let(:host) do
                nil
              end

              it { should include error }
            end
          end

          context 'without Metasploit::Credential::Origin::Service#service' do
            let(:service) do
              nil
            end

            it { should include error }
          end
        end

        context 'with Metasploit::Credential::Origin::Session' do
          let(:error) do
            I18n.translate!('activerecord.errors.models.metasploit/credential/core.attributes.workspace.origin_session_host_workspace')
          end

          let(:origin) do
            FactoryGirl.build(
                :metasploit_credential_origin_session,
                session: session
            )
          end

          context 'with Metasploit::Credential::Origin::Session#session' do
            let(:session) do
              FactoryGirl.build(
                  :mdm_session,
                  host: host
              )
            end

            context 'with Mdm::Session#host' do
              let(:host) do
                FactoryGirl.build(
                    :mdm_host,
                    workspace: host_workspace
                )
              end

              context 'with Mdm::Host#workspace' do
                context 'same as #workspace' do
                  let(:host_workspace) do
                    workspace
                  end

                  it { should_not include error }
                end

                context 'different than #workspace' do
                  let(:host_workspace) do
                    FactoryGirl.create(:mdm_workspace)
                  end

                  it { should include error }
                end
              end

              context 'without Mdm::Host#workspace' do
                let(:host_workspace) do
                  nil
                end

                it { should include error }
              end
            end

            context 'without Mdm::Session#host' do
              let(:host) do
                nil
              end

              it { should include error }
            end
          end

          context 'without Metasploit::Credential::Origin::Session#session' do
            let(:session) do
              nil
            end

            it { should include error }
          end
        end
      end
    end

    context '#minimum_presence' do
      subject(:base_errors) do
        core.errors[:base]
      end

      #
      # lets
      #

      let(:core) do
        FactoryGirl.build(
            :metasploit_credential_core,
            private: private,
            public: public,
            realm: realm
        )
      end

      let(:error) do
        I18n.translate!('activerecord.errors.models.metasploit/credential/core.attributes.base.minimum_presence')
      end

      #
      # Callbacks
      #

      before(:each) do
        core.valid?
      end

      context 'with #private' do
        let(:private) do
          FactoryGirl.build(private_factory)
        end

        let(:private_factory) do
          FactoryGirl.generate :metasploit_credential_core_private_factory
        end

        context 'with #public' do
          let(:public) do
            FactoryGirl.build(:metasploit_credential_public)
          end

          context 'with #realm' do
            let(:realm) do
              FactoryGirl.build(realm_factory)
            end

            let(:realm_factory) do
              FactoryGirl.generate :metasploit_credential_core_realm_factory
            end

            it { should_not include(error) }
          end

          context 'without #realm' do
            let(:realm) do
              nil
            end

            it { should_not include(error) }
          end
        end

        context 'without #public' do
          let(:public) do
            nil
          end

          context 'with #realm' do
            let(:realm) do
              FactoryGirl.build(realm_factory)
            end

            let(:realm_factory) do
              FactoryGirl.generate :metasploit_credential_core_realm_factory
            end

            it { should_not include(error) }
          end

          context 'without #realm' do
            let(:realm) do
              nil
            end

            it { should_not include(error) }
          end
        end
      end

      context 'without #private' do
        let(:private) do
          nil
        end

        context 'with #public' do
          let(:public) do
            FactoryGirl.build(:metasploit_credential_public)
          end

          context 'with #realm' do
            let(:realm) do
              FactoryGirl.build(realm_factory)
            end

            let(:realm_factory) do
              FactoryGirl.generate :metasploit_credential_core_realm_factory
            end

            it { should_not include(error) }
          end

          context 'without #realm' do
            let(:realm) do
              nil
            end

            it { should_not include(error) }
          end
        end

        context 'without #public' do
          let(:public) do
            nil
          end

          context 'with #realm' do
            let(:realm) do
              FactoryGirl.build(realm_factory)
            end

            let(:realm_factory) do
              FactoryGirl.generate :metasploit_credential_core_realm_factory
            end

            it { should include(error) }
          end

        end
      end
    end

    context "#public_for_ssh_key" do
      let(:error) do
        I18n.translate!('activerecord.errors.models.metasploit/credential/core.attributes.base.public_for_ssh_key')
      end

      let(:core) do
        FactoryGirl.build(
            :metasploit_credential_core,
            private: FactoryGirl.build(:metasploit_credential_ssh_key),
            public: FactoryGirl.build(:metasploit_credential_public)
        )
      end

      it { core.should be_valid }

      context "when the Public is missing" do
        before(:each) do
          core.public = nil
        end

        it 'should not be valid if Private is an SSHKey and Public is missing' do
          core.should_not be_valid
        end

        it 'should show the proper error' do
          core.valid?
          core.errors[:base].should include(error)
        end
      end

    end

  end

end
