class Components::ErrorMessages < Components::Base
  def initialize(record:)
    @record = record
  end

  def view_template
    return if @record.errors.empty?

    Alert(variant: :destructive) do
      AlertDescription { @record.errors.full_messages.to_sentence }
    end
  end
end
