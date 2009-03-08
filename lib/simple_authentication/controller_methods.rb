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
          redirect_to new_login_url
        end
      end

      def require_logout
        unless logged_out?
          redirect_to login_url
        end
      end


    end


    module Logins


      def show
        @user = current_user
      end


      def new
        if authenticator
          send(authenticator.identifier) if respond_to?(authenticator.identifier)
          render :action => authenticator.identifier
        else
          @authenticators = SimpleAuthentication::Authenticator.authenticators
        end
      end


      def create
        if params[:authenticator] && authenticator && user = authenticator.new(self).authenticate
          unless user == :ok#Authenticator doesn't want any help
            self.current_user = user
            authentication_successful
          end
        else
          authentication_failed
        end
      end


      def destroy
        self.current_user = nil
        redirect_to new_login_url
      end


    private

      def authenticator
        @authenticator ||= SimpleAuthentication::Authenticator.authenticators.size == 1 ?
          SimpleAuthentication::Authenticator.authenticators.first :
          SimpleAuthentication::Authenticator.authenticator_for(params[:authenticator])
      end


      def authentication_successful(message = 'Logged in')
        flash[:notice] = message
        redirect_to login_url
      end

      def authentication_failed(message = 'Login failed')
        flash[:error] = message
        redirect_to params[:authenticator].blank? ?
          new_login_url :
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
