class Views::Registrations::New < Views::Base
  def initialize(user:)
    @user = user
  end

  def view_template
    Card(class: "max-w-md mx-auto") do
      CardHeader { CardTitle { "Create your account" } }
      CardContent do
        ActionForm(action: registration_path) do
          Stack do
            ErrorMessages(record: @user)
            Field(label: "Name", name: "user[name]", value: @user.name, required: true)
            Field(label: "Email", name: "user[email_address]", type: :email, value: @user.email_address, required: true)
            Field(label: "Password (6+ characters)", name: "user[password]", type: :password, required: true)
            Button(type: :submit) { "Sign up" }
            Link(href: new_session_path) { "Already have an account?" }
          end
        end
      end
    end
  end
end
