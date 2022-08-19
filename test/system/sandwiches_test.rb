require "application_system_test_case"

class SandwichesTest < ApplicationSystemTestCase
  setup do
    @sandwich = sandwiches(:one)
  end

  test "visiting the index" do
    visit sandwiches_url
    assert_selector "h1", text: "Sandwiches"
  end

  test "should create sandwich" do
    visit sandwiches_url
    click_on "New sandwich"

    fill_in "Category", with: @sandwich.category
    fill_in "Name", with: @sandwich.name
    click_on "Create Sandwich"

    assert_text "Sandwich was successfully created"
    click_on "Back"
  end

  test "should update Sandwich" do
    visit sandwich_url(@sandwich)
    click_on "Edit this sandwich", match: :first

    fill_in "Category", with: @sandwich.category
    fill_in "Name", with: @sandwich.name
    click_on "Update Sandwich"

    assert_text "Sandwich was successfully updated"
    click_on "Back"
  end

  test "should destroy Sandwich" do
    visit sandwich_url(@sandwich)
    click_on "Destroy this sandwich", match: :first

    assert_text "Sandwich was successfully destroyed"
  end
end
