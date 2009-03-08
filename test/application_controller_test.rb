require File.dirname(__FILE__) + '/test_helper.rb'
require 'action_controller/test_process'
require 'user'

load_schema
load_routes do |map|
  map.resources :horses
end

class HorsesController < ApplicationController
  before_filter :require_login, :only => [:show]
  before_filter :require_logout, :only => [:edit]

  def index
    render :text => "index"
  end

  def show
    render :text => "show"
  end

  def edit
    render :text => "edit"
  end

  def rescue_action(e); raise e; end
end

class HorsesControllerTest < ActionController::TestCase

  def setup
    @user = User.create!(:name => "Humbaba", :email => "humbaba@forest")
  end


  def test_current_user_should_be_set_when_session_contains_current_user_id
    get :index, {}, {:current_user_id => @user.id}
    assert_equal @user, @controller.current_user
  end

  def test_current_user_should_be_nil_when_id_does_not_exist
    get :index, {}, {:current_user_id => 456}
    assert_nil @controller.current_user
  end

  def test_current_user_should_be_settable
    get :index
    assert_nil @controller.current_user
    @controller.send :current_user=, @user
    get :index
    assert_equal @user, @controller.current_user
  end

  def test_current_user_should_be_settable_to_nil_for_logout
    get :index, {}, {:current_user_id => @user.id}
    assert_equal @user, @controller.current_user
    get :index
    assert_equal @user, @controller.current_user
    @controller.send :current_user=, nil
    assert_nil @controller.current_user
    get :index
    assert_nil @controller.current_user
  end

  def test_logged_in_should_return_true_if_current_user_not_nil
    get :index, {}, {:current_user_id => @user.id}
    assert_equal @user, @controller.current_user
    assert @controller.logged_in?
    @controller.send :current_user=, nil
    assert !@controller.logged_in?
  end

  def test_logged_out_should_return_true_if_current_user_is_nil
    get :index
    assert @controller.logged_out?
    @controller.send :current_user=, @user
    assert !@controller.logged_out?
  end

  def test_require_login_should_redirect_unless_logged_in
    get :show, {:id => 1}
    assert_response :redirect
  end

  def test_require_logout_should_redirect_unless_logged_out
    get :edit, {:id => 1}, {:current_user_id => @user.id}
    assert_response :redirect
    @controller.send :current_user=, nil
    get :edit, {:id => 1}
    assert_response :ok
  end


end
