class ApplicationBlueprint < Blueprinter::Base
  def self.policy_scoped_association(resources_name, blueprint:)
    association(resources_name, blueprint:) do |record, _options|
      record.send(resources_name).select do |resource|
        Pundit.policy!(Current.agent, resource).show?
      end
    end
  end
end
