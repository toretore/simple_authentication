require File.dirname(__FILE__) + '/test_helper.rb'
require 'mocha'
require 'action_controller/test_process'
require 'logins_controller'
require 'user'

load_schema
load_routes

class MockAuthenticator < SimpleAuthentication::Authenticator

  def authentication_possible?
    true
  end

  def authenticate
    User.first
  end

end

class RenderingAuthenticator < SimpleAuthentication::Authenticator

  def authentication_possible?
    true
  end

  def authenticate
    controller.send(:render, :text => "humbaba")
    :ok
  end

end

MockAuthenticatorStruct = Struct.new(:identifier)

class LoginsController < ApplicationController
  view_paths << File.join(File.dirname(__FILE__), 'views')
end

class LoginsControllerTest < ActionController::TestCase

  def setup
    @user = User.create!(:name => "Humbaba", :email => "humbaba@forest")
  end


  def test_show_should_use_current_user
    get :show, {}, {:current_user_id, @user.id}
    assert_equal @user, assigns(:user)
  end

  def test_new_should_list_authenticators_when_none_given
    SimpleAuthentication::Authenticator.expects(:authenticators).at_least_once.returns(%w(foo bar).map{|s| MockAuthenticatorStruct.new(s) })
    get :new
    assert_response :ok
    assert_equal SimpleAuthentication::Authenticator.authenticators, assigns(:authenticators)
  end

  def test_new_should_not_list_authenticators_when_there_is_only_one
    SimpleAuthentication::Authenticator.expects(:authenticators).at_least_once.returns(%w(foo).map{|s| MockAuthenticatorStruct.new(s) })
    get :new
    assert_response :ok
    assert_nil assigns(:authenticators)
    assert_equal "foo", @response.body.strip#TODO: Figure out how to use assert_template to do this
  end

  def test_new_should_execute_and_render_authenticator_action_when_present
    SimpleAuthentication::Authenticator.expects(:authenticators).at_least_once.returns(%w(foo bar).map{|s| MockAuthenticatorStruct.new(s) })
    LoginsController.any_instance.expects(:foo)
    get :new, {:authenticator => "foo"}
    assert_response :ok
    assert_equal "foo", @response.body.strip#TODO: Figure out how to use assert_template to do this
  end

  def test_create_should_fail_when_no_authenticator_given
    post :create
    assert_redirected_to new_login_url
    assert !@controller.logged_in?

    post :create
    assert_redirected_to new_login_url
    assert !@controller.logged_in?
  end

  def test_create_should_set_current_user_when_successful
    post :create, {:authenticator => "mock"}
    assert_redirected_to login_url
    assert @controller.logged_in?
    assert_equal User.first, @controller.current_user
  end

  def test_create_should_not_set_current_user_or_redirect_when_authenticator_returns_ok
    post :create, {:authenticator => "rendering"}
    assert_response :ok
    assert_equal "humbaba", @response.body
  end

  def test_create_should_redirect_to_authentication_successful_url_when_login_successful
    def @controller.authentication_successful_url; "success"; end
    post :create, {:authenticator => "mock"}
    assert_redirected_to "success"
  end

  def test_create_should_redirect_to_authentication_failed_url_when_login_failed
    def @controller.authentication_failed_url; "fail"; end
    post :create
    assert_redirected_to "fail"
  end

  def test_destroy_should_unset_current_user
    post :create, {:authenticator => "mock"}
    assert @controller.logged_in?
    delete :destroy
    assert @controller.logged_out?
  end

  def test_destroy_should_redirect_to_login_destroyed_url
    def @controller.login_destroyed_url; "destroyed"; end
    post :create, {:authenticator => "mock"}
    delete :destroy
    assert_redirected_to "destroyed"
  end

  def test_login_destroyed_url_should_receive_previously_logged_in_user_as_parameter_if_arity_allows
    user = nil
    (class << @controller;self;end).send(:define_method, :login_destroyed_url){|u| user = u; "hej" }
    post :create, {:authenticator => "mock"}
    delete :destroy
    assert_redirected_to "hej"
    assert_not_nil user
  end


end
