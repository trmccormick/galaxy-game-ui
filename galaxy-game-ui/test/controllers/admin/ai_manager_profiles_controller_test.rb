require "test_helper"

class Admin::AiManagerProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(
      email_address: "ai-manager-admin@example.com",
      password: "password",
      role: "admin"
    )
    sign_in_as(@admin)
  end

  test "new profile builder loads the Luna template" do
    get admin_ai_manager_new_profile_path

    assert_response :success
    assert_select "h1", "Mission Profile Builder"
    assert_select "input[name='mission_profile[name]']"
  end

  test "creates a session-backed profile draft and displays its assignments" do
    post admin_ai_manager_profiles_path, params: {
      mission_profile: {
        template_id: "luna-precursor",
        name: "Luna Bootstrap — review draft",
        objective: "Establish the initial Luna operating base.",
        target_body: "Luna / Marius Hills",
        task_names: [
          "Precursor launch and arrival",
          "Tank farm preparation"
        ],
        assignments: {
          "0" => "Luna cargo / construction units",
          "2" => "Luna Base Alpha operations group"
        }
      }
    }

    assert_response :redirect
    assert_match %r{/admin/ai_manager/profiles/MP-}, response.location

    follow_redirect!

    assert_response :success
    assert_select "h1", "Luna Bootstrap — review draft"
    assert_select "td", "Luna cargo / construction units"
    assert_select "td", "Luna Base Alpha operations group"
    assert_select "span", text: /Session draft/
  end

  test "rejects a profile with no selected task groupings" do
    post admin_ai_manager_profiles_path, params: {
      mission_profile: {
        template_id: "luna-precursor",
        task_names: [""]
      }
    }

    assert_redirected_to admin_ai_manager_new_profile_path(template_id: "luna-precursor")
    follow_redirect!
    assert_response :success
    assert_select ".mb-5", text: /Mission Profile Builder/
  end
end
