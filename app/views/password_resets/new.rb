class Views::PasswordResets::New < Views::Base
  def view_template
    Card(class: "max-w-md mx-auto") do
      CardHeader do
        CardTitle { "Forgot your password?" }
        CardDescription { "Enter your email and we'll send a link to choose a new one." }
      end
      CardContent do
        ActionForm(action: password_resets_path) do
          Stack do
            Field(label: "Email", name: "email_address", type: :email, required: true, autofocus: true, autocomplete: "username", autocapitalize: "none", autocorrect: "off")
            Button(type: :submit) { "Send the link" }
            Link(href: new_session_path) { "Back to sign in" }
          end
        end
      end
    end
  end
end
