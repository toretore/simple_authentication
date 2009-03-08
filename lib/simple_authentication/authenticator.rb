module SimpleAuthentication


  class Authenticator

    def initialize(controller)
      @controller = controller
    end

    def authenticate
      raise NotImplementedError
    end

    def authentication_possible?
      false
    end

    def authenticate_if_possible
      return false unless authentication_possible?
      authenticate
    end

  private

    def controller
      @controller
    end

    def params
      controller.params
    end


    def self.authenticators
      @authenticators ||= []
    end


    def self.inherited(klass)
      authenticators << klass
    end

  public

    def self.identifier
      name.split('::').last.gsub(/Authenticator$/, '').underscore
    end

    def self.authenticator_for(identifier)
      authenticators.detect{|a| a.identifier == identifier }
    end


  end


end
