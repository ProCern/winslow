# Say Hello To Winslow

Winslow helps you make wizards where some steps of the wizard are in other
applications. Its basically [wicked](https://github.com/schneems/wicked)
modified to handle being able to define steps that send the user to another
application.

## Creating A Wizard

In order to create a wizard, create a new controller and inherit from `Winslow::WizardController`.

    class UserWizardController < Winslow::WizardController
      add_step :new_user

      add_step :service => :user_preferences,
               :resource => :wizard,
               :query_params => lambda do |controller|
                                  { :user_href => controller.user_url(controller.current_user) }
                                end
      add_step :confirmation

      def show
        @user = current_user
        render_wizard
      end

      def update
        @user = current_user
        @user.update_attributes(params[:user])
        render_wizard @user
      end

      def finish_wizard_path
        users_path
      end
    end

To add a step to the wizard, you call `add_step` and pass either a symbol or a
hash. If you pass a symbol, you need to create a view with the same name as the
step. So in the example above, for the `new_user` step, a view needs to be
created in `app/views/user_wizard/new_user.html.erb`.

In order to define a step that calls an external application, you pass a hash
to `add_step`. The hash should contain whatever information you need to
determine the url to redirect to. This hash will be passed to the
`resource_lookup` method you configure Winslow with (see below).

If you need to pass query parameters to the external application, add a
`query_params` key to the hash passed to `add_step`. The value can be a hash or
a proc that, when called, returns a hash. If a proc is given it will be called
with the controller as a parameter.

When a wizard reaches its last step it will redirect to the value returned by
calling `finish_wizard_path`. By default this is `/`. Override
`finish_wizard_path` if you need to go to a different url when your wizard is
complete. The exception to this is is that if your wizard was invoked as a step
from another wizard. In that case, you will be redirected to the next step in
the original wizard.

I guess this is a good time to mention that when a step in a wizard calls
another application, it must call into another wizard. So the controller in the
other application for the second step above could look something like this.

    class UserPreferenceWizardController < Winslow::WizardController
      add_step :new_user_preference

      return_step_query_params lambda do |controller|
                                 { :user_preferences_href => controller.user_preference_url(controller.current_user_preference) }
                               end

      def show
        @user_preference = current_user_preference
        render_wizard
      end

      def update
        @user_preference = current_user_preference
        @user_preference.update_attributes(params[:user_preference])
        render_wizard @user_preference
      end
    end

After the `new_user_preference` step is run, the user will be redirected to the
`confirmation` step in the `UserWizardController`.

If you need to pass query parameters back to the original wizard you can call
the `return_step_query_params` method and pass it either a hash of query
parameters or a proc that, when called, returns a hash of query parameters. If
a proc is given it will be called with the controller as a parameter.

## Defining How External Resources Are Found

In order to define how winslow finds the urls for external steps, you define a
`resource_lookup` method in an initializer. So you could have something like
this in `config/initializers/winslow.rb`.

    Winslow.configure do |config|
      config.resource_lookup = lambda do |options|
        # lookup logic goes here
      end
    end

The `options` parameter is the hash given when adding the step. The result of
calling `resource_lookup` should be a url that the user can be redirected to.
