# Defines the core DSL for specifying validations.
module Verity::Core::DSL
  def self.included(klass)
    klass.class_eval do
      extend ClassMethods
      extend Verity::Predicates
    end
  end
  module ClassMethods

    def the(attribute_name)
      return Proc.new { |r| r.send(attribute_name) }
    end

    def method_missing(name, *args)
      begin
        super
      rescue NameError
        case name.to_s
          when /^(.*)_must$/
            predicate = args.shift
            predicate.configure(*args)
            attribute = $1.to_sym
            (validations[attribute][:positive] ||= []) << predicate
            true
          when /^(.*)_must_not$/
            predicate = args.shift
            predicate.configure(*args)
            attribute = $1.to_sym
            (validations[attribute][:negative] ||= []) << predicate
            true
          when /^be_(.*)/
            Verity::Predicates::Be.new($1)
          else
            raise
        end
      end
    end

  end
end
