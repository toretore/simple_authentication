require File.join(File.dirname(__FILE__), 'test_helper')

#Create a custom Authenticator class to prevent pollution from
#other tests that add descendant classes
class CustomAuthenticator < SimpleAuthentication::Authenticator
end

class HorsesController < ApplicationController

  def rescue_action(e)
    raise e
  end

end

class BasicAuthenticator < CustomAuthenticator

  public :controller

end

class RealAuthenticator < CustomAuthenticator

  def authenticate
    :ok
  end

end

class FooBarBazAuthenticator < CustomAuthenticator
end

class FooBar < CustomAuthenticator
end

class AuthenticatorTest < Test::Unit::TestCase

  def setup
    @controller = HorsesController.new
    @basic = BasicAuthenticator.new(@controller)
  end


  def test_all_immediate_descendants_should_be_registered
    descendants = [BasicAuthenticator, RealAuthenticator, FooBarBazAuthenticator, FooBar]
    assert_equal descendants, CustomAuthenticator.authenticators
  end


  def test_should_have_access_to_controller
    assert_equal @controller, @basic.controller
  end

  def test_should_raise_if_authenticate_not_overridden
    assert_raise(NotImplementedError){ @basic.authenticate }
  end

  def test_authentication_possible_should_return_false_by_default
    assert_equal false, @basic.authentication_possible?
  end

  def test_identifier
    assert_equal "basic", BasicAuthenticator.identifier
    assert_equal "real", RealAuthenticator.identifier
    assert_equal "foo_bar_baz", FooBarBazAuthenticator.identifier
    assert_equal "foo_bar", FooBar.identifier
  end

  def test_authenticator_for_should_return_authenticator_class_with_matching_identifier
    assert_equal BasicAuthenticator, CustomAuthenticator.authenticator_for("basic")
    assert_equal FooBarBazAuthenticator, CustomAuthenticator.authenticator_for("foo_bar_baz")
    assert_equal FooBar, CustomAuthenticator.authenticator_for("foo_bar")
    assert_equal nil, CustomAuthenticator.authenticator_for("nonexistant")
  end


end
