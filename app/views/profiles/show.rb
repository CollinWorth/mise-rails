class Views::Profiles::Show < Views::Base
  def initialize(user:)
    @user = user
  end

  def view_template
    PageHeader(title: "Your account")
    Text { "#{@user.recipes.count} recipes · #{@user.followers.count} followers · #{@user.following.count} following" }

    Card do
      CardHeader { CardTitle { "Profile" } }
      CardContent do
        ActionForm(action: profile_path, method: :patch) do
          Stack do
            ErrorMessages(record: @user)
            Field(label: "Name", name: "user[name]", value: @user.name, autocomplete: "name")
            Field(label: "Email", name: "user[email_address]", type: :email, value: @user.email_address, autocomplete: "username", autocapitalize: "none", autocorrect: "off")
            Button(type: :submit) { "Save" }
          end
        end
      end
    end

    Card do
      CardHeader do
        CardTitle { "Appearance" }
        CardDescription { "Choose how Mise looks, and the colors it uses in light and in dark." }
      end
      CardContent { AppearancePicker(user: @user) }
    end

    ActionForm(action: session_path, method: :delete) { Button(type: :submit, variant: :outline) { "Sign out" } }

    Card do
      CardHeader { CardTitle { "Change password" } }
      CardContent do
        ActionForm(action: password_path, method: :patch) do
          Stack do
            Field(label: "Current password", name: "current_password", type: :password, autocomplete: "current-password")
            Field(label: "New password", name: "password", type: :password, autocomplete: "new-password")
            Button(type: :submit) { "Update password" }
          end
        end
      end
    end

    Card do
      CardHeader do
        CardTitle { "Delete account" }
        CardDescription { "Removes your account and all of your recipes." }
      end
      CardContent do
        ActionForm(action: profile_path, method: :delete) do
          Row do
            Input(type: :password, name: "password", placeholder: "Confirm password")
            Button(type: :submit, variant: :destructive) { "Delete account" }
          end
        end
      end
    end
  end
end
