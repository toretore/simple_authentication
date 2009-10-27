module SimpleAuthentication


  module ControllerMethods


    module Application


      def self.included(controller)
        [:logged_in?, :logged_out?, :current_user].each do |m|
          controller.helper_method m
        end
      end


      def current_user
        @_current_user ||= User.find_by_id(session[:current_user_id])
      end

      def logged_in?
        !!current_user
      end

      def logged_out?
        !logged_in?
      end


    private

      def current_user=(user)
        @_current_user = user
        session[:current_user_id] = user && user.id
      end


      def require_login
        unless logged_in?
          flash[:error] = I18n.t('simple_authentication.login_required')
          redirect_to new_login_url
        end
      end

      def require_logout
        unless logged_out?
          flash[:error] = I18n.t('simple_authentication.logout_required')
          redirect_to login_url
        end
      end


    end


    module Logins


      def show
        @user = current_user
      end


      #If there is only one authenticator installed or if one has been specified,
      #this will render its login form.
      #
      #If there is more than one installed and none has been specified, it will
      #list all authenticators as links to their login forms.
      def new
        if authenticator
          send(authenticator.identifier) if respond_to?(authenticator.identifier)
          render :action => authenticator.identifier
        else
          @authenticators = SimpleAuthentication::Authenticator.authenticators
        end
      end


      #Create a login - aka log in the user
      #
      #An authenticator must be specified for authentication to continue. The
      #authenticator will receive the controller as its only parameter and either
      #
      # * respond with :ok, signalling that it takes care of everything
      # * or, if the authentication was successful, return the User that
      #   was authenticated. current_user will then be set to this user.
      # * or, if the authentication failed, return nil or false
      def create
        if params[:authenticator]
          if authenticator && user = authenticator.new(self).authenticate
            unless user == :ok#Authenticator doesn't want any help
              self.current_user = user
              authentication_successful
            end
          elsif authenticator
            #First, see if the authenticator has defined a message of its own
            message = I18n.t(:login_failed, :default => "##not found##",#This is hacky
              :scope => [:simple_authentication, :authenticators, authenticator.identifier])
            #If not, use default
            message = I18n.t('simple_authentication.login_failed') if message == "##not found##"

            authentication_failed message
          else
            authentication_failed
          end
        else
          authentication_failed
        end
      end


      #Destroy the login - aka "log out"
      def destroy
        user = current_user
        self.current_user = nil
        redirect_to(
          method(:login_destroyed_url).arity.zero? ?
            login_destroyed_url :
            login_destroyed_url(user)
        )
      end


    private

      def authenticator
        @authenticator ||= SimpleAuthentication::Authenticator.authenticators.size == 1 ?
          SimpleAuthentication::Authenticator.authenticators.first :
          SimpleAuthentication::Authenticator.authenticator_for(params[:authenticator])
      end


      def authentication_successful(message = I18n.t('simple_authentication.login_successful'))
        flash[:notice] = message
        redirect_to authentication_successful_url
      end

      def authentication_failed(message = I18n.t('simple_authentication.login_failed'))
        flash[:error] = message
        redirect_to authentication_failed_url
      end


      def login_destroyed_url
        new_login_url
      end

      def authentication_successful_url
        login_url
      end

      def authentication_failed_url
        params[:authenticator].blank? ? new_login_url :
          new_login_with_authenticator_url(:authenticator => authenticator.identifier)
      end


      module Behavior

        def self.included(controller)
          controller.before_filter :require_login, :except => [:new, :create]
          controller.before_filter :require_logout, :only => [:new, :create]
        end

      end


    end


  end


end
