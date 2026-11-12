class Views::Sessions::New < Views::Base
  def view_template
    Card(class: "max-w-md mx-auto") do
      CardHeader { CardTitle { "Sign in" } }
      CardContent do
        ActionForm(action: session_path) do
          Stack do
            Field(label: "Email", name: "email_address", type: :email, required: true, autofocus: true, autocomplete: "username", autocapitalize: "none", autocorrect: "off")
            Field(label: "Password", name: "password", type: :password, required: true, autocomplete: "current-password")
            Button(type: :submit) { "Sign in" }
            Link(href: new_registration_path) { "Create an account" }
          end
        end
      end
    end
  end
end
