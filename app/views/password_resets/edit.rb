class Views::PasswordResets::Edit < Views::Base
  def initialize(token:, errors: [])
    @token = token
    @errors = errors
  end

  def view_template
    Card(class: "max-w-md mx-auto") do
      CardHeader { CardTitle { "Choose a new password" } }
      CardContent do
        ActionForm(action: password_reset_path(@token), method: :patch) do
          Stack do
            Text { @errors.to_sentence } if @errors.any?
            Field(label: "New password (6+ characters)", name: "password", type: :password, required: true, autofocus: true, autocomplete: "new-password")
            Button(type: :submit) { "Update password" }
          end
        end
      end
    end
  end
end
