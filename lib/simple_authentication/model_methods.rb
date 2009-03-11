module SimpleAuthentication
  module ModelMethods
    module User

      def self.model_classes
        @model_classes ||= []
      end

      #Keep a track of modules/classes that include this module
      def self.included(m)
        model_classes << m
        m.extend ClassMethods
      end

      #When another module is included in this one,
      #include that module in all modules/classes that include this module
      #This way if another module is included in this one after this module
      #has been included elsewhere, those other classes will still have access
      #to the methods in the included module. Example:
      #
      #User.include(SimpleAuthentication::ModelMethods::User)
      #SimpleAuthentication::ModelMethods::User.include(OtherModule)
      #
      #Normally, User wouldn't have access to OtherModule's methods,
      #but we're passing them on. This way, other plugins can add
      #methods to User without having to load/touch it directly.
      def self.include(m)
        self.model_classes.each{|c| c.send(:include, m) }
        super
      end

      def display_name
        name
      end


      #Class methods for User
      #
      #Methods included here are automatically added to User as class methods
      module ClassMethods

        def self.model_classes
          @model_classes ||= []
        end

        #Keep track of model classes (in practise this is just User)
        def self.extended(m)
          model_classes << m
        end

        #When methods are included here, add them to User's eigenclass
        def self.include(m)
          model_classes.each{|c| c.extend m }
          super
        end

      end

    end
  end
end
