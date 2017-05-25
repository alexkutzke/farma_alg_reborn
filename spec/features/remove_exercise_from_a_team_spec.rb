require 'rails_helper'

describe "Add exercise to a team", type: :feature, js: true do
  let(:user) { create(:user, :teacher) }
  let(:exercise) { create(:exercise, user: user) }
  let!(:team) { create(:team, owner: user, exercises: [exercise]) }

  before do
    login_as user
    visit team_path(team)

    click_on "Listas de exercício"
    click_on "Adicionar exercício"
    find("#remove-exercise-#{exercise.id}").trigger("click")
  end

  xit "replaces the add button and add the exercise to the table" do
    expect(page).to have_selector("#add-exercise-#{exercise.id} a", text: "Adicionar")
    expect(page).to_not have_selector("#team-exercise-#{exercise.id} td a", text: exercise.title)
  end
end
